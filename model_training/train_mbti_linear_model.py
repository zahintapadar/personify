import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, accuracy_score
import pickle
import json
import os
import hashlib
from pathlib import Path
import time

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

# Use CPU only for compatibility on M1 Mac
tf.config.set_visible_devices([], 'GPU')

# Cache directory for preprocessed data
CACHE_DIR = Path('../cache')
CACHE_DIR.mkdir(exist_ok=True)

def load_and_preprocess_data(csv_path):
    """Load and preprocess the MBTI dataset with caching for TF-IDF"""
    print("Loading MBTI dataset...")
    
    # Create cache key based on file modification time and path
    file_stat = os.stat(csv_path)
    cache_key = hashlib.md5(f"{csv_path}_{file_stat.st_mtime}_tfidf".encode()).hexdigest()
    cache_file = CACHE_DIR / f"tfidf_data_{cache_key}.pkl"
    
    # Try to load from cache
    if cache_file.exists():
        print("Loading preprocessed TF-IDF data from cache...")
        with open(cache_file, 'rb') as f:
            return pickle.load(f)
    
    # Load and preprocess data
    df = pd.read_csv(csv_path)
    print(f"Dataset shape: {df.shape}")
    
    # Use 100% of the dataset for maximum accuracy
    df_sample = df  # Use entire dataset
    print(f"Using full dataset: {df_sample.shape[0]} samples")
    
    # Balanced sampling for better performance - use more data per class
    balanced_samples = []
    min_samples_per_class = 200   # Higher minimum samples per class
    max_samples_per_class = 2000  # Much more samples per class for better learning
    
    for mbti_type in df_sample['type'].unique():
        type_samples = df_sample[df_sample['type'] == mbti_type]
        available_samples = len(type_samples)
        
        if available_samples < min_samples_per_class:
            print(f"Warning: {mbti_type} has only {available_samples} samples (less than {min_samples_per_class})")
            samples_to_take = available_samples
        else:
            samples_to_take = min(available_samples, max_samples_per_class)
        
        # Randomly sample the data
        if samples_to_take < available_samples:
            selected_samples = type_samples.sample(n=samples_to_take, random_state=42)
        else:
            selected_samples = type_samples
            
        balanced_samples.append(selected_samples)
        print(f"{mbti_type}: {samples_to_take} samples")
    
    df_balanced = pd.concat(balanced_samples, ignore_index=True)
    print(f"Balanced dataset size: {df_balanced.shape[0]}")
    print(f"Distribution of types:\n{df_balanced['type'].value_counts()}")
    
    # Extract posts and labels
    texts = df_balanced['posts'].values
    labels = df_balanced['type'].values
    
    # Preprocess texts - keep first 500 characters and clean
    texts = [str(text)[:500].lower() for text in texts]
    print(f"Text length: average {np.mean([len(text) for text in texts]):.0f} characters")
    
    # Cache the processed data
    print("Caching preprocessed data...")
    with open(cache_file, 'wb') as f:
        pickle.dump((texts, labels), f)
    
    return texts, labels

def create_tfidf_features(texts, max_features=5000):
    """Create TF-IDF features from texts with higher feature count for better accuracy"""
    print(f"Creating TF-IDF features with max_features={max_features}...")
    
    # Check for cached TF-IDF vectorizer
    tfidf_cache = CACHE_DIR / f"tfidf_vectorizer_{max_features}.pkl"
    features_cache = CACHE_DIR / f"tfidf_features_{max_features}.pkl"
    
    if tfidf_cache.exists() and features_cache.exists():
        print("Loading TF-IDF vectorizer and features from cache...")
        with open(tfidf_cache, 'rb') as f:
            vectorizer = pickle.load(f)
        with open(features_cache, 'rb') as f:
            features = pickle.load(f)
        return features, vectorizer
    
    # Create TF-IDF vectorizer with enhanced parameters for accuracy
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words='english',
        ngram_range=(1, 3),  # Include trigrams for better context
        lowercase=True,
        strip_accents='ascii',
        min_df=2,  # Ignore terms that appear in less than 2 documents
        max_df=0.95,  # Ignore terms that appear in more than 95% of documents
        sublinear_tf=True  # Apply sublinear TF scaling
    )
    
    # Fit and transform texts
    features = vectorizer.fit_transform(texts).toarray()
    
    print(f"TF-IDF features shape: {features.shape}")
    print(f"Feature vocabulary size: {len(vectorizer.vocabulary_)}")
    
    # Cache vectorizer and features
    print("Caching TF-IDF vectorizer and features...")
    with open(tfidf_cache, 'wb') as f:
        pickle.dump(vectorizer, f)
    with open(features_cache, 'wb') as f:
        pickle.dump(features, f)
    
    return features, vectorizer

def create_linear_model(input_dim, num_classes):
    """Create a simple but effective TensorFlow linear model"""
    print(f"Creating linear model with input_dim={input_dim}, num_classes={num_classes}")
    
    model = tf.keras.Sequential([
        # Input layer
        tf.keras.layers.Dense(
            256, 
            activation='relu', 
            input_shape=(input_dim,),
            kernel_regularizer=tf.keras.regularizers.l2(0.001)
        ),
        tf.keras.layers.Dropout(0.5),
        
        # Hidden layer
        tf.keras.layers.Dense(
            128, 
            activation='relu',
            kernel_regularizer=tf.keras.regularizers.l2(0.001)
        ),
        tf.keras.layers.Dropout(0.3),
        
        # Hidden layer
        tf.keras.layers.Dense(
            64, 
            activation='relu',
            kernel_regularizer=tf.keras.regularizers.l2(0.001)
        ),
        tf.keras.layers.Dropout(0.2),
        
        # Output layer
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    # Compile with appropriate optimizer and loss
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def main():
    start_time = time.time()
    
    # Configuration for mobile-optimized linear model
    MAX_FEATURES = 1000   # TF-IDF max features for speed
    BATCH_SIZE = 64       # Batch size for training
    EPOCHS = 15           # More epochs for linear model
    
    print("=== TensorFlow Linear MBTI Classification Model ===")
    print(f"Configuration: max_features={MAX_FEATURES}, batch_size={BATCH_SIZE}, epochs={EPOCHS}")
    
    # Load data
    csv_path = '../lib/data/mbti_personality.csv'
    texts, labels = load_and_preprocess_data(csv_path)
    
    # Create TF-IDF features
    X_tfidf, vectorizer = create_tfidf_features(texts, max_features=MAX_FEATURES)
    
    # Encode labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(labels)
    
    print(f"Label classes: {label_encoder.classes_}")
    print(f"Number of classes: {len(label_encoder.classes_)}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X_tfidf, y_encoded, 
        test_size=0.2, 
        random_state=42, 
        stratify=y_encoded
    )
    
    print(f"Training samples: {X_train.shape[0]}")
    print(f"Test samples: {X_test.shape[0]}")
    print(f"Feature dimensions: {X_train.shape[1]}")
    
    # Calculate class weights for imbalanced dataset
    from sklearn.utils.class_weight import compute_class_weight
    class_weights = compute_class_weight(
        'balanced',
        classes=np.unique(y_train),
        y=y_train
    )
    class_weight_dict = dict(enumerate(class_weights))
    print(f"Using balanced class weights")
    
    # Create and train model
    model = create_linear_model(X_train.shape[1], len(label_encoder.classes_))
    
    print("\nModel architecture:")
    model.summary()
    
    # Training callbacks
    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='val_accuracy', 
        patience=5, 
        restore_best_weights=True,
        verbose=1
    )
    
    reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss', 
        factor=0.2, 
        patience=3, 
        min_lr=0.0001,
        verbose=1
    )
    
    # Train the model
    print("\nTraining model...")
    training_start = time.time()
    
    history = model.fit(
        X_train, y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_test, y_test),
        class_weight=class_weight_dict,
        callbacks=[early_stopping, reduce_lr],
        verbose=1
    )
    
    training_time = time.time() - training_start
    print(f"Training completed in {training_time:.2f} seconds")
    
    # Evaluate model
    print("\nEvaluating model...")
    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test accuracy: {test_accuracy:.4f}")
    print(f"Test loss: {test_loss:.4f}")
    
    # Generate predictions for detailed evaluation
    y_pred = model.predict(X_test, verbose=0)
    y_pred_classes = np.argmax(y_pred, axis=1)
    
    # Classification report
    print("\nDetailed Classification Report:")
    print(classification_report(y_test, y_pred_classes, target_names=label_encoder.classes_))
    
    # Save all model artifacts
    print("\nSaving model and preprocessing artifacts...")
    
    # Create assets directory if it doesn't exist
    assets_dir = '../assets/models'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Save Keras model in new format
    model_path = f'{assets_dir}/mbti_linear_model.keras'
    model.save(model_path)
    print(f"✓ Keras model saved: {model_path}")
    
    # Convert to TensorFlow Lite
    print("Converting to TensorFlow Lite...")
    try:
        # Create converter
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Set optimizations for mobile deployment
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Convert model
        tflite_model = converter.convert()
        
        # Save TensorFlow Lite model
        tflite_path = f'{assets_dir}/mbti_linear_model.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        print(f"✓ TensorFlow Lite model saved: {tflite_path}")
        
        # Model size info
        tflite_size = len(tflite_model) / 1024  # KB
        print(f"✓ TensorFlow Lite model size: {tflite_size:.1f} KB")
        
    except Exception as e:
        print(f"Warning: TensorFlow Lite conversion failed: {e}")
        print("Continuing with Keras model only...")
    
    # Save TF-IDF vectorizer
    vectorizer_path = f'{assets_dir}/mbti_tfidf_vectorizer.pickle'
    with open(vectorizer_path, 'wb') as f:
        pickle.dump(vectorizer, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ TF-IDF vectorizer saved: {vectorizer_path}")
    
    # Save label encoder
    encoder_path = f'{assets_dir}/mbti_label_encoder.pickle'
    with open(encoder_path, 'wb') as f:
        pickle.dump(label_encoder, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ Label encoder saved: {encoder_path}")
    
    # Save preprocessing parameters and metadata
    preprocessing_params = {
        'model_type': 'tensorflow_linear',
        'max_features': MAX_FEATURES,
        'input_dim': X_train.shape[1],
        'num_classes': len(label_encoder.classes_),
        'label_classes': label_encoder.classes_.tolist(),
        'test_accuracy': float(test_accuracy),
        'test_loss': float(test_loss),
        'training_time_seconds': training_time,
        'total_samples': len(texts),
        'train_samples': X_train.shape[0],
        'test_samples': X_test.shape[0],
        'epochs_trained': len(history.history['loss']),
        'model_architecture': 'Dense(256)->Dense(128)->Dense(64)->Dense(16)',
        'optimizer': 'Adam(lr=0.001)',
        'regularization': 'L2(0.001)',
        'created_timestamp': time.time()
    }
    
    params_path = f'{assets_dir}/mbti_linear_params.json'
    with open(params_path, 'w') as f:
        json.dump(preprocessing_params, f, indent=2)
    print(f"✓ Model parameters saved: {params_path}")
    
    # Summary
    total_time = time.time() - start_time
    print(f"\n{'='*60}")
    print(f"🎉 MBTI Linear Model Training Complete!")
    print(f"{'='*60}")
    print(f"📊 Test Accuracy: {test_accuracy:.2%}")
    print(f"⏱️  Total Time: {total_time:.1f} seconds")
    print(f"🏋️  Training Time: {training_time:.1f} seconds")
    print(f"📦 Model Files:")
    print(f"   • mbti_linear_model.keras")
    print(f"   • mbti_linear_model.tflite")
    print(f"   • mbti_tfidf_vectorizer.pickle")
    print(f"   • mbti_label_encoder.pickle")
    print(f"   • mbti_linear_params.json")
    print(f"📁 Saved in: {assets_dir}/")

if __name__ == "__main__":
    main()

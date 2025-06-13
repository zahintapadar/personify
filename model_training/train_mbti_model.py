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

# Use float32 for stability
tf.config.set_visible_devices([], 'GPU')  # Use CPU only for compatibility

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
    
    # Use 50% of the dataset for better performance
    df_sample = df.sample(frac=0.5, random_state=42)
    print(f"Using sample size: {df_sample.shape[0]} (50% of original)")
    
    # Balanced sampling for better performance
    balanced_samples = []
    min_samples_per_class = 100   # Higher minimum samples per class
    max_samples_per_class = 500   # More samples per class for better learning
    
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

def create_tfidf_features(texts, max_features=1000):
    """Create TF-IDF features from texts"""
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
    
    # Create TF-IDF vectorizer
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words='english',
        ngram_range=(1, 2),  # Include bigrams for better context
        lowercase=True,
        strip_accents='ascii'
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
    
    # Load data
    csv_path = '../lib/data/mbti_personality.csv'
    texts, labels = load_and_preprocess_data(csv_path)
    
    # Create TF-IDF features
    X_tfidf, vectorizer = create_tfidf_features(texts, max_features=MAX_FEATURES)
    
    # Encode labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(labels)
    
    print(f"Label classes: {label_encoder.classes_}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X_tfidf, y_encoded, 
        test_size=0.2, 
        random_state=42, 
        stratify=y_encoded
    )
    
    print(f"Training samples: {X_train.shape[0]}")
    print(f"Test samples: {X_test.shape[0]}")
    
    # Calculate class weights to handle imbalanced dataset
    from sklearn.utils.class_weight import compute_class_weight
    class_weights = compute_class_weight(
        'balanced',
        classes=np.unique(y_train),
        y=y_train
    )
    class_weight_dict = dict(enumerate(class_weights))
    
    # Create model
    model = create_linear_model(X_train.shape[1], len(label_encoder.classes_))
    
    print("\nModel architecture:")
    model.summary()
    
    # Train model
    print("\nTraining model...")
    
    # Callbacks
    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='val_accuracy', 
        patience=5, 
        restore_best_weights=True
    )
    
    reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss', 
        factor=0.2, 
        patience=3, 
        min_lr=0.0001
    )
    
    # Train the model
    history = model.fit(
        X_train, y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_test, y_test),
        class_weight=class_weight_dict,
        callbacks=[early_stopping, reduce_lr],
        verbose=1
    )
    
    # Evaluate model
    print("\nEvaluating model...")
    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test accuracy: {test_accuracy:.4f}")
    
    # Generate predictions for detailed evaluation
    y_pred = model.predict(X_test, verbose=0)
    y_pred_classes = np.argmax(y_pred, axis=1)
    
    # Classification report
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred_classes, target_names=label_encoder.classes_))
    
    # Save model in different formats
    print("\nSaving model...")
    
    # Create assets directory if it doesn't exist
    assets_dir = '../assets/models'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Save Keras model
    model.save(f'{assets_dir}/mbti_linear_model.keras')
    
    # Convert to TensorFlow Lite with optimizations
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    try:
        tflite_model = converter.convert()
        
        with open(f'{assets_dir}/mbti_linear_model.tflite', 'wb') as f:
            f.write(tflite_model)
        print("✓ TensorFlow Lite model saved successfully")
    except Exception as e:
        print(f"Warning: TFLite conversion failed: {e}")
        print("Saving only the Keras model")
    
    # Save TF-IDF vectorizer
    with open(f'{assets_dir}/mbti_tfidf_vectorizer.pickle', 'wb') as f:
        pickle.dump(vectorizer, f, protocol=pickle.HIGHEST_PROTOCOL)
    
    # Save preprocessing parameters
    preprocessing_params = {
        'model_type': 'tensorflow_linear',
        'max_features': MAX_FEATURES,
        'input_dim': X_train.shape[1],
        'label_classes': label_encoder.classes_.tolist(),
        'test_accuracy': float(test_accuracy)
    }
    
    with open(f'{assets_dir}/mbti_linear_params.json', 'w') as f:
        json.dump(preprocessing_params, f, indent=2)
    
    # Save label encoder
    with open(f'{assets_dir}/mbti_label_encoder.pickle', 'wb') as f:
        pickle.dump(label_encoder, f, protocol=pickle.HIGHEST_PROTOCOL)
    
    total_time = time.time() - start_time
    print(f"\nModel training completed in {total_time:.2f} seconds!")
    print(f"Test Accuracy: {test_accuracy:.4f}")
    print(f"Files saved in: {assets_dir}/")
    print("- mbti_linear_model.keras")
    print("- mbti_linear_model.tflite") 
    print("- mbti_tfidf_vectorizer.pickle")
    print("- mbti_label_encoder.pickle")
    print("- mbti_linear_params.json")

if __name__ == "__main__":
    main()

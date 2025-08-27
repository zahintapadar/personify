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
import re
from collections import Counter

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

# Use CPU only for compatibility on M1 Mac
tf.config.set_visible_devices([], 'GPU')

# Cache directory for preprocessed data
CACHE_DIR = Path('../cache')
CACHE_DIR.mkdir(exist_ok=True)

def clean_text(text):
    """Enhanced text cleaning for MBTI posts"""
    if pd.isna(text):
        return ""
    
    # Convert to string and lowercase
    text = str(text).lower()
    # Remove URLs
    text = re.sub(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', text)
    # Remove special characters
    text = re.sub(r'[^a-zA-Z0-9\s]', ' ', text)
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    # Remove stopwords (for English)
    stopwords = set(["the","and","is","in","to","of","for","on","with","as","by","at","from","it","an","be","this","that","are","was","were","or","but","not","have","has","had","a","i","you","he","she","they","we","my","your","his","her","their","our"])
    words = [word for word in text.split() if word not in stopwords and 2 <= len(word) <= 20]
    return ' '.join(words).strip()

def load_and_preprocess_data(csv_path, use_full_dataset=False, max_samples_per_class=2000):
    """Load and preprocess the MBTI dataset with balanced sampling"""
    print("Loading MBTI dataset...")
    
    # Create cache key based on configuration
    config_key = f"balanced_{max_samples_per_class}"
    cache_key = hashlib.md5(f"{csv_path}_{config_key}_enhanced".encode()).hexdigest()
    cache_file = CACHE_DIR / f"enhanced_data_{cache_key}.pkl"
    
    # Try to load from cache
    if cache_file.exists():
        print("Loading preprocessed data from cache...")
        with open(cache_file, 'rb') as f:
            return pickle.load(f)
    
    # Load data
    df = pd.read_csv(csv_path)
    print(f"Original dataset shape: {df.shape}")
    
    # Clean and preprocess posts
    print("Cleaning and preprocessing text data...")
    df['cleaned_posts'] = df['posts'].apply(clean_text)
    
    # Remove empty posts
    df = df[df['cleaned_posts'].str.len() > 10]
    print(f"After removing empty posts: {df.shape}")
    
    # Balanced sampling for better accuracy and faster training
    balanced_samples = []
    min_samples_per_class = 500  # Minimum samples per class
    
    print("Creating balanced dataset...")
    for mbti_type in df['type'].unique():
        type_samples = df[df['type'] == mbti_type]
        available_samples = len(type_samples)
        
        if available_samples < min_samples_per_class:
            print(f"Warning: {mbti_type} has only {available_samples} samples")
            samples_to_take = available_samples
        else:
            samples_to_take = min(available_samples, max_samples_per_class)
        
        # Randomly sample the data for diversity
        if samples_to_take < available_samples:
            selected_samples = type_samples.sample(n=samples_to_take, random_state=42)
        else:
            selected_samples = type_samples
            
        balanced_samples.append(selected_samples)
        print(f"{mbti_type}: {samples_to_take} samples")
    
    df_balanced = pd.concat(balanced_samples, ignore_index=True)
    print(f"Balanced dataset size: {df_balanced.shape[0]}")
    
    # Shuffle the dataset
    df_balanced = df_balanced.sample(frac=1, random_state=42).reset_index(drop=True)
    
    texts = df_balanced['cleaned_posts'].values
    labels = df_balanced['type'].values
    
    print(f"Text statistics:")
    text_lengths = [len(text) for text in texts]
    print(f"  Average length: {np.mean(text_lengths):.0f} characters")
    print(f"  Median length: {np.median(text_lengths):.0f} characters")
    print(f"  Max length: {np.max(text_lengths):.0f} characters")
    
    print("Caching preprocessed data...")
    with open(cache_file, 'wb') as f:
        pickle.dump((texts, labels), f)
    return texts, labels

def create_advanced_tfidf_features(texts, max_features=5000):
    """Create optimized TF-IDF features for MBTI classification"""
    print(f"Creating TF-IDF features with max_features={max_features}...")
    
    # Cache key based on features and texts
    texts_hash = hashlib.md5(str(texts[:100]).encode()).hexdigest()[:8]
    tfidf_cache = CACHE_DIR / f"tfidf_vectorizer_{max_features}_{texts_hash}.pkl"
    features_cache = CACHE_DIR / f"tfidf_features_{max_features}_{texts_hash}.pkl"
    
    if tfidf_cache.exists() and features_cache.exists():
        print("Loading TF-IDF vectorizer and features from cache...")
        with open(tfidf_cache, 'rb') as f:
            vectorizer = pickle.load(f)
        with open(features_cache, 'rb') as f:
            features = pickle.load(f)
        return features, vectorizer
    
    # Create optimized TF-IDF vectorizer
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words='english',
        ngram_range=(1, 3),  # Up to trigrams for context
        lowercase=True,
        strip_accents='ascii',
        min_df=3,  # Ignore rare terms
        max_df=0.9,  # Ignore very common terms
        sublinear_tf=True,
        use_idf=True,
        smooth_idf=True,
        norm='l2'
    )
    # Fit and transform texts
    print("Fitting TF-IDF vectorizer...")
    features = vectorizer.fit_transform(texts).toarray()
    
    print(f"TF-IDF features shape: {features.shape}")
    print(f"Vocabulary size: {len(vectorizer.vocabulary_)}")
    print(f"Feature density: {np.count_nonzero(features) / features.size:.4f}")
    
    # Cache vectorizer and features
    print("Caching TF-IDF data...")
    with open(tfidf_cache, 'wb') as f:
        pickle.dump(vectorizer, f)
    with open(features_cache, 'wb') as f:
        pickle.dump(features, f)
    
    return features, vectorizer

def create_optimized_model(input_dim, num_classes):
    """Create an optimized neural network model for MBTI classification"""
    print(f"Creating optimized model with input_dim={input_dim}, num_classes={num_classes}")
    
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(512, activation='relu', input_shape=(input_dim,), 
                             kernel_regularizer=tf.keras.regularizers.l2(0.0002)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.5),
        
        tf.keras.layers.Dense(256, activation='relu', 
                             kernel_regularizer=tf.keras.regularizers.l2(0.0002)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.4),
        
        tf.keras.layers.Dense(128, activation='relu', 
                             kernel_regularizer=tf.keras.regularizers.l2(0.0002)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        tf.keras.layers.Dense(64, activation='relu', 
                             kernel_regularizer=tf.keras.regularizers.l2(0.0002)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    model.compile(
        optimizer=tf.keras.optimizers.Adam(
            learning_rate=0.0005,
            beta_1=0.9,
            beta_2=0.999,
            epsilon=1e-07
        ),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model

def main():
    start_time = time.time()
    
    # Configuration for extremely accurate optimized model
    MAX_FEATURES = 15000       # Optimal feature count for accuracy vs speed
    BATCH_SIZE = 64            # Smaller batch size for better convergence
    EPOCHS = 30               # More epochs for deeper learning
    MAX_SAMPLES_PER_CLASS = 3000  # More samples per class for better learning
    
    print("=== Optimized TensorFlow MBTI Classification Model (M4 Mac) ===")
    print(f"Configuration:")
    print(f"  • Max Features: {MAX_FEATURES}")
    print(f"  • Batch Size: {BATCH_SIZE}")
    print(f"  • Epochs: {EPOCHS}")
    print(f"  • Max Samples per Class: {MAX_SAMPLES_PER_CLASS}")
    
    # Load and preprocess data
    csv_path = '../lib/data/mbti_personality.csv'
    if not os.path.exists(csv_path):
        print(f"Error: Dataset file not found at {csv_path}")
        print("Please ensure the MBTI dataset is available.")
        return
        
    texts, labels = load_and_preprocess_data(
        csv_path,
        use_full_dataset=False,
        max_samples_per_class=MAX_SAMPLES_PER_CLASS
    )
    
    # Create TF-IDF features
    X_tfidf, vectorizer = create_advanced_tfidf_features(texts, max_features=MAX_FEATURES)
    # Encode labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(labels)
    print(f"\nLabel encoding:")
    print(f"  • Classes: {label_encoder.classes_}")
    print(f"  • Number of classes: {len(label_encoder.classes_)}")
    # Split data with stratification
    X_train, X_test, y_train, y_test = train_test_split(
        X_tfidf, y_encoded,
        test_size=0.2,
        random_state=42,
        stratify=y_encoded
    )
    print(f"\nDataset split:")
    print(f"  • Training samples: {X_train.shape[0]}")
    print(f"  • Test samples: {X_test.shape[0]}")
    print(f"  • Feature dimensions: {X_train.shape[1]}")
    # Calculate balanced class weights
    from sklearn.utils.class_weight import compute_class_weight
    class_weights = compute_class_weight(
        'balanced',
        classes=np.unique(y_train),
        y=y_train
    )
    class_weight_dict = dict(enumerate(class_weights))
    print(f"  • Using balanced class weights")
    # Create optimized model
    model = create_optimized_model(X_train.shape[1], len(label_encoder.classes_))
    print(f"\nModel architecture:")
    model.summary()
    # Enhanced training callbacks for better accuracy
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=15,  # More patience for better convergence
            restore_best_weights=True,
            verbose=1,
            min_delta=0.0005
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.3,  # More aggressive learning rate reduction
            patience=7,
            min_lr=0.00001,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath='../cache/best_optimized_model.keras',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    # Train the model
    print(f"\nStarting training...")
    training_start = time.time()
    history = model.fit(
        X_train, y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_test, y_test),
        class_weight=class_weight_dict,
        callbacks=callbacks,
        verbose=1
    )
    training_time = time.time() - training_start
    print(f"\nTraining completed in {training_time:.2f} seconds")
    
    # Evaluate model
    print(f"\\nEvaluating optimized model...")
    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"  • Test accuracy: {test_accuracy:.4f} ({test_accuracy:.2%})")
    print(f"  • Test loss: {test_loss:.4f}")
    
    # Generate detailed predictions
    y_pred = model.predict(X_test, verbose=0)
    y_pred_classes = np.argmax(y_pred, axis=1)
    
    # Calculate top-k accuracies manually
    def calculate_top_k_accuracy(y_true, y_pred_probs, k=5):
        """Calculate top-k accuracy"""
        top_k_predictions = np.argsort(y_pred_probs, axis=1)[:, -k:]
        correct = 0
        for i, true_label in enumerate(y_true):
            if true_label in top_k_predictions[i]:
                correct += 1
        return correct / len(y_true)
    
    top_3_acc = calculate_top_k_accuracy(y_test, y_pred, k=3)
    top_5_acc = calculate_top_k_accuracy(y_test, y_pred, k=5)
    
    print(f"  • Top-3 accuracy: {top_3_acc:.4f} ({top_3_acc:.2%})")
    print(f"  • Top-5 accuracy: {top_5_acc:.4f} ({top_5_acc:.2%})")
    
    # Classification report
    print(f"\\nDetailed Classification Report:")
    report = classification_report(
        y_test, 
        y_pred_classes, 
        target_names=label_encoder.classes_,
        digits=3
    )
    print(report)
    
    # Save all model artifacts
    print(f"\\nSaving optimized model and artifacts...")
    
    # Create assets directory
    assets_dir = '../assets/models'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Save Keras model
    model_path = f'{assets_dir}/mbti_optimized_model.keras'
    model.save(model_path)
    print(f"✓ Optimized Keras model saved: {model_path}")
    
    # Convert to TensorFlow Lite
    print("Converting to TensorFlow Lite...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Enable float16 quantization for smaller model size
        converter.target_spec.supported_types = [tf.float16]
        
        tflite_model = converter.convert()
        
        tflite_path = f'{assets_dir}/mbti_optimized_model.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        tflite_size = len(tflite_model) / 1024  # KB
        print(f"✓ Optimized TensorFlow Lite model saved: {tflite_path}")
        print(f"✓ TensorFlow Lite model size: {tflite_size:.1f} KB")
        
    except Exception as e:
        print(f"Warning: TensorFlow Lite conversion failed: {e}")
    
    # Save TF-IDF vectorizer
    vectorizer_path = f'{assets_dir}/mbti_optimized_vectorizer.pickle'
    with open(vectorizer_path, 'wb') as f:
        pickle.dump(vectorizer, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ Optimized TF-IDF vectorizer saved: {vectorizer_path}")
    
    # Save label encoder
    encoder_path = f'{assets_dir}/mbti_optimized_encoder.pickle'
    with open(encoder_path, 'wb') as f:
        pickle.dump(label_encoder, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ Optimized label encoder saved: {encoder_path}")
    
    # Save comprehensive parameters
    best_epoch = np.argmax(history.history['val_accuracy']) + 1
    best_val_acc = np.max(history.history['val_accuracy'])
    
    preprocessing_params = {
        'model_type': 'tensorflow_optimized',
        'max_features': MAX_FEATURES,
        'input_dim': X_train.shape[1],
        'num_classes': len(label_encoder.classes_),
        'label_classes': label_encoder.classes_.tolist(),
        'test_accuracy': float(test_accuracy),
        'test_loss': float(test_loss),
        'test_top_3_accuracy': float(top_3_acc),
        'test_top_5_accuracy': float(top_5_acc),
        'best_val_accuracy': float(best_val_acc),
        'best_epoch': int(best_epoch),
        'training_time_seconds': training_time,
        'total_samples': len(texts),
        'train_samples': X_train.shape[0],
        'test_samples': X_test.shape[0],
        'epochs_trained': len(history.history['loss']),
        'max_samples_per_class': MAX_SAMPLES_PER_CLASS,
        'model_architecture': 'Dense(256)->BN->Dense(128)->BN->Dense(64)->BN->Dense(32)->BN->Dense(16)->BN->Dense(16)',
        'optimizer': 'Adam(lr=0.0005)',
        'regularization': 'L2(0.0003) + BatchNorm + Dropout',
        'tfidf_config': {
            'ngram_range': '(1,3)',
            'min_df': 3,
            'max_df': 0.9,
            'sublinear_tf': True
        },
        'created_timestamp': time.time()
    }
    
    params_path = f'{assets_dir}/mbti_optimized_params.json'
    with open(params_path, 'w') as f:
        json.dump(preprocessing_params, f, indent=2)
    print(f"✓ Optimized model parameters saved: {params_path}")
    
    # Performance summary
    total_time = time.time() - start_time
    print(f"\\n{'='*70}")
    print(f"🎉 OPTIMIZED MBTI MODEL TRAINING COMPLETE! 🎉")
    print(f"{'='*70}")
    print(f"📊 Performance Metrics:")
    print(f"   • Test Accuracy: {test_accuracy:.2%}")
    print(f"   • Top-5 Accuracy: {top_5_acc:.2%}")
    print(f"   • Best Validation Accuracy: {best_val_acc:.2%}")
    print(f"   • Test Loss: {test_loss:.4f}")
    print(f"⏱️  Timing:")
    print(f"   • Total Time: {total_time:.1f} seconds")
    print(f"   • Training Time: {training_time:.1f} seconds")
    print(f"   • Speed: {X_train.shape[0]/training_time:.0f} samples/sec")
    print(f"📦 Model Files:")
    print(f"   • mbti_optimized_model.keras")
    print(f"   • mbti_optimized_model.tflite")  
    print(f"   • mbti_optimized_vectorizer.pickle")
    print(f"   • mbti_optimized_encoder.pickle")
    print(f"   • mbti_optimized_params.json")
    print(f"📁 Location: {assets_dir}/")
    
    if test_accuracy > 0.5:
        print(f"✅ EXCELLENT: Model achieved > 50% accuracy!")
    elif test_accuracy > 0.3:
        print(f"✅ GOOD: Model achieved > 30% accuracy!")
    else:
        print(f"⚠️  Model accuracy could be improved further")

if __name__ == "__main__":
    main()

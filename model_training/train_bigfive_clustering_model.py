import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score, silhouette_score
from sklearn.decomposition import PCA
import pickle
import json
import os
import hashlib
from pathlib import Path
import time
import matplotlib.pyplot as plt
import seaborn as sns
from collections import Counter

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

# Use CPU only for compatibility on M1 Mac
tf.config.set_visible_devices([], 'GPU')

# Cache directory for preprocessed data
CACHE_DIR = Path('../cache')
CACHE_DIR.mkdir(exist_ok=True)

def load_and_preprocess_bigfive_data(csv_path, use_full_dataset=False, max_samples=50000):
    """Load and preprocess the Big Five personality dataset"""
    print("Loading Big Five personality dataset...")
    
    # Create cache key based on configuration
    config_key = f"bigfive_{max_samples}"
    cache_key = hashlib.md5(f"{csv_path}_{config_key}_enhanced".encode()).hexdigest()
    cache_file = CACHE_DIR / f"bigfive_data_{cache_key}.pkl"
    
    # Try to load from cache
    if cache_file.exists():
        print("Loading preprocessed data from cache...")
        with open(cache_file, 'rb') as f:
            return pickle.load(f)
    
    # Load data with chunking for large files
    print("Reading CSV file (this may take a while for large files)...")
    
    # Big Five trait columns based on codebook
    ext_cols = [f'EXT{i}' for i in range(1, 11)]  # Extraversion
    est_cols = [f'EST{i}' for i in range(1, 11)]  # Emotional Stability (Neuroticism reversed)
    agr_cols = [f'AGR{i}' for i in range(1, 11)]  # Agreeableness
    csn_cols = [f'CSN{i}' for i in range(1, 11)]  # Conscientiousness
    opn_cols = [f'OPN{i}' for i in range(1, 11)]  # Openness
    
    # All personality trait columns
    personality_cols = ext_cols + est_cols + agr_cols + csn_cols + opn_cols
    
    # Additional useful columns that definitely exist
    other_cols = ['country', 'screenw', 'screenh', 'testelapse', 'IPC']
    
    # Read data efficiently
    try:
        # Read header first to check available columns - handle tab separation
        header_df = pd.read_csv(csv_path, nrows=0, sep='\t')
        available_cols = header_df.columns.tolist()
        print(f"Available columns in dataset: {len(available_cols)}")
        print(f"Sample columns: {available_cols[:10]}")
        
        # Filter to only use columns that actually exist
        personality_available = [col for col in personality_cols if col in available_cols]
        other_available = [col for col in other_cols if col in available_cols]
        
        print(f"Found {len(personality_available)} personality trait columns")
        print(f"Found {len(other_available)} demographic columns")
        
        if len(personality_available) < 10:  # Need at least some personality data
            raise ValueError(f"Insufficient personality data: only {len(personality_available)} columns found")
        
        # Read the actual data
        columns_to_use = personality_available + other_available
        print(f"Reading {len(columns_to_use)} columns from dataset...")
        df = pd.read_csv(csv_path, usecols=columns_to_use, nrows=max_samples if not use_full_dataset else None, sep='\t')
        
        # Debug: Print sample of columns that were actually read
        print(f"Successfully read data with columns: {df.columns.tolist()[:10]}{'...' if len(df.columns) > 10 else ''}")
        print(f"Data types: {df.dtypes.iloc[:5]}")
        
    except Exception as e:
        print(f"Error reading with specific columns: {e}")
        print("Falling back to reading all columns...")
        df = pd.read_csv(csv_path, nrows=max_samples if not use_full_dataset else None, sep='\t')
        
        # Filter to available columns
        personality_available = [col for col in personality_cols if col in df.columns]
        other_available = [col for col in other_cols if col in df.columns]
    
    print(f"Original dataset shape: {df.shape}")
    
    # Clean data
    print("Cleaning data...")
    
    # Remove rows with missing personality trait values
    if len(personality_available) > 0:
        df = df.dropna(subset=personality_available[:10])  # At least first 10 columns
    
    # Filter for quality responses (IPC = 1 for single submissions)
    if 'IPC' in df.columns:
        initial_size = len(df)
        df = df[df['IPC'] == 1]
        print(f"Filtered to single submissions: {initial_size} -> {len(df)} samples")
    
    # Remove outliers (responses outside 1-5 range) for personality columns
    for col in personality_available:
        if col in df.columns:
            df = df[(df[col] >= 1) & (df[col] <= 5)]
    
    print(f"After cleaning: {df.shape}")
    
    # Calculate Big Five scores based on codebook
    print("Calculating Big Five trait scores...")
    
    trait_scores = []  # Initialize empty list to collect trait scores
    
    # Extraversion (EXT2, EXT4, EXT6, EXT8, EXT10 are reverse scored)
    ext_available = [col for col in ext_cols if col in df.columns]
    if len(ext_available) >= 8:  # Need at least 8 out of 10 for reliable score
        ext_forward = [f'EXT{i}' for i in [1, 3, 5, 7, 9] if f'EXT{i}' in df.columns]
        ext_reverse = [f'EXT{i}' for i in [2, 4, 6, 8, 10] if f'EXT{i}' in df.columns]
        
        forward_sum = df[ext_forward].sum(axis=1) if ext_forward else 0
        reverse_sum = (6 - df[ext_reverse]).sum(axis=1) if ext_reverse else 0
        total_items = len(ext_forward) + len(ext_reverse)
        
        if total_items > 0:
            df['EXT_score'] = (forward_sum + reverse_sum) / total_items
            trait_scores.append('EXT_score')
            print(f"  Extraversion: {total_items} items used")
    
    # Emotional Stability (EST1, EST3, EST5, EST6, EST7, EST8, EST9, EST10 are reverse scored)
    est_available = [col for col in est_cols if col in df.columns]
    if len(est_available) >= 8:
        est_forward = [f'EST{i}' for i in [2, 4] if f'EST{i}' in df.columns]
        est_reverse = [f'EST{i}' for i in [1, 3, 5, 6, 7, 8, 9, 10] if f'EST{i}' in df.columns]
        
        forward_sum = df[est_forward].sum(axis=1) if est_forward else 0
        reverse_sum = (6 - df[est_reverse]).sum(axis=1) if est_reverse else 0
        total_items = len(est_forward) + len(est_reverse)
        
        if total_items > 0:
            df['EST_score'] = (forward_sum + reverse_sum) / total_items
            trait_scores.append('EST_score')
            print(f"  Emotional Stability: {total_items} items used")
    
    # Agreeableness (AGR1, AGR3, AGR5, AGR7 are reverse scored)
    agr_available = [col for col in agr_cols if col in df.columns]
    if len(agr_available) >= 8:
        agr_forward = [f'AGR{i}' for i in [2, 4, 6, 8, 9, 10] if f'AGR{i}' in df.columns]
        agr_reverse = [f'AGR{i}' for i in [1, 3, 5, 7] if f'AGR{i}' in df.columns]
        
        forward_sum = df[agr_forward].sum(axis=1) if agr_forward else 0
        reverse_sum = (6 - df[agr_reverse]).sum(axis=1) if agr_reverse else 0
        total_items = len(agr_forward) + len(agr_reverse)
        
        if total_items > 0:
            df['AGR_score'] = (forward_sum + reverse_sum) / total_items
            trait_scores.append('AGR_score')
            print(f"  Agreeableness: {total_items} items used")
    
    # Conscientiousness (CSN2, CSN4, CSN6, CSN8 are reverse scored)
    csn_available = [col for col in csn_cols if col in df.columns]
    if len(csn_available) >= 8:
        csn_forward = [f'CSN{i}' for i in [1, 3, 5, 7, 9, 10] if f'CSN{i}' in df.columns]
        csn_reverse = [f'CSN{i}' for i in [2, 4, 6, 8] if f'CSN{i}' in df.columns]
        
        forward_sum = df[csn_forward].sum(axis=1) if csn_forward else 0
        reverse_sum = (6 - df[csn_reverse]).sum(axis=1) if csn_reverse else 0
        total_items = len(csn_forward) + len(csn_reverse)
        
        if total_items > 0:
            df['CSN_score'] = (forward_sum + reverse_sum) / total_items
            trait_scores.append('CSN_score')
            print(f"  Conscientiousness: {total_items} items used")
    
    # Openness (OPN2, OPN4, OPN6 are reverse scored)
    opn_available = [col for col in opn_cols if col in df.columns]
    if len(opn_available) >= 8:
        opn_forward = [f'OPN{i}' for i in [1, 3, 5, 7, 8, 9, 10] if f'OPN{i}' in df.columns]
        opn_reverse = [f'OPN{i}' for i in [2, 4, 6] if f'OPN{i}' in df.columns]
        
        forward_sum = df[opn_forward].sum(axis=1) if opn_forward else 0
        reverse_sum = (6 - df[opn_reverse]).sum(axis=1) if opn_reverse else 0
        total_items = len(opn_forward) + len(opn_reverse)
        
        if total_items > 0:
            df['OPN_score'] = (forward_sum + reverse_sum) / total_items
            trait_scores.append('OPN_score')
            print(f"  Openness: {total_items} items used")
    
    # Create feature matrix for clustering
    if len(trait_scores) >= 3:  # Need at least 3 traits for meaningful clustering
        features = df[trait_scores].values
        feature_names = trait_scores
        print(f"Using calculated Big Five scores: {trait_scores}")
    else:
        print("Warning: Insufficient trait scores calculated. Using raw personality items.")
        # Use raw personality scores as fallback (first 25 items)
        fallback_cols = personality_available[:25]  # Use first 25 available personality items
        features = df[fallback_cols].values
        feature_names = fallback_cols
    
    print(f"Feature matrix shape: {features.shape}")
    print(f"Features: {feature_names}")
    
    # Add demographic features if available
    demo_features = []
    demo_names = []
    
    if 'screenw' in df.columns and 'screenh' in df.columns:
        # Screen resolution
        screen_ratio = df['screenw'] / (df['screenh'] + 1e-8)  # Avoid division by zero
        demo_features.append(screen_ratio.values.reshape(-1, 1))
        demo_names.append('screen_ratio')
    
    if 'testelapse' in df.columns:
        # Log transform test time to handle outliers
        test_time = np.log1p(df['testelapse'].values)
        demo_features.append(test_time.reshape(-1, 1))
        demo_names.append('log_test_time')
    
    if demo_features:
        demo_matrix = np.hstack(demo_features)
        # Normalize demographic features
        from sklearn.preprocessing import StandardScaler
        demo_scaler = StandardScaler()
        demo_matrix = demo_scaler.fit_transform(demo_matrix)
        features = np.hstack([features, demo_matrix])
        feature_names.extend(demo_names)
        print(f"Added {len(demo_names)} demographic features. New shape: {features.shape}")
    
    # Final validation
    if features.shape[1] == 0:
        raise ValueError("No valid features could be extracted from the dataset!")
    
    print("Caching preprocessed data...")
    with open(cache_file, 'wb') as f:
        pickle.dump((features, feature_names, df), f)
    
    return features, feature_names, df

def perform_kmeans_clustering(features, n_clusters_range=(3, 12), random_state=42):
    """Perform K-Means clustering with optimal cluster selection"""
    print("Performing K-Means clustering analysis...")
    
    # Standardize features for clustering
    scaler = StandardScaler()
    features_scaled = scaler.fit_transform(features)
    
    print(f"Scaled features shape: {features_scaled.shape}")
    print(f"Testing cluster range: {n_clusters_range[0]} to {n_clusters_range[1]}")
    
    # Test different numbers of clusters
    silhouette_scores = []
    inertias = []
    cluster_range = range(n_clusters_range[0], n_clusters_range[1] + 1)
    
    for n_clusters in cluster_range:
        print(f"Testing {n_clusters} clusters...")
        kmeans = KMeans(n_clusters=n_clusters, random_state=random_state, n_init=10, max_iter=300)
        cluster_labels = kmeans.fit_predict(features_scaled)
        
        # Calculate silhouette score
        sil_score = silhouette_score(features_scaled, cluster_labels)
        silhouette_scores.append(sil_score)
        inertias.append(kmeans.inertia_)
        
        print(f"  Silhouette score: {sil_score:.4f}")
        print(f"  Inertia: {kmeans.inertia_:.2f}")
    
    # Find optimal number of clusters
    optimal_idx = np.argmax(silhouette_scores)
    optimal_clusters = cluster_range[optimal_idx]
    optimal_silhouette = silhouette_scores[optimal_idx]
    
    print(f"\nOptimal number of clusters: {optimal_clusters}")
    print(f"Best silhouette score: {optimal_silhouette:.4f}")
    
    # Fit final model with optimal clusters
    print(f"Fitting final K-Means model with {optimal_clusters} clusters...")
    final_kmeans = KMeans(n_clusters=optimal_clusters, random_state=random_state, n_init=20, max_iter=500)
    final_labels = final_kmeans.fit_predict(features_scaled)
    
    # Analyze cluster characteristics
    print("\nCluster Analysis:")
    for i in range(optimal_clusters):
        cluster_size = np.sum(final_labels == i)
        cluster_pct = cluster_size / len(final_labels) * 100
        print(f"Cluster {i}: {cluster_size} samples ({cluster_pct:.1f}%)")
    
    return final_kmeans, scaler, final_labels, {
        'optimal_clusters': optimal_clusters,
        'silhouette_score': optimal_silhouette,
        'silhouette_scores': silhouette_scores,
        'inertias': inertias,
        'cluster_range': list(cluster_range)
    }

def create_personality_classifier(features, cluster_labels, input_dim, num_clusters):
    """Create a neural network to predict personality clusters"""
    print(f"Creating personality cluster classifier...")
    print(f"Input dimension: {input_dim}, Number of clusters: {num_clusters}")
    
    # Create a deep learning model for cluster prediction
    model = tf.keras.Sequential([
        # Input layer
        tf.keras.layers.Dense(128, activation='relu', input_shape=(input_dim,),
                             kernel_regularizer=tf.keras.regularizers.l2(0.001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        # Hidden layer 1
        tf.keras.layers.Dense(64, activation='relu',
                             kernel_regularizer=tf.keras.regularizers.l2(0.001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        # Hidden layer 2
        tf.keras.layers.Dense(32, activation='relu',
                             kernel_regularizer=tf.keras.regularizers.l2(0.001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        
        # Output layer
        tf.keras.layers.Dense(num_clusters, activation='softmax')
    ])
    
    # Compile model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def create_personality_type_labels(cluster_labels, features, feature_names):
    """Create interpretable personality type labels based on cluster characteristics"""
    print("Creating personality type labels...")
    
    n_clusters = len(np.unique(cluster_labels))
    personality_types = []
    
    # Analyze each cluster's characteristics
    for cluster_id in range(n_clusters):
        cluster_mask = cluster_labels == cluster_id
        cluster_features = features[cluster_mask]
        
        # Calculate mean scores for this cluster
        mean_scores = np.mean(cluster_features[:, :5], axis=0)  # First 5 are Big Five scores
        
        # Create personality type name based on dominant traits
        trait_names = ['Extraverted', 'Stable', 'Agreeable', 'Conscientious', 'Open']
        trait_opposites = ['Introverted', 'Neurotic', 'Competitive', 'Flexible', 'Traditional']
        
        # Find dominant traits (above median)
        median_score = 3.0  # Middle of 1-5 scale
        dominant_traits = []
        
        for i, (score, pos_trait, neg_trait) in enumerate(zip(mean_scores, trait_names, trait_opposites)):
            if score > median_score + 0.3:  # Significantly above median
                dominant_traits.append(pos_trait)
            elif score < median_score - 0.3:  # Significantly below median
                dominant_traits.append(neg_trait)
        
        # Create personality type name
        if len(dominant_traits) >= 2:
            personality_type = f"{dominant_traits[0]} {dominant_traits[1]}"
        elif len(dominant_traits) == 1:
            personality_type = f"{dominant_traits[0]} Type"
        else:
            personality_type = f"Balanced Type {cluster_id + 1}"
        
        personality_types.append(personality_type)
        
        print(f"Cluster {cluster_id}: {personality_type}")
        print(f"  Extraversion: {mean_scores[0]:.2f}")
        print(f"  Emotional Stability: {mean_scores[1]:.2f}")
        print(f"  Agreeableness: {mean_scores[2]:.2f}")
        print(f"  Conscientiousness: {mean_scores[3]:.2f}")
        print(f"  Openness: {mean_scores[4]:.2f}")
        print()
    
    return personality_types

def main():
    start_time = time.time()
    
    # Configuration
    MAX_SAMPLES = 100000  # Limit for faster processing
    BATCH_SIZE = 128
    EPOCHS = 50
    N_CLUSTERS_RANGE = (5, 10)  # Test 5-10 clusters
    
    print("=== Big Five Personality Clustering Model (K-Means + Deep Learning) ===")
    print(f"Configuration:")
    print(f"  • Max Samples: {MAX_SAMPLES}")
    print(f"  • Batch Size: {BATCH_SIZE}")
    print(f"  • Epochs: {EPOCHS}")
    print(f"  • Cluster Range: {N_CLUSTERS_RANGE}")
    
    # Load and preprocess data
    csv_path = '../lib/data/data-final.csv'
    if not os.path.exists(csv_path):
        print(f"Error: Dataset file not found at {csv_path}")
        print("Please ensure the Big Five dataset is available.")
        return
    
    features, feature_names, df = load_and_preprocess_bigfive_data(
        csv_path,
        use_full_dataset=False,
        max_samples=MAX_SAMPLES
    )
    
    print(f"\nDataset summary:")
    print(f"  • Total samples: {features.shape[0]}")
    print(f"  • Features: {features.shape[1]}")
    print(f"  • Feature names: {feature_names}")
    
    # Perform K-Means clustering
    kmeans_model, scaler, cluster_labels, cluster_info = perform_kmeans_clustering(
        features, n_clusters_range=N_CLUSTERS_RANGE
    )
    
    optimal_clusters = cluster_info['optimal_clusters']
    
    # Create personality type labels
    personality_types = create_personality_type_labels(cluster_labels, features, feature_names)
    
    # Prepare data for neural network training
    X_scaled = scaler.transform(features)
    y_clusters = cluster_labels
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y_clusters,
        test_size=0.2,
        random_state=42,
        stratify=y_clusters
    )
    
    X_train, X_val, y_train, y_val = train_test_split(
        X_train, y_train,
        test_size=0.2,
        random_state=42,
        stratify=y_train
    )
    
    print(f"\nDataset split:")
    print(f"  • Training samples: {X_train.shape[0]}")
    print(f"  • Validation samples: {X_val.shape[0]}")
    print(f"  • Test samples: {X_test.shape[0]}")
    
    # Create and train neural network classifier
    model = create_personality_classifier(features, cluster_labels, X_train.shape[1], optimal_clusters)
    
    print(f"\nModel architecture:")
    model.summary()
    
    # Training callbacks
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy',
            patience=15,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=7,
            min_lr=0.00001,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath='../cache/best_bigfive_clustering_model.keras',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Train model
    print(f"\nTraining neural network classifier...")
    training_start = time.time()
    
    history = model.fit(
        X_train, y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_val, y_val),
        callbacks=callbacks,
        verbose=1
    )
    
    training_time = time.time() - training_start
    print(f"\nTraining completed in {training_time:.2f} seconds")
    
    # Evaluate model
    print(f"\nEvaluating model...")
    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test accuracy: {test_accuracy:.4f} ({test_accuracy:.2%})")
    print(f"Test loss: {test_loss:.4f}")
    
    # Generate predictions
    y_pred = model.predict(X_test, verbose=0)
    y_pred_classes = np.argmax(y_pred, axis=1)
    
    # Classification report
    print(f"\nClassification Report:")
    report = classification_report(
        y_test,
        y_pred_classes,
        target_names=personality_types,
        digits=3
    )
    print(report)
    
    # Save all model artifacts
    print(f"\nSaving model and artifacts...")
    
    # Create assets directory
    assets_dir = '../assets/models'
    os.makedirs(assets_dir, exist_ok=True)
    
    # Save Keras model
    model_path = f'{assets_dir}/bigfive_clustering_model.keras'
    model.save(model_path)
    print(f"✓ Keras model saved: {model_path}")
    
    # Convert to TensorFlow Lite
    print("Converting to TensorFlow Lite...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        
        tflite_model = converter.convert()
        
        tflite_path = f'{assets_dir}/bigfive_clustering_model.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        tflite_size = len(tflite_model) / 1024  # KB
        print(f"✓ TensorFlow Lite model saved: {tflite_path}")
        print(f"✓ TensorFlow Lite model size: {tflite_size:.1f} KB")
        
    except Exception as e:
        print(f"Warning: TensorFlow Lite conversion failed: {e}")
    
    # Save K-Means model and scaler
    kmeans_path = f'{assets_dir}/bigfive_kmeans_model.pickle'
    with open(kmeans_path, 'wb') as f:
        pickle.dump(kmeans_model, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ K-Means model saved: {kmeans_path}")
    
    scaler_path = f'{assets_dir}/bigfive_scaler.pickle'
    with open(scaler_path, 'wb') as f:
        pickle.dump(scaler, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ Feature scaler saved: {scaler_path}")
    
    # Save personality type labels
    labels_path = f'{assets_dir}/bigfive_personality_types.pickle'
    with open(labels_path, 'wb') as f:
        pickle.dump(personality_types, f, protocol=pickle.HIGHEST_PROTOCOL)
    print(f"✓ Personality type labels saved: {labels_path}")
    
    # Save comprehensive parameters
    best_epoch = np.argmax(history.history['val_accuracy']) + 1
    best_val_acc = np.max(history.history['val_accuracy'])
    
    model_params = {
        'model_type': 'bigfive_clustering_tensorflow',
        'clustering_method': 'kmeans',
        'optimal_clusters': optimal_clusters,
        'silhouette_score': float(cluster_info['silhouette_score']),
        'input_dim': int(X_train.shape[1]),
        'num_clusters': optimal_clusters,
        'personality_types': personality_types,
        'feature_names': feature_names,
        'test_accuracy': float(test_accuracy),
        'test_loss': float(test_loss),
        'best_val_accuracy': float(best_val_acc),
        'best_epoch': int(best_epoch),
        'training_time_seconds': training_time,
        'total_samples': len(features),
        'train_samples': X_train.shape[0],
        'test_samples': X_test.shape[0],
        'epochs_trained': len(history.history['loss']),
        'max_samples': MAX_SAMPLES,
        'model_architecture': 'Dense(128)->BN->Dense(64)->BN->Dense(32)->BN->Softmax',
        'optimizer': 'Adam(lr=0.001)',
        'regularization': 'L2(0.001) + BatchNorm + Dropout',
        'cluster_analysis': cluster_info,
        'created_timestamp': time.time()
    }
    
    params_path = f'{assets_dir}/bigfive_clustering_params.json'
    with open(params_path, 'w') as f:
        json.dump(model_params, f, indent=2)
    print(f"✓ Model parameters saved: {params_path}")
    
    # Performance summary
    total_time = time.time() - start_time
    print(f"\n{'='*70}")
    print(f"🎉 BIG FIVE CLUSTERING MODEL TRAINING COMPLETE! 🎉")
    print(f"{'='*70}")
    print(f"📊 Performance Metrics:")
    print(f"   • Test Accuracy: {test_accuracy:.2%}")
    print(f"   • Best Validation Accuracy: {best_val_acc:.2%}")
    print(f"   • Silhouette Score: {cluster_info['silhouette_score']:.4f}")
    print(f"   • Optimal Clusters: {optimal_clusters}")
    print(f"⏱️  Timing:")
    print(f"   • Total Time: {total_time:.1f} seconds")
    print(f"   • Training Time: {training_time:.1f} seconds")
    print(f"   • Speed: {X_train.shape[0]/training_time:.0f} samples/sec")
    print(f"📦 Model Files:")
    print(f"   • bigfive_clustering_model.keras")
    print(f"   • bigfive_clustering_model.tflite")  
    print(f"   • bigfive_kmeans_model.pickle")
    print(f"   • bigfive_scaler.pickle")
    print(f"   • bigfive_personality_types.pickle")
    print(f"   • bigfive_clustering_params.json")
    print(f"📁 Location: {assets_dir}/")
    print(f"\n🎭 Discovered Personality Types:")
    for i, ptype in enumerate(personality_types):
        print(f"   {i+1}. {ptype}")
    
    if test_accuracy > 0.7:
        print(f"✅ EXCELLENT: Model achieved > 70% accuracy!")
    elif test_accuracy > 0.5:
        print(f"✅ GOOD: Model achieved > 50% accuracy!")
    else:
        print(f"⚠️  Model accuracy could be improved further")

if __name__ == "__main__":
    main()

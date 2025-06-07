import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import os

# Load the dataset
df = pd.read_csv('../lib/data/personality_dataset.csv')

print("Dataset shape:", df.shape)
print("\nDataset info:")
print(df.info())
print("\nMissing values:")
print(df.isnull().sum())

# Handle missing values
df = df.dropna()

# Encode categorical variables
label_encoders = {}

# Encode Yes/No columns
yes_no_columns = ['Stage_fear', 'Drained_after_socializing']
for col in yes_no_columns:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    label_encoders[col] = le

# Encode target variable
target_encoder = LabelEncoder()
df['Personality'] = target_encoder.fit_transform(df['Personality'])
label_encoders['Personality'] = target_encoder

print("\nLabel encodings:")
for col, encoder in label_encoders.items():
    print(f"{col}: {dict(zip(encoder.classes_, encoder.transform(encoder.classes_)))}")

# Prepare features and target
feature_columns = ['Time_spent_Alone', 'Stage_fear', 'Social_event_attendance', 
                  'Going_outside', 'Drained_after_socializing', 'Friends_circle_size', 
                  'Post_frequency']

X = df[feature_columns].values
y = df['Personality'].values

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# Scale the features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print(f"\nTraining set shape: {X_train_scaled.shape}")
print(f"Test set shape: {X_test_scaled.shape}")
print(f"Class distribution in training set: {np.bincount(y_train)}")

# Create the TensorFlow model
model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(7,)),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])

model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy']
)

print("\nModel summary:")
model.summary()

# Train the model
history = model.fit(
    X_train_scaled, y_train,
    epochs=100,
    batch_size=32,
    validation_split=0.2,
    verbose=1
)

# Evaluate the model
test_loss, test_accuracy = model.evaluate(X_test_scaled, y_test, verbose=0)
print(f"\nTest accuracy: {test_accuracy:.4f}")

# Make predictions
y_pred_proba = model.predict(X_test_scaled)
y_pred = (y_pred_proba > 0.5).astype(int).flatten()

print("\nClassification Report:")
print(classification_report(y_test, y_pred, target_names=target_encoder.classes_))

# Save the model
os.makedirs('../assets/models', exist_ok=True)
model.save('../assets/models/personality_model.h5')

# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save TensorFlow Lite model
with open('../assets/models/personality_model.tflite', 'wb') as f:
    f.write(tflite_model)

# Save preprocessing parameters
import json
preprocessing_params = {
    'scaler_mean': scaler.mean_.tolist(),
    'scaler_scale': scaler.scale_.tolist(),
    'feature_columns': feature_columns,
    'label_encoders': {
        'Stage_fear': {'No': 0, 'Yes': 1},
        'Drained_after_socializing': {'No': 0, 'Yes': 1},
        'Personality': {'Extrovert': 0, 'Introvert': 1}
    }
}

with open('../assets/models/preprocessing_params.json', 'w') as f:
    json.dump(preprocessing_params, f, indent=2)

print("\nModel saved successfully!")
print("Files created:")
print("- personality_model.h5")
print("- personality_model.tflite")
print("- preprocessing_params.json")

# Test the TensorFlow Lite model
interpreter = tf.lite.Interpreter(model_path='../assets/models/personality_model.tflite')
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test with a sample
sample_input = X_test_scaled[0:1].astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], sample_input)
interpreter.invoke()
tflite_prediction = interpreter.get_tensor(output_details[0]['index'])

print(f"\nTensorFlow Lite model test:")
print(f"Original prediction: {y_pred_proba[0][0]:.4f}")
print(f"TFLite prediction: {tflite_prediction[0][0]:.4f}")
print("TensorFlow Lite model is working correctly!")

# Personify - AI-Powered Personality Test App

A beautiful Flutter application that uses machine learning to determine personality types (Introvert vs Extrovert) based on user responses to psychological questions.

## Features

- **AI-Powered Analysis**: Uses TensorFlow Lite model trained on personality data
- **Beautiful UI/UX**: Modern, animated interface with smooth transitions
- **Multiple Screens**: Welcome screen, interactive test, and detailed results
- **Real-time Progress**: Visual progress tracking during the test
- **Detailed Results**: Confidence scores, descriptions, and personality traits
- **Cross-platform**: Runs on iOS and Android

## Technologies Used

- **Flutter**: Cross-platform mobile app framework
- **TensorFlow Lite**: On-device machine learning inference
- **Provider**: State management
- **Go Router**: Navigation and routing
- **Google Fonts**: Beautiful typography
- **Animated Text Kit**: Text animations
- **Staggered Animations**: Smooth UI transitions

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── models/                   # Data models
│   ├── personality_question.dart
│   └── personality_result.dart
├── providers/                # State management
│   └── personality_provider.dart
├── screens/                  # UI screens
│   ├── welcome_screen.dart
│   ├── personality_test_screen.dart
│   └── results_screen.dart
├── services/                 # Business logic
│   └── ml_service.dart
└── widgets/                  # Reusable UI components
    ├── animated_button.dart
    ├── gradient_background.dart
    ├── question_card.dart
    ├── result_card.dart
    └── trait_chip.dart

assets/
└── models/                   # ML model files
    ├── personality_model.tflite
    └── preprocessing_params.json

model_training/               # Python ML training scripts
└── train_personality_model.py
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / Xcode for mobile development
- Python 3.x (for model training)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd personify
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Model Training (Optional)

If you want to retrain the model with your own data:

1. **Install Python dependencies**
   ```bash
   pip install tensorflow pandas scikit-learn numpy
   ```

2. **Train the model**
   ```bash
   cd model_training
   python train_personality_model.py
   ```

3. **Copy new model files to assets**
   ```bash
   cp personality_model.tflite ../assets/models/
   cp preprocessing_params.json ../assets/models/
   ```

## How It Works

### Data Collection
The app asks users 7 key questions about their personality traits:
- Time spent alone preferences
- Stage fear levels
- Social event attendance
- Outdoor activity preferences
- Energy after socializing
- Preferred friend circle size
- Social media posting frequency

### Machine Learning Model
- **Architecture**: Neural network with dense layers (64→32→16→1)
- **Training**: Achieved 91.3% accuracy on personality classification
- **Features**: 7 normalized input features
- **Output**: Binary classification (Introvert vs Extrovert) with confidence score

### Mobile Integration
- **TensorFlow Lite**: Optimized model for mobile inference
- **Preprocessing**: Real-time feature scaling and normalization
- **Results**: Detailed personality analysis with traits and descriptions

## App Screens

### 1. Welcome Screen
- Animated app introduction
- Feature highlights
- Beautiful gradient background
- "Start Test" call-to-action

### 2. Personality Test
- 7 interactive questions
- Visual progress indicator
- Smooth transitions between questions
- Answer selection with immediate feedback

### 3. Results Screen
- Personality type announcement
- Confidence score visualization
- Detailed description
- Key personality traits
- Option to retake test

## Performance & Optimization

- **Model Size**: ~50KB TensorFlow Lite model
- **Inference Time**: <100ms on average mobile device
- **Memory Usage**: Minimal memory footprint
- **Animations**: 60fps smooth animations with proper disposal

## Testing

Run the test suite:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Personality dataset for training the ML model
- Flutter community for excellent packages
- TensorFlow team for mobile ML capabilities
# personify

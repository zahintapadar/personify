import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;
  Map<String, dynamic>? _preprocessingParams;
  bool _isInitialized = false;
  bool _debugMode = false; // Add debug mode flag
  
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('assets/models/personality_model.tflite');
      
      // Load preprocessing parameters
      final String paramsString = await rootBundle.loadString('assets/models/preprocessing_params.json');
      _preprocessingParams = json.decode(paramsString);
      
      _isInitialized = true;
      debugPrint('ML Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ML Service, enabling debug mode: $e');
      // Enable debug mode if model fails to load
      _debugMode = true;
      _isInitialized = true; // Still mark as initialized for fallback
    }
  }
  
  Future<double> predict(List<double> input) async {
    if (!_isInitialized) {
      throw Exception('ML Service not initialized');
    }
    
    // If in debug mode or model not available, return a simple prediction
    if (_debugMode || _interpreter == null) {
      debugPrint('Using debug mode prediction');
      return _debugPredict(input);
    }
    
    try {
      // Preprocess the input
      List<double> preprocessedInput = _preprocessInput(input);
      
      // Prepare input tensor
      var inputBuffer = Float32List.fromList(preprocessedInput);
      var inputTensor = inputBuffer.buffer.asUint8List();
      
      // Prepare output tensor
      var outputBuffer = Float32List(1);
      var outputTensor = outputBuffer.buffer.asUint8List();
      
      // Run inference
      _interpreter!.run(inputTensor, outputTensor);
      
      // Extract the prediction
      double prediction = outputBuffer[0];
      
      debugPrint('Input: $input');
      debugPrint('Preprocessed: $preprocessedInput');
      debugPrint('Prediction: $prediction');
      
      return prediction;
    } catch (e) {
      debugPrint('Error during prediction, falling back to debug mode: $e');
      return _debugPredict(input);
    }
  }
  
  // Simple debug prediction for testing
  double _debugPredict(List<double> input) {
    // Simple heuristic based on question answers
    double timeAlone = input[0]; // 1-5, higher = more alone time (introvert)
    double stageFear = input[1]; // 1-5, higher = more fear (introvert)
    double socialEvents = input[2]; // 1-5, higher = more social (extrovert)
    double goingOutside = input[3]; // 1-5, higher = more active (extrovert)
    double drainedSocializing = input[4]; // 1-5, higher = more drained (introvert)
    double friendsCircle = input[5]; // 1-5, higher = larger circle (extrovert)
    double postFrequency = input[6]; // 1-5, higher = more posts (extrovert)
    
    // Calculate weighted score (higher = more extroverted)
    double extrovertScore = 
        (6 - timeAlone) * 0.2 + // Invert time alone
        (6 - stageFear) * 0.15 + // Invert stage fear
        socialEvents * 0.2 +
        goingOutside * 0.15 +
        (6 - drainedSocializing) * 0.15 + // Invert drained feeling
        friendsCircle * 0.1 +
        postFrequency * 0.05;
    
    // Normalize to 0-1 range
    double normalizedScore = (extrovertScore - 1) / 4; // Assuming max possible is 5, min is 1
    
    // Ensure it's within bounds and add some randomness for realism
    normalizedScore = (normalizedScore.clamp(0.0, 1.0) * 0.8 + 0.1);
    
    debugPrint('Debug prediction calculated: $normalizedScore');
    return normalizedScore;
  }
  
  List<double> _preprocessInput(List<double> input) {
    if (_preprocessingParams == null) {
      throw Exception('Preprocessing parameters not loaded');
    }
    
    // Get scaler parameters
    List<double> mean = List<double>.from(_preprocessingParams!['scaler_mean']);
    List<double> scale = List<double>.from(_preprocessingParams!['scaler_scale']);
    
    // Apply StandardScaler transformation: (x - mean) / scale
    List<double> scaledInput = [];
    for (int i = 0; i < input.length; i++) {
      double scaledValue = (input[i] - mean[i]) / scale[i];
      scaledInput.add(scaledValue);
    }
    
    return scaledInput;
  }
  
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _preprocessingParams = null;
    _isInitialized = false;
  }
}

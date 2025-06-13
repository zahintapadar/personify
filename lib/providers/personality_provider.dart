import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/personality_question.dart';
import '../models/personality_result.dart';
import '../services/ml_service.dart';
import '../services/google_forms_service.dart';

class PersonalityProvider extends ChangeNotifier {
  final MLService _mlService = MLService();
  
  // Test state
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isTestCompleted = false;
  PersonalityResult? _result;
  bool _isLoading = false;
  
  // History state
  List<PersonalityResult> _testHistory = [];
  static const String _historyKey = 'personality_test_history';
  
  // Questions for the personality test
  final List<PersonalityQuestion> _questions = [
    PersonalityQuestion(
      id: 'time_alone',
      title: 'Time Spent Alone',
      question: 'How much time do you prefer to spend alone?',
      options: ['Very little', 'Some time', 'Moderate amount', 'Quite a bit', 'A lot'],
      values: [1, 2, 3, 4, 5],
    ),
    PersonalityQuestion(
      id: 'stage_fear',
      title: 'Stage Fear',
      question: 'How comfortable are you speaking in front of groups?',
      options: ['Very comfortable', 'Somewhat comfortable', 'Neutral', 'Somewhat uncomfortable', 'Very uncomfortable'],
      values: [1, 2, 3, 4, 5],
    ),
    PersonalityQuestion(
      id: 'social_events',
      title: 'Social Event Attendance',
      question: 'How often do you attend social events?',
      options: ['Always', 'Often', 'Sometimes', 'Rarely', 'Never'],
      values: [5, 4, 3, 2, 1],
    ),
    PersonalityQuestion(
      id: 'going_outside',
      title: 'Going Outside',
      question: 'How often do you enjoy going outside and being active?',
      options: ['Always', 'Often', 'Sometimes', 'Rarely', 'Never'],
      values: [5, 4, 3, 2, 1],
    ),
    PersonalityQuestion(
      id: 'drained_socializing',
      title: 'Energy After Socializing',
      question: 'How do you feel after socializing for a long time?',
      options: ['Energized', 'Slightly energized', 'Neutral', 'Slightly drained', 'Very drained'],
      values: [1, 2, 3, 4, 5],
    ),
    PersonalityQuestion(
      id: 'friends_circle',
      title: 'Friends Circle Size',
      question: 'How would you describe your ideal friends circle?',
      options: ['Very large', 'Large', 'Medium', 'Small', 'Very small'],
      values: [5, 4, 3, 2, 1],
    ),
    PersonalityQuestion(
      id: 'post_frequency',
      title: 'Social Media Posting',
      question: 'How often do you post on social media?',
      options: ['Very frequently', 'Frequently', 'Sometimes', 'Rarely', 'Never'],
      values: [5, 4, 3, 2, 1],
    ),
  ];
  
  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get answers => _answers;
  bool get isTestCompleted => _isTestCompleted;
  PersonalityResult? get result => _result;
  bool get isLoading => _isLoading;
  List<PersonalityQuestion> get questions => _questions;
  PersonalityQuestion get currentQuestion => _questions[_currentQuestionIndex];
  double get progress => (_currentQuestionIndex + 1) / _questions.length;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;
  List<PersonalityResult> get testHistory => _testHistory;
  
  // Get ML service status
  bool get isMLServiceReady => _mlService.isInitialized;
  String get mlServiceStatus => _mlService.isInitialized ? 'Ready' : 'Not Available';
  
  // Initialize ML service
  Future<void> initializeML() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Initializing ML service...');
      await _mlService.initialize();
      await _loadTestHistory(); // Load saved history
      debugPrint('ML Service initialization completed. Status: ${_mlService.isInitialized}');
    } catch (e) {
      debugPrint('Error initializing ML service: $e');
      // Continue without ML service - fallback algorithm will be used
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Manually retry ML service initialization
  Future<bool> retryMLInitialization() async {
    try {
      debugPrint('Retrying ML service initialization...');
      await _mlService.initialize();
      debugPrint('ML Service retry completed. Status: ${_mlService.isInitialized}');
      notifyListeners();
      return _mlService.isInitialized;
    } catch (e) {
      debugPrint('ML service retry failed: $e');
      return false;
    }
  }
  
  // Answer a question
  void answerQuestion(String questionId, int value) {
    _answers[questionId] = value;
    notifyListeners();
  }
  
  // Navigate to next question
  void nextQuestion() {
    if (hasNextQuestion && _currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }
  
  // Navigate to previous question
  void previousQuestion() {
    if (hasPreviousQuestion && _currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }
  
  // Complete the test and get results
  Future<void> completeTest() async {
    if (_answers.length != _questions.length) {
      throw Exception('Please answer all questions before completing the test.');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Prepare input for ML model (all values should be 1-5 scale)
      List<double> input = [
        _answers['time_alone']?.toDouble() ?? 0.0,
        _answers['stage_fear']?.toDouble() ?? 0.0,
        _answers['social_events']?.toDouble() ?? 0.0,
        _answers['going_outside']?.toDouble() ?? 0.0,
        _answers['drained_socializing']?.toDouble() ?? 0.0,
        _answers['friends_circle']?.toDouble() ?? 0.0,
        _answers['post_frequency']?.toDouble() ?? 0.0,
      ];
      
      debugPrint('Processing personality test with input: $input');
      
      double prediction;
      String predictionSource = 'ML Model';
      
      // Try to get prediction from ML model
      if (_mlService.isInitialized) {
        try {
          debugPrint('Attempting ML prediction...');
          prediction = await _mlService.predict(input);
          debugPrint('ML prediction successful: $prediction');
        } catch (e) {
          debugPrint('ML prediction failed, using fallback: $e');
          prediction = _calculateFallbackPrediction(input);
          predictionSource = 'Fallback Algorithm';
        }
      } else {
        debugPrint('ML service not initialized, using fallback prediction');
        prediction = _calculateFallbackPrediction(input);
        predictionSource = 'Fallback Algorithm';
      }
      
      // Determine personality type and confidence
      String personalityType = prediction > 0.5 ? 'Extrovert' : 'Introvert';
      double confidence = prediction > 0.5 ? prediction : (1 - prediction);
      
      debugPrint('Final prediction: $prediction, Type: $personalityType, Confidence: ${(confidence * 100).toInt()}%, Source: $predictionSource');
      
      // Create result
      _result = PersonalityResult(
        personalityType: personalityType,
        confidence: confidence,
        description: _getPersonalityDescription(personalityType),
        traits: _getPersonalityTraits(personalityType),
        strengths: _getPersonalityStrengths(personalityType),
        tips: _getPersonalityTips(personalityType),
        answers: Map.from(_answers),
      );
      
      _isTestCompleted = true;
      
      // Save to history
      await _saveTestToHistory(_result!);
      
      // Submit to Google Forms (non-blocking)
      _submitToGoogleForms(_result!, _answers);
      
      debugPrint('Test completed successfully and saved to history');
    } catch (e) {
      debugPrint('Error completing test: $e');
      rethrow;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Load test history from SharedPreferences
  Future<void> _loadTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        _testHistory = historyList
            .map((json) => PersonalityResult.fromJson(json))
            .toList();
        debugPrint('Loaded ${_testHistory.length} test results from history');
      }
    } catch (e) {
      debugPrint('Error loading test history: $e');
      _testHistory = [];
    }
  }
  
  // Save test result to history
  Future<void> _saveTestToHistory(PersonalityResult result) async {
    try {
      // Add current test result with timestamp
      final resultWithTimestamp = PersonalityResult(
        personalityType: result.personalityType,
        confidence: result.confidence,
        description: result.description,
        traits: result.traits,
        strengths: result.strengths,
        tips: result.tips,
        answers: result.answers,
        timestamp: DateTime.now(), // Add timestamp
      );
      
      _testHistory.insert(0, resultWithTimestamp); // Add to beginning
      
      // Keep only last 10 results
      if (_testHistory.length > 10) {
        _testHistory = _testHistory.take(10).toList();
      }
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_testHistory.map((r) => r.toJson()).toList());
      await prefs.setString(_historyKey, historyJson);
      
      debugPrint('Saved test result to history. Total results: ${_testHistory.length}');
    } catch (e) {
      debugPrint('Error saving test to history: $e');
    }
  }
  
  // Clear test history
  Future<void> clearTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _testHistory.clear();
      notifyListeners();
      debugPrint('Test history cleared');
    } catch (e) {
      debugPrint('Error clearing test history: $e');
    }
  }

  // Submit results to Google Forms (non-blocking)
  void _submitToGoogleForms(PersonalityResult result, Map<String, dynamic> answers) {
    // Run submission in background without blocking UI
    GoogleFormsService.submitTestResults(
      result: result,
      answers: answers,
      questions: _questions, // Pass questions for option text mapping
    ).then((success) {
      if (success) {
        debugPrint('Successfully submitted test results to Google Forms');
      } else {
        debugPrint('Failed to submit test results to Google Forms');
      }
    }).catchError((error) {
      debugPrint('Error submitting to Google Forms: $error');
    });
  }
  
  // Set a historical result as current (for viewing details)
  void setHistoricalResult(PersonalityResult result) {
    _result = result;
    _isTestCompleted = true;
    notifyListeners();
  }
  
  // Fallback prediction when ML model is not available
  double _calculateFallbackPrediction(List<double> input) {
    // Simple heuristic based on question answers
    // All values are on 1-5 scale, consistent with ML service expectations
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
    
    // Ensure it's within bounds and add slight variance for realism
    normalizedScore = (normalizedScore.clamp(0.0, 1.0) * 0.8 + 0.1);
    
    debugPrint('Fallback prediction calculated: $normalizedScore for input: $input');
    return normalizedScore;
  }
  
  // Reset the test
  void resetTest() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _isTestCompleted = false;
    _result = null;
    notifyListeners();
  }
  
  // Get personality description
  String _getPersonalityDescription(String personalityType) {
    if (personalityType == 'Extrovert') {
      return 'You are energized by social interactions and tend to be outgoing, talkative, and assertive. You enjoy being around people and often seek out social situations.';
    } else {
      return 'You are energized by solitude and tend to be reflective, reserved, and thoughtful. You prefer smaller groups and often enjoy quiet activities.';
    }
  }
  
  // Get personality traits
  List<String> _getPersonalityTraits(String personalityType) {
    if (personalityType == 'Extrovert') {
      return [
        'Outgoing and sociable',
        'Energized by social interactions',
        'Enjoys being the center of attention',
        'Thinks out loud',
        'Acts first, thinks later',
        'Prefers variety and action',
      ];
    } else {
      return [
        'Reflective and reserved',
        'Energized by solitude',
        'Prefers one-on-one conversations',
        'Thinks before speaking',
        'Thinks first, acts later',
        'Prefers depth over breadth',
      ];
    }
  }
  
  // Get personality strengths
  List<String> _getPersonalityStrengths(String personalityType) {
    if (personalityType == 'Extrovert') {
      return [
        'Natural leader and motivator',
        'Excellent at networking and building relationships',
        'Quick decision-making abilities',
        'Comfortable with public speaking',
        'Adaptable to new situations',
        'Great at energizing teams',
      ];
    } else {
      return [
        'Deep thinking and analytical skills',
        'Excellent listener and observer',
        'Strong focus and concentration',
        'Thoughtful decision-making',
        'Independent problem-solving',
        'Calm under pressure',
      ];
    }
  }
  
  // Get personality tips
  List<String> _getPersonalityTips(String personalityType) {
    if (personalityType == 'Extrovert') {
      return [
        'Take time for self-reflection and quiet moments',
        'Practice active listening in conversations',
        'Consider others\' need for processing time',
        'Balance social activities with downtime',
        'Think before making important decisions',
        'Respect introverted colleagues\' working styles',
      ];
    } else {
      return [
        'Push yourself to participate in group discussions',
        'Practice expressing ideas before they\'re perfect',
        'Schedule regular social interactions',
        'Share your insights and expertise with others',
        'Take on small leadership opportunities',
        'Build one meaningful relationship at a time',
      ];
    }
  }
  
  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}

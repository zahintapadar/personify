import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bigfive_personality_question.dart';
import '../models/bigfive_personality_result.dart';
import '../services/bigfive_ml_service.dart';

class BigFivePersonalityProvider extends ChangeNotifier {
  final BigFiveMLService _mlService = BigFiveMLService();
  
  List<BigFivePersonalityQuestion> _questions = [];
  final Map<String, int> _answers = {};
  int _currentQuestionIndex = 0;
  BigFivePersonalityResult? _result;
  List<BigFivePersonalityResult> _testHistory = [];
  bool _isLoading = false;
  bool _isTestCompleted = false;

  // Getters
  List<BigFivePersonalityQuestion> get questions => _questions;
  Map<String, int> get answers => _answers;
  int get currentQuestionIndex => _currentQuestionIndex;
  BigFivePersonalityResult? get result => _result;
  List<BigFivePersonalityResult> get testHistory => _testHistory;
  bool get isLoading => _isLoading;
  bool get isTestCompleted => _isTestCompleted;
  double get progress => _questions.isEmpty ? 0.0 : (_currentQuestionIndex + 1) / _questions.length;
  BigFivePersonalityQuestion get currentQuestion => _questions[_currentQuestionIndex];
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;

  BigFivePersonalityProvider() {
    _initializeQuestions();
    _loadTestHistory();
  }

  // Initialize ML service
  Future<void> initializeML() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _mlService.initialize();
    } catch (e) {
      debugPrint('Error initializing BigFive ML service: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeQuestions() {
    _questions = [
      // Openness questions (O1-O10)
      BigFivePersonalityQuestion(
        id: 'O1',
        title: 'Vocabulary & Communication',
        question: 'I have a rich vocabulary and enjoy using diverse words to express myself.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'O',
      ),
      BigFivePersonalityQuestion(
        id: 'O2',
        title: 'Abstract Ideas',
        question: 'I have difficulty understanding abstract ideas and theoretical concepts.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'O',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'O3',
        title: 'Imagination',
        question: 'I have a vivid imagination and often daydream about possibilities.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'O',
      ),
      BigFivePersonalityQuestion(
        id: 'O4',
        title: 'Interest in Abstract Ideas',
        question: 'I am not interested in abstract ideas or philosophical discussions.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'O',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'O5',
        title: 'Creative Ideas',
        question: 'I have excellent ideas and often think of creative solutions.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'O',
      ),

      // Conscientiousness questions (C1-C10)
      BigFivePersonalityQuestion(
        id: 'C1',
        title: 'Preparation',
        question: 'I am always prepared and plan ahead for important events.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'C',
      ),
      BigFivePersonalityQuestion(
        id: 'C2',
        title: 'Organization',
        question: 'I leave my belongings around and struggle to keep things organized.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'C',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'C3',
        title: 'Attention to Detail',
        question: 'I pay attention to details and notice things others might miss.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'C',
      ),
      BigFivePersonalityQuestion(
        id: 'C4',
        title: 'Orderliness',
        question: 'I make a mess of things and struggle to maintain order.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'C',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'C5',
        title: 'Task Completion',
        question: 'I get chores done right away rather than putting them off.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'C',
      ),

      // Extraversion questions (E1-E10)
      BigFivePersonalityQuestion(
        id: 'E1',
        title: 'Social Energy',
        question: 'I am the life of the party and enjoy being the center of attention.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'E',
      ),
      BigFivePersonalityQuestion(
        id: 'E2',
        title: 'Communication',
        question: 'I don\'t talk a lot and prefer to listen rather than speak.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'E',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'E3',
        title: 'Social Comfort',
        question: 'I feel comfortable around people and enjoy social situations.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'E',
      ),
      BigFivePersonalityQuestion(
        id: 'E4',
        title: 'Social Presence',
        question: 'I keep in the background and avoid drawing attention to myself.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'E',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'E5',
        title: 'Social Initiative',
        question: 'I start conversations easily and enjoy meeting new people.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'E',
      ),

      // Agreeableness questions (A1-A10)
      BigFivePersonalityQuestion(
        id: 'A1',
        title: 'Concern for Others',
        question: 'I feel little concern for others and their problems.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'A',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'A2',
        title: 'Interest in People',
        question: 'I am interested in people and enjoy learning about them.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'A',
      ),
      BigFivePersonalityQuestion(
        id: 'A3',
        title: 'Respectful Communication',
        question: 'I insult people and often speak without considering their feelings.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'A',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'A4',
        title: 'Empathy',
        question: 'I sympathize with others\' feelings and try to understand their perspective.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'A',
      ),
      BigFivePersonalityQuestion(
        id: 'A5',
        title: 'Helping Others',
        question: 'I am not interested in other people\'s problems and prefer to focus on myself.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed
        trait: 'A',
        isReversed: true,
      ),

      // Neuroticism questions (N1-N10)
      BigFivePersonalityQuestion(
        id: 'N1',
        title: 'Stress Response',
        question: 'I get stressed out easily and often feel overwhelmed.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'N',
      ),
      BigFivePersonalityQuestion(
        id: 'N2',
        title: 'Emotional Stability',
        question: 'I am relaxed most of the time and rarely get anxious.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed (low neuroticism)
        trait: 'N',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'N3',
        title: 'Worry Tendency',
        question: 'I worry about things and often think about what could go wrong.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'N',
      ),
      BigFivePersonalityQuestion(
        id: 'N4',
        title: 'Emotional Resilience',
        question: 'I seldom feel blue or depressed and maintain a positive outlook.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [5, 4, 3, 2, 1], // Reversed (low neuroticism)
        trait: 'N',
        isReversed: true,
      ),
      BigFivePersonalityQuestion(
        id: 'N5',
        title: 'Emotional Sensitivity',
        question: 'I am easily disturbed by criticism or negative feedback.',
        options: ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree'],
        values: [1, 2, 3, 4, 5],
        trait: 'N',
      ),
    ];
  }

  // Answer current question
  void answerCurrentQuestion(int answerIndex) {
    if (_currentQuestionIndex < _questions.length) {
      final question = _questions[_currentQuestionIndex];
      _answers[question.id] = answerIndex;
      notifyListeners();
    }
  }

  // Navigate to next question
  void nextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Navigate to previous question
  void previousQuestion() {
    if (hasPreviousQuestion) {
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
      // Calculate trait scores
      Map<String, double> traitScores = _calculateTraitScores();
      
      // Get ML prediction
      Map<String, dynamic> prediction = await _mlService.predictPersonality(traitScores);
      
      // Create result
      _result = BigFivePersonalityResult(
        traitScores: traitScores,
        dominantCluster: prediction['cluster'] ?? 'Unknown',
        personalityType: prediction['personalityType'] ?? 'Balanced Individual',
        confidence: prediction['confidence'] ?? 0.0,
        clusterProbabilities: Map<String, double>.from(prediction['probabilities'] ?? {}),
        timestamp: DateTime.now(),
        answers: _getAnswersForStorage(),
      );

      // Add to history
      _testHistory.insert(0, _result!);
      await _saveTestHistory();

      _isTestCompleted = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing Big Five test: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate trait scores from answers
  Map<String, double> _calculateTraitScores() {
    Map<String, double> traitTotals = {'O': 0, 'C': 0, 'E': 0, 'A': 0, 'N': 0};
    Map<String, int> traitCounts = {'O': 0, 'C': 0, 'E': 0, 'A': 0, 'N': 0};

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answerIndex = _answers[question.id];
      
      if (answerIndex != null) {
        final value = question.values[answerIndex].toDouble();
        traitTotals[question.trait] = traitTotals[question.trait]! + value;
        traitCounts[question.trait] = traitCounts[question.trait]! + 1;
      }
    }

    // Calculate averages and normalize to -3 to +3 scale
    Map<String, double> traitScores = {};
    for (String trait in ['O', 'C', 'E', 'A', 'N']) {
      if (traitCounts[trait]! > 0) {
        double average = traitTotals[trait]! / traitCounts[trait]!;
        // Convert from 1-5 scale to -3 to +3 scale
        traitScores[trait] = (average - 3.0) * 1.5;
      } else {
        traitScores[trait] = 0.0;
      }
    }

    return traitScores;
  }

  // Get answers formatted for storage
  List<Map<String, dynamic>> _getAnswersForStorage() {
    return _questions.map((question) {
      final answerIndex = _answers[question.id];
      return {
        'questionId': question.id,
        'answerIndex': answerIndex,
        'answerText': answerIndex != null ? question.options[answerIndex] : null,
        'trait': question.trait,
      };
    }).toList();
  }

  // Reset test
  void resetTest() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _result = null;
    _isTestCompleted = false;
    notifyListeners();
  }

  // Load test history
  Future<void> _loadTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('bigfive_test_history') ?? [];
      
      _testHistory = historyJson
          .map((json) => BigFivePersonalityResult.fromJson(jsonDecode(json)))
          .toList();
          
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Big Five test history: $e');
    }
  }

  // Save test history
  Future<void> _saveTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _testHistory
          .take(50) // Keep only last 50 tests
          .map((result) => jsonEncode(result.toJson()))
          .toList();
      
      await prefs.setStringList('bigfive_test_history', historyJson);
    } catch (e) {
      debugPrint('Error saving Big Five test history: $e');
    }
  }

  // Clear test history
  Future<void> clearTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bigfive_test_history');
      _testHistory.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing Big Five test history: $e');
    }
  }

  // Get current personality type (most recent result)
  String? get currentPersonalityType {
    return _testHistory.isNotEmpty ? _testHistory.first.personalityType : null;
  }

  // Get confidence of current personality type
  double get currentConfidence {
    return _testHistory.isNotEmpty ? _testHistory.first.confidence : 0.0;
  }

  // Get trait scores of current personality type
  Map<String, double> get currentTraitScores {
    return _testHistory.isNotEmpty ? _testHistory.first.traitScores : {};
  }

  // Set a historical result as current (for viewing details)
  void setHistoricalResult(BigFivePersonalityResult result) {
    _result = result;
    _isTestCompleted = true;
    notifyListeners();
  }
}

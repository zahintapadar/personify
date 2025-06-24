import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mbti_personality_question.dart';
import '../models/mbti_personality_result.dart';
import '../services/mbti_ml_service_enhanced.dart';
import '../services/google_forms_service.dart';
import '../services/supabase_service.dart';

class MBTIPersonalityProvider extends ChangeNotifier {
  final MBTIMLService _mlService = MBTIMLService();

  // Test state
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isTestCompleted = false;
  MBTIPersonalityResult? _result;
  bool _isLoading = false;
  bool _isInitialized = false;

  // History state
  List<MBTIPersonalityResult> _testHistory = [];
  static const String _historyKey = 'mbti_personality_test_history';

  // MBTI Questions - MCQ-based for better UX and retention
  final List<PersonalityQuestion> _questions = [
    // Extraversion vs Introversion Questions (E/I)
    PersonalityQuestion(
      id: 'energy_source',
      title: 'Energy & Social Interaction',
      question: 'What gives you more energy and makes you feel most alive?',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Being around people, socializing, and engaging in group activities',
        'Having quiet time alone, reflecting, and pursuing individual interests',
        'A mix of both, but I lean toward being with others',
        'A mix of both, but I prefer my alone time',
      ],
      values: [3, -3, 1, -1], // E, I, slight E, slight I
    ),
    PersonalityQuestion(
      id: 'communication_style',
      title: 'Communication Preference',
      question: 'How do you prefer to process and share your thoughts?',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'I think out loud and enjoy discussing ideas as they develop',
        'I prefer to think things through privately before sharing',
        'I like brainstorming with others to develop my ideas',
        'I need quiet reflection time to form my thoughts clearly',
      ],
      values: [3, -3, 2, -2],
    ),
    PersonalityQuestion(
      id: 'social_situations',
      title: 'Social Situations',
      question: 'At a party or social gathering, you typically:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Feel energized and enjoy meeting new people',
        'Find it draining and prefer to leave early',
        'Enjoy it but need breaks to recharge',
        'Stay close to people you know well',
      ],
      values: [3, -3, 1, -1],
    ),

    // Sensing vs Intuition Questions (S/N)
    PersonalityQuestion(
      id: 'information_focus',
      title: 'Information Processing',
      question: 'When learning something new, you prefer to focus on:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Concrete facts, details, and step-by-step procedures',
        'Big picture concepts, patterns, and future possibilities',
        'Practical applications and real-world examples',
        'Theoretical implications and innovative connections',
      ],
      values: [3, -3, 2, -2], // S, N, moderate S, moderate N
    ),
    PersonalityQuestion(
      id: 'problem_approach',
      title: 'Problem-Solving Approach',
      question: 'When facing a complex problem, you tend to:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Break it down into manageable, concrete steps',
        'Look for creative, innovative solutions that haven\'t been tried',
        'Use proven methods that have worked before',
        'Explore multiple possibilities and unconventional approaches',
      ],
      values: [3, -3, 2, -2],
    ),
    PersonalityQuestion(
      id: 'future_vs_present',
      title: 'Time Orientation',
      question: 'You find yourself more naturally drawn to:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Living in the present moment and dealing with current realities',
        'Imagining future possibilities and potential outcomes',
        'Learning from past experiences and established traditions',
        'Envisioning revolutionary changes and breakthrough innovations',
      ],
      values: [3, -3, 1, -2],
    ),

    // Thinking vs Feeling Questions (T/F)
    PersonalityQuestion(
      id: 'decision_criteria',
      title: 'Decision-Making Criteria',
      question: 'When making important decisions, you primarily consider:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Logical analysis, objective facts, and rational evaluation',
        'Personal values, impact on people, and what feels right',
        'Efficiency, effectiveness, and practical outcomes',
        'Harmony, consensus, and everyone\'s feelings',
      ],
      values: [3, -3, 2, -2], // T, F, moderate T, moderate F
    ),
    PersonalityQuestion(
      id: 'feedback_style',
      title: 'Feedback & Criticism',
      question: 'When giving feedback or criticism, you tend to:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Be direct and focus on facts, even if it might hurt feelings',
        'Consider the person\'s emotions and deliver it gently',
        'Focus on improvement opportunities with objective reasoning',
        'Emphasize positive aspects while addressing concerns sensitively',
      ],
      values: [3, -3, 2, -2],
    ),
    PersonalityQuestion(
      id: 'conflict_resolution',
      title: 'Conflict Resolution',
      question: 'In conflicts, you believe the most important thing is to:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Find the most logical and fair solution based on principles',
        'Ensure everyone feels heard and relationships are preserved',
        'Solve the problem efficiently with clear reasoning',
        'Create harmony and understanding between all parties',
      ],
      values: [3, -3, 1, -2],
    ),

    // Judging vs Perceiving Questions (J/P)
    PersonalityQuestion(
      id: 'planning_style',
      title: 'Planning & Organization',
      question: 'Your approach to planning and organization is:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'I like detailed plans, schedules, and sticking to deadlines',
        'I prefer to keep options open and adapt as situations change',
        'I make basic plans but am comfortable adjusting them',
        'I work best with complete flexibility and spontaneous decisions',
      ],
      values: [3, -3, 1, -2], // J, P, slight J, strong P
    ),
    PersonalityQuestion(
      id: 'work_style',
      title: 'Work Style Preference',
      question: 'You work most effectively when you:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Have clear deadlines, structure, and organized systems',
        'Can explore different options and change direction as needed',
        'Balance structure with some flexibility for creativity',
        'Have complete freedom to work in your own unique way',
      ],
      values: [3, -3, 1, -2],
    ),
    PersonalityQuestion(
      id: 'decision_timing',
      title: 'Decision-Making Timeline',
      question: 'When facing an important decision, you prefer to:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Gather necessary information quickly and decide promptly',
        'Keep exploring options and delay the decision as long as possible',
        'Set a reasonable deadline and stick to it',
        'Wait until the last minute when all possibilities are clear',
      ],
      values: [3, -3, 2, -2],
    ),

    // Additional Mixed Questions for Better Analysis
    PersonalityQuestion(
      id: 'leadership_style',
      title: 'Leadership Approach',
      question: 'If you were leading a team, you would:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Set clear goals, delegate tasks, and monitor progress systematically',
        'Inspire the team with a compelling vision and encourage creativity',
        'Build consensus and ensure everyone feels valued and heard',
        'Adapt your approach based on the situation and team needs',
      ],
      values: [2, -1, -2, 0], // Slight T+J, slight N, F, balanced
    ),
    PersonalityQuestion(
      id: 'stress_response',
      title: 'Stress Management',
      question: 'When you\'re feeling stressed or overwhelmed, you typically:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Make lists, organize your tasks, and tackle them systematically',
        'Take time alone to process your thoughts and recharge',
        'Talk it through with friends or family for support',
        'Try new approaches or change your environment',
      ],
      values: [2, -1, 1, -1], // J+T, I, E+F, P+N
    ),
    PersonalityQuestion(
      id: 'learning_preference',
      title: 'Learning Style',
      question: 'You learn best when you can:',
      type: PersonalityQuestionType.multipleChoice,
      options: [
        'Follow structured lessons with clear steps and practical examples',
        'Explore concepts freely and make creative connections',
        'Discuss ideas with others and learn through interaction',
        'Reflect quietly and understand the underlying principles',
      ],
      values: [2, -2, 1, -1], // S+J, N+P, E, I+T
    ),
  ];

  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get answers => _answers;
  bool get isTestCompleted => _isTestCompleted;
  MBTIPersonalityResult? get result => _result;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<PersonalityQuestion> get questions => _questions;
  PersonalityQuestion get currentQuestion => _questions[_currentQuestionIndex];
  double get progress => (_currentQuestionIndex + 1) / _questions.length;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;
  List<MBTIPersonalityResult> get testHistory => _testHistory;

  // Initialize ML service
  Future<void> initializeML() async {
    if (_isInitialized) return; // Prevent multiple initializations

    _isLoading = true;
    notifyListeners();

    try {
      await _mlService.initialize();
      await _loadTestHistory();
      debugPrint('MBTI ML Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing MBTI ML service: $e');
      // Continue without ML service - fallback will be used
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Answer a question
  void answerQuestion(String questionId, int selectedOptionIndex) {
    _answers[questionId] = selectedOptionIndex;
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
      throw Exception(
        'Please answer all questions before completing the test.',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate MBTI scores from MCQ answers
      Map<String, double> dimensionScores = _calculateMCQScores();

      // Determine MBTI type based on scores
      String mbtiType = _determineMBTIType(dimensionScores);

      // Calculate confidence based on score clarity
      double confidence = _calculateConfidence(dimensionScores);

      // Generate type probabilities
      Map<String, double> typeProbabilities = _generateTypeProbabilities(
        dimensionScores,
      );

      // Create comprehensive result
      _result = MBTIPersonalityResult(
        mbtiType: mbtiType,
        confidence: confidence,
        description: _getTypeDescription(mbtiType),
        traits: _getMBTITraits(mbtiType),
        strengths: _getTypeStrengths(mbtiType),
        weaknesses: _getTypeChallenges(mbtiType),
        tips: _getMBTITips(mbtiType),
        typeProbabilities: typeProbabilities,
        cognitiveStack: _getCognitiveStack(mbtiType),
        careerSuggestions: _getCareerSuggestions(mbtiType),
        answers: Map.from(_answers),
      );

      _isTestCompleted = true;

      // Save to history
      await _saveTestToHistory(_result!);

      // Submit to Google Forms (non-blocking)
      _submitToGoogleForms(_result!.mbtiType, _answers);

      // Submit to Supabase (non-blocking)
      _submitToSupabase(_result!, _answers);
    } catch (e) {
      debugPrint('Error completing MBTI test: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Calculate MBTI dimension scores from MCQ answers
  Map<String, double> _calculateMCQScores() {
    Map<String, double> scores = {
      'E': 0.0,
      'I': 0.0,
      'S': 0.0,
      'N': 0.0,
      'T': 0.0,
      'F': 0.0,
      'J': 0.0,
      'P': 0.0,
    };

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answerIndex = _answers[question.id] as int?;

      if (answerIndex != null &&
          question.values != null &&
          answerIndex < question.values!.length) {
        final value = question.values![answerIndex];

        // Map scores to MBTI dimensions based on question content
        if (question.id.contains('energy') ||
            question.id.contains('communication') ||
            question.id.contains('social')) {
          // E/I questions
          if (value > 0) {
            scores['E'] = scores['E']! + value;
          } else {
            scores['I'] = scores['I']! + value.abs();
          }
        } else if (question.id.contains('information') ||
            question.id.contains('problem') ||
            question.id.contains('future')) {
          // S/N questions
          if (value > 0) {
            scores['S'] = scores['S']! + value;
          } else {
            scores['N'] = scores['N']! + value.abs();
          }
        } else if (question.id.contains('decision') ||
            question.id.contains('feedback') ||
            question.id.contains('conflict')) {
          // T/F questions
          if (value > 0) {
            scores['T'] = scores['T']! + value;
          } else {
            scores['F'] = scores['F']! + value.abs();
          }
        } else if (question.id.contains('planning') ||
            question.id.contains('work') ||
            question.id.contains('timing')) {
          // J/P questions
          if (value > 0) {
            scores['J'] = scores['J']! + value;
          } else {
            scores['P'] = scores['P']! + value.abs();
          }
        } else {
          // Mixed questions - distribute based on question content
          _distributeMixedQuestionScore(question, value.toDouble(), scores);
        }
      }
    }

    return scores;
  }

  // Distribute scores for mixed questions
  void _distributeMixedQuestionScore(
    PersonalityQuestion question,
    double value,
    Map<String, double> scores,
  ) {
    if (question.id == 'leadership_style') {
      // Leadership question affects T/F and J/P
      if (value > 0) {
        scores['T'] = scores['T']! + (value * 0.6);
        scores['J'] = scores['J']! + (value * 0.4);
      } else if (value < -1) {
        scores['F'] = scores['F']! + value.abs();
      }
    } else if (question.id == 'stress_response') {
      // Stress question affects multiple dimensions
      if (value == 2.0) {
        // Organize tasks
        scores['J'] = scores['J']! + 2.0;
        scores['T'] = scores['T']! + 1.0;
      } else if (value == -1.0) {
        // Time alone
        scores['I'] = scores['I']! + 2.0;
      } else if (value == 1.0) {
        // Talk it through
        scores['E'] = scores['E']! + 2.0;
        scores['F'] = scores['F']! + 1.0;
      } else {
        // Try new approaches
        scores['P'] = scores['P']! + 1.0;
        scores['N'] = scores['N']! + 1.0;
      }
    } else if (question.id == 'learning_preference') {
      // Learning question affects S/N and E/I
      if (value == 2.0) {
        // Structured lessons
        scores['S'] = scores['S']! + 2.0;
        scores['J'] = scores['J']! + 1.0;
      } else if (value == -2.0) {
        // Explore freely
        scores['N'] = scores['N']! + 2.0;
        scores['P'] = scores['P']! + 1.0;
      } else if (value == 1.0) {
        // Discuss with others
        scores['E'] = scores['E']! + 2.0;
      } else if (value == -1.0) {
        // Reflect quietly
        scores['I'] = scores['I']! + 2.0;
        scores['T'] = scores['T']! + 1.0;
      }
    }
  }

  // Determine MBTI type from dimension scores
  String _determineMBTIType(Map<String, double> scores) {
    String type = '';

    // E vs I
    type += scores['E']! > scores['I']! ? 'E' : 'I';

    // S vs N
    type += scores['S']! > scores['N']! ? 'S' : 'N';

    // T vs F
    type += scores['T']! > scores['F']! ? 'T' : 'F';

    // J vs P
    type += scores['J']! > scores['P']! ? 'J' : 'P';

    return type;
  }

  // Calculate confidence based on score clarity
  double _calculateConfidence(Map<String, double> scores) {
    // Calculate confidence based on how clear the preferences are
    double eiDiff = (scores['E']! - scores['I']!).abs();
    double snDiff = (scores['S']! - scores['N']!).abs();
    double tfDiff = (scores['T']! - scores['F']!).abs();
    double jpDiff = (scores['J']! - scores['P']!).abs();

    // Average the differences and normalize
    double avgDiff = (eiDiff + snDiff + tfDiff + jpDiff) / 4;
    double maxPossibleScore =
        15.0; // Theoretical maximum based on question values

    // Convert to confidence percentage (0.5 to 1.0 range)
    double confidence = 0.5 + (avgDiff / maxPossibleScore) * 0.5;
    return confidence.clamp(0.5, 1.0);
  }

  // Generate probability distribution for all 16 types
  Map<String, double> _generateTypeProbabilities(Map<String, double> scores) {
    Map<String, double> probabilities = {};

    // List of all 16 MBTI types
    List<String> types = [
      'INTJ',
      'INTP',
      'ENTJ',
      'ENTP',
      'INFJ',
      'INFP',
      'ENFJ',
      'ENFP',
      'ISTJ',
      'ISFJ',
      'ESTJ',
      'ESFJ',
      'ISTP',
      'ISFP',
      'ESTP',
      'ESFP',
    ];

    for (String type in types) {
      double score = 0.0;

      // Calculate score for each type based on dimension alignment
      score += type[0] == 'E' ? scores['E']! : scores['I']!;
      score += type[1] == 'S' ? scores['S']! : scores['N']!;
      score += type[2] == 'T' ? scores['T']! : scores['F']!;
      score += type[3] == 'J' ? scores['J']! : scores['P']!;

      probabilities[type] = score;
    }

    // Normalize probabilities
    double totalScore = probabilities.values.reduce((a, b) => a + b);
    if (totalScore > 0) {
      probabilities.updateAll((key, value) => value / totalScore);
    }

    return probabilities;
  }

  // Get type description
  String _getTypeDescription(String mbtiType) {
    final descriptions = {
      'INTJ':
          'The Architect - Independent and strategic, you prefer working alone and focusing on the big picture.',
      'INTP':
          'The Thinker - Logical and analytical, you love exploring ideas and understanding complex systems.',
      'ENTJ':
          'The Commander - Natural born leader, you are confident and excel at organizing and directing.',
      'ENTP':
          'The Debater - Innovative and enthusiastic, you enjoy exploring new possibilities and challenging ideas.',
      'INFJ':
          'The Advocate - Compassionate and insightful, you are driven by your values and desire to help others.',
      'INFP':
          'The Mediator - Creative and idealistic, you are guided by your personal values and seek harmony.',
      'ENFJ':
          'The Protagonist - Charismatic and inspiring, you naturally motivate others toward positive change.',
      'ENFP':
          'The Campaigner - Enthusiastic and creative, you see potential in everyone and everything.',
      'ISTJ':
          'The Logistician - Practical and responsible, you value tradition and work systematically.',
      'ISFJ':
          'The Protector - Caring and meticulous, you dedicate yourself to supporting and protecting others.',
      'ESTJ':
          'The Executive - Organized and decisive, you excel at managing projects and leading teams.',
      'ESFJ':
          'The Consul - Social and supportive, you work best when helping others and maintaining harmony.',
      'ISTP':
          'The Virtuoso - Practical and adaptable, you prefer hands-on problem solving and flexible approaches.',
      'ISFP':
          'The Adventurer - Gentle and artistic, you value personal freedom and express yourself creatively.',
      'ESTP':
          'The Entrepreneur - Energetic and perceptive, you live in the moment and adapt quickly to change.',
      'ESFP':
          'The Entertainer - Spontaneous and enthusiastic, you love interacting with others and trying new experiences.',
    };

    return descriptions[mbtiType] ??
        'A unique personality type with balanced traits across all dimensions.';
  }

  // Get type strengths
  List<String> _getTypeStrengths(String mbtiType) {
    final strengths = {
      'INTJ': [
        'Strategic thinking',
        'Independent',
        'Determined',
        'Innovative',
        'Analytical',
      ],
      'INTP': [
        'Logical reasoning',
        'Intellectual curiosity',
        'Objective analysis',
        'Creative problem-solving',
        'Independent thinking',
      ],
      'ENTJ': [
        'Leadership skills',
        'Strategic planning',
        'Efficient',
        'Confident',
        'Goal-oriented',
      ],
      'ENTP': [
        'Creative thinking',
        'Enthusiastic',
        'Adaptable',
        'Good at generating ideas',
        'Charismatic',
      ],
      'INFJ': [
        'Empathetic',
        'Insightful',
        'Creative',
        'Decisive',
        'Altruistic',
      ],
      'INFP': [
        'Empathetic',
        'Creative',
        'Passionate about values',
        'Flexible',
        'Open-minded',
      ],
      'ENFJ': [
        'Natural leadership',
        'Empathetic',
        'Charismatic',
        'Altruistic',
        'Good communicator',
      ],
      'ENFP': [
        'Enthusiastic',
        'Creative',
        'Sociable',
        'Energetic',
        'Good people skills',
      ],
      'ISTJ': [
        'Responsible',
        'Practical',
        'Fact-minded',
        'Reliable',
        'Patient',
      ],
      'ISFJ': ['Supportive', 'Reliable', 'Patient', 'Imaginative', 'Observant'],
      'ESTJ': ['Dedicated', 'Strong-willed', 'Direct', 'Honest', 'Loyal'],
      'ESFJ': [
        'Strong practical skills',
        'Loyal',
        'Sensitive',
        'Warm-hearted',
        'Good at connecting with others',
      ],
      'ISTP': [
        'Optimistic',
        'Energetic',
        'Creative',
        'Practical',
        'Spontaneous',
      ],
      'ISFP': [
        'Charming',
        'Sensitive to others',
        'Imaginative',
        'Passionate',
        'Curious',
      ],
      'ESTP': ['Bold', 'Rational', 'Practical', 'Original', 'Perceptive'],
      'ESFP': ['Bold', 'Original', 'Aesthetics', 'Showmanship', 'Practical'],
    };

    return strengths[mbtiType] ??
        ['Natural leadership', 'Strategic thinking', 'Problem solving'];
  }

  // Get type challenges
  List<String> _getTypeChallenges(String mbtiType) {
    final challenges = {
      'INTJ': [
        'Can be overly critical',
        'May dismiss emotions',
        'Perfectionist tendencies',
        'Difficulty with details',
      ],
      'INTP': [
        'May neglect practical matters',
        'Difficulty with emotions',
        'Can be insensitive',
        'Procrastination',
      ],
      'ENTJ': [
        'Can be impatient',
        'May overlook feelings',
        'Domineering',
        'Workaholic tendencies',
      ],
      'ENTP': [
        'Difficulty with routine',
        'May neglect details',
        'Can be argumentative',
        'Inconsistent follow-through',
      ],
      'INFJ': [
        'Perfectionist',
        'Overly sensitive',
        'Reluctant to open up',
        'Can burn out easily',
      ],
      'INFP': [
        'Overly idealistic',
        'May take things personally',
        'Difficulty with criticism',
        'Can be impractical',
      ],
      'ENFJ': [
        'Overly idealistic',
        'Too selfless',
        'Overly sensitive',
        'Can be manipulative',
      ],
      'ENFP': [
        'Difficulty focusing',
        'Overthink things',
        'Get stressed easily',
        'Highly emotional',
      ],
      'ISTJ': ['Stubborn', 'Insensitive', 'Always by the book', 'Judgmental'],
      'ISFJ': ['Humble', 'Shy', 'Take things personally', 'Repress feelings'],
      'ESTJ': [
        'Inflexible',
        'Uncomfortable with unconventional situations',
        'Judgmental',
        'Impatient',
      ],
      'ESFJ': [
        'Worried about social status',
        'Inflexible',
        'Reluctant to innovate',
        'Vulnerable to criticism',
      ],
      'ISTP': ['Stubborn', 'Insensitive', 'Private', 'Easily bored'],
      'ISFP': [
        'Fiercely independent',
        'Unpredictable',
        'Easily stressed',
        'Overly competitive',
      ],
      'ESTP': ['Insensitive', 'Impatient', 'Risk-prone', 'Unstructured'],
      'ESFP': [
        'Sensitive',
        'Conflict-averse',
        'Easily bored',
        'Poor long-term planners',
      ],
    };

    return challenges[mbtiType] ??
        ['May be overly critical', 'Can appear aloof', 'Might ignore emotions'];
  }

  // Load test history from SharedPreferences
  Future<void> _loadTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        _testHistory = historyList
            .map((json) => MBTIPersonalityResult.fromJson(json))
            .toList();
        debugPrint(
          'Loaded ${_testHistory.length} MBTI test results from history',
        );
      }
    } catch (e) {
      debugPrint('Error loading MBTI test history: $e');
      _testHistory = [];
    }
  }

  // Save test result to history
  Future<void> _saveTestToHistory(MBTIPersonalityResult result) async {
    try {
      _testHistory.insert(0, result); // Add to beginning

      // Keep only last 10 results
      if (_testHistory.length > 10) {
        _testHistory = _testHistory.take(10).toList();
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _testHistory.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);

      debugPrint(
        'Saved MBTI test result to history. Total results: ${_testHistory.length}',
      );
    } catch (e) {
      debugPrint('Error saving MBTI test to history: $e');
    }
  }

  // Clear test history
  Future<void> clearTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _testHistory.clear();
      notifyListeners();
      debugPrint('MBTI test history cleared');
    } catch (e) {
      debugPrint('Error clearing MBTI test history: $e');
    }
  }

  // Submit MBTI results to Google Forms (non-blocking)
  void _submitToGoogleForms(String mbtiType, Map<String, dynamic> answers) {
    // Run submission in background without blocking UI
    GoogleFormsService.submitMBTIResults(
          mbtiType: mbtiType,
          answers: answers,
          questions: _questions, // Pass questions for option text mapping
        )
        .then((success) {
          if (success) {
            debugPrint('Successfully submitted MBTI results to Google Forms');
          } else {
            debugPrint('Failed to submit MBTI results to Google Forms');
          }
        })
        .catchError((error) {
          debugPrint('Error submitting MBTI results to Google Forms: $error');
        });
  }

  // Submit MBTI results to Supabase (non-blocking)
  void _submitToSupabase(
    MBTIPersonalityResult result,
    Map<String, dynamic> answers,
  ) {
    // Run submission in background without blocking UI
    SupabaseService.submitMBTITest(result: result, answers: answers)
        .then((success) {
          if (success) {
            debugPrint('Successfully submitted MBTI results to Supabase');
          } else {
            debugPrint('Failed to submit MBTI results to Supabase');
          }
        })
        .catchError((error) {
          debugPrint('Error submitting MBTI results to Supabase: $error');
        });
  }

  // Set a historical result as current (for viewing details)
  void setHistoricalResult(MBTIPersonalityResult result) {
    _result = result;
    _isTestCompleted = true;
    notifyListeners();
  }

  // Reset the test
  void resetTest() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _isTestCompleted = false;
    _result = null;
    notifyListeners();
  }

  // MBTI Type Descriptions
  // Get MBTI traits
  List<String> _getMBTITraits(String mbtiType) {
    // Implementation would include comprehensive traits for each type
    final traits = {
      'INTJ': [
        'Strategic thinking',
        'Independent',
        'Analytical',
        'Future-focused',
        'Systematic',
        'Confident',
      ],
      'INTP': [
        'Logical',
        'Theoretical',
        'Curious',
        'Flexible',
        'Objective',
        'Innovative',
      ],
      'ENTJ': [
        'Leadership',
        'Strategic',
        'Decisive',
        'Ambitious',
        'Organized',
        'Confident',
      ],
      'ENTP': [
        'Innovative',
        'Enthusiastic',
        'Strategic',
        'Adaptable',
        'Outgoing',
        'Intellectual',
      ],
      'INFJ': [
        'Insightful',
        'Empathetic',
        'Creative',
        'Inspiring',
        'Principled',
        'Visionary',
      ],
      'INFP': [
        'Idealistic',
        'Creative',
        'Authentic',
        'Empathetic',
        'Values-driven',
        'Flexible',
      ],
      'ENFJ': [
        'Charismatic',
        'Empathetic',
        'Inspiring',
        'Organized',
        'Diplomatic',
        'Altruistic',
      ],
      'ENFP': [
        'Enthusiastic',
        'Creative',
        'People-focused',
        'Adaptable',
        'Inspiring',
        'Innovative',
      ],
      'ISTJ': [
        'Reliable',
        'Methodical',
        'Practical',
        'Responsible',
        'Thorough',
        'Traditional',
      ],
      'ISFJ': [
        'Caring',
        'Loyal',
        'Detail-oriented',
        'Supportive',
        'Practical',
        'Patient',
      ],
      'ESTJ': [
        'Organized',
        'Decisive',
        'Leadership',
        'Practical',
        'Efficient',
        'Traditional',
      ],
      'ESFJ': [
        'Caring',
        'Sociable',
        'Helpful',
        'Organized',
        'Loyal',
        'Traditional',
      ],
      'ISTP': [
        'Practical',
        'Analytical',
        'Adaptable',
        'Independent',
        'Realistic',
        'Action-oriented',
      ],
      'ISFP': [
        'Artistic',
        'Gentle',
        'Flexible',
        'Values-driven',
        'Caring',
        'Independent',
      ],
      'ESTP': [
        'Energetic',
        'Practical',
        'Adaptable',
        'Realistic',
        'Action-oriented',
        'Social',
      ],
      'ESFP': [
        'Enthusiastic',
        'Spontaneous',
        'People-focused',
        'Optimistic',
        'Flexible',
        'Fun-loving',
      ],
    };

    return traits[mbtiType] ?? ['Unique', 'Individual', 'Special'];
  }

  // Get MBTI tips
  List<String> _getMBTITips(String mbtiType) {
    final tips = {
      'INTJ': [
        'Set aside time for both strategic planning and tactical execution',
        'Practice communicating your vision in ways others can understand',
        'Remember to consider the emotional impact of your decisions',
        'Build strong networks even though you prefer working independently',
        'Take breaks to avoid burnout from intense focus',
      ],
      'INTP': [
        'Set deadlines and accountability systems to complete projects',
        'Practice articulating your ideas clearly to others',
        'Consider the practical applications of your theories',
        'Develop your emotional intelligence and empathy',
        'Create structure in your daily routine',
      ],
      'ENTJ': [
        'Listen actively to others\' perspectives before making decisions',
        'Consider the emotional needs of your team members',
        'Practice patience with those who work at different paces',
        'Delegate effectively rather than trying to do everything',
        'Take time for personal reflection and self-care',
      ],
      'ENTP': [
        'Develop systems to follow through on your ideas',
        'Practice focus by limiting the number of active projects',
        'Consider others\' feelings when sharing constructive criticism',
        'Create accountability partnerships to meet deadlines',
        'Learn to appreciate routine tasks that support your goals',
      ],
      'INFJ': [
        'Set healthy boundaries to prevent emotional overwhelm',
        'Share your insights more openly with trusted people',
        'Practice self-compassion when things don\'t go perfectly',
        'Take regular alone time to recharge and reflect',
        'Focus on progress rather than perfection',
      ],
      'INFP': [
        'Create structure and deadlines to turn ideas into reality',
        'Practice direct communication even when it feels uncomfortable',
        'Build confidence by celebrating small accomplishments',
        'Seek feedback without taking criticism personally',
        'Connect with others who share your values and passions',
      ],
      'ENFJ': [
        'Remember to take care of your own needs, not just others\'',
        'Practice saying no to prevent overcommitment',
        'Seek honest feedback about your leadership style',
        'Allow others to make their own mistakes and learn',
        'Develop your analytical thinking skills',
      ],
      'ENFP': [
        'Create systems to manage details and follow through',
        'Practice focusing on one project at a time',
        'Develop your decision-making process for important choices',
        'Learn to handle routine tasks without losing motivation',
        'Seek feedback to improve your consistency',
      ],
      'ISTJ': [
        'Practice being open to new ideas and approaches',
        'Communicate your reasoning to help others understand',
        'Consider the emotional impact of changes on others',
        'Challenge yourself to try new experiences occasionally',
        'Appreciate innovation alongside proven methods',
      ],
      'ISFJ': [
        'Practice expressing your own needs and opinions',
        'Set boundaries to prevent being taken advantage of',
        'Take credit for your contributions and achievements',
        'Learn to handle conflict constructively',
        'Make time for activities that energize you personally',
      ],
      'ESTJ': [
        'Practice flexibility when plans need to change',
        'Listen to others\' perspectives before making decisions',
        'Consider innovative solutions alongside proven methods',
        'Develop your emotional intelligence with team members',
        'Delegate rather than micromanaging',
      ],
      'ESFJ': [
        'Practice asserting your own needs in relationships',
        'Learn to handle criticism without taking it personally',
        'Consider logical analysis alongside emotional factors',
        'Set boundaries to prevent overextending yourself',
        'Embrace change as an opportunity for growth',
      ],
      'ISTP': [
        'Practice communicating your thoughts and feelings to others',
        'Set long-term goals to complement your present focus',
        'Consider how your actions affect others emotionally',
        'Develop your planning and organizational skills',
        'Engage with others even when you prefer solitude',
      ],
      'ISFP': [
        'Practice expressing your values and opinions more openly',
        'Develop confidence in your abilities and contributions',
        'Learn to handle conflict and criticism constructively',
        'Set goals and create plans to achieve your ideals',
        'Build stronger connections with like-minded people',
      ],
      'ESTP': [
        'Practice thinking through long-term consequences',
        'Develop patience for detailed planning and preparation',
        'Consider others\' feelings when making quick decisions',
        'Create systems to manage your time and commitments',
        'Learn from past experiences to inform future choices',
      ],
      'ESFP': [
        'Develop your planning and organizational skills',
        'Practice handling criticism and conflict constructively',
        'Consider long-term consequences of your decisions',
        'Create structure in your daily routine',
        'Build your analytical thinking capabilities',
      ],
    };

    return tips[mbtiType] ??
        [
          'Practice emotional intelligence and empathy',
          'Collaborate effectively with different personality types',
          'Stay open to feedback and continuous learning',
          'Balance your strengths with areas for growth',
        ];
  }

  // Get cognitive stack
  String _getCognitiveStack(String mbtiType) {
    final stacks = {
      'INTJ': 'Ni-Te-Fi-Se',
      'INTP': 'Ti-Ne-Si-Fe',
      'ENTJ': 'Te-Ni-Se-Fi',
      'ENTP': 'Ne-Ti-Fe-Si',
      'INFJ': 'Ni-Fe-Ti-Se',
      'INFP': 'Fi-Ne-Si-Te',
      'ENFJ': 'Fe-Ni-Se-Ti',
      'ENFP': 'Ne-Fi-Te-Si',
      'ISTJ': 'Si-Te-Fi-Ne',
      'ISFJ': 'Si-Fe-Ti-Ne',
      'ESTJ': 'Te-Si-Ne-Fi',
      'ESFJ': 'Fe-Si-Ne-Ti',
      'ISTP': 'Ti-Se-Ni-Fe',
      'ISFP': 'Fi-Se-Ni-Te',
      'ESTP': 'Se-Ti-Fe-Ni',
      'ESFP': 'Se-Fi-Te-Ni',
    };

    return stacks[mbtiType] ?? 'Unknown';
  }

  // Get detailed cognitive function explanations
  Map<String, String> getCognitiveFunctionDetails(String mbtiType) {
    final functionMappings = {
      'Ni':
          'Introverted Intuition: Sees patterns, connections, and future possibilities. Naturally synthesizes information to form insights and see the bigger picture.',
      'Ne':
          'Extraverted Intuition: Explores possibilities, generates ideas, and sees connections between different concepts. Naturally brainstorms and thinks outside the box.',
      'Si':
          'Introverted Sensing: Recalls past experiences and compares them to present situations. Values tradition, consistency, and proven methods.',
      'Se':
          'Extraverted Sensing: Lives in the present moment and responds to immediate opportunities. Notices environmental details and adapts quickly to changes.',
      'Ti':
          'Introverted Thinking: Analyzes information logically and creates internal frameworks for understanding. Seeks logical consistency and precision.',
      'Te':
          'Extraverted Thinking: Organizes and systematizes the external world efficiently. Focuses on results, productivity, and logical organization.',
      'Fi':
          'Introverted Feeling: Evaluates based on personal values and maintains inner harmony. Has strong personal convictions and seeks authenticity.',
      'Fe':
          'Extraverted Feeling: Understands and responds to others\' emotions and creates group harmony. Naturally considers others\' feelings and social dynamics.',
    };

    final stackOrder = _getCognitiveStack(mbtiType).split('-');

    return {
      'dominant':
          '${stackOrder[0]}: ${functionMappings[stackOrder[0]] ?? 'Unknown function'}',
      'auxiliary':
          '${stackOrder[1]}: ${functionMappings[stackOrder[1]] ?? 'Unknown function'}',
      'tertiary':
          '${stackOrder[2]}: ${functionMappings[stackOrder[2]] ?? 'Unknown function'}',
      'inferior':
          '${stackOrder[3]}: ${functionMappings[stackOrder[3]] ?? 'Unknown function'}',
    };
  }

  // Get detailed personality explanation
  String getDetailedPersonalityExplanation(String mbtiType) {
    final explanations = {
      'INTJ':
          'You are "The Architect" - a strategic, independent, and highly analytical visionary. You see possibilities for improvement everywhere and have a natural gift for seeing the big picture and developing long-term plans. Your mind works like a master strategist, constantly analyzing patterns and developing comprehensive plans for the future.',
      'INTP':
          'You are "The Thinker" - a logical, innovative, and curious individual who loves exploring theoretical concepts. You are driven by a desire to understand the underlying principles of everything around you. Your mind works like a sophisticated analytical engine, constantly questioning and seeking to understand.',
      'ENTJ':
          'You are "The Commander" - a bold, strategic, and natural-born leader. You excel at organizing people and resources to achieve ambitious goals. Your mind works like a master orchestrator, seeing the big picture and efficiently organizing everything to achieve success.',
      'ENTP':
          'You are "The Debater" - an innovative, enthusiastic, and strategic thinker. You thrive on intellectual challenges and generating creative solutions. Your mind works like an idea generator, constantly exploring possibilities and connecting seemingly unrelated concepts.',
      'INFJ':
          'You are "The Advocate" - an insightful, principled, and creative individual. You have a unique ability to inspire and guide others toward meaningful goals. Your mind works like a visionary compass, seeing future possibilities while staying true to your deep values.',
      'INFP':
          'You are "The Mediator" - an idealistic, loyal, and creative individual driven by your values. You seek to make the world a better place and find authenticity in everything you do. Your mind works like a values-driven artist, creating meaning and seeking authentic expression.',
      'ENFJ':
          'You are "The Protagonist" - a charismatic, altruistic, and inspiring leader. You have a natural gift for motivating others and building strong relationships. Your mind works like a people orchestrator, seeing potential in others and inspiring them to achieve it.',
      'ENFP':
          'You are "The Campaigner" - an enthusiastic, creative, and people-focused individual. You excel at inspiring others and generating innovative ideas. Your mind works like an enthusiasm engine, spreading energy and inspiring others while generating creative possibilities.',
      'ISTJ':
          'You are "The Logistician" - a practical, reliable, and methodical individual. You excel at organizing, planning, and ensuring everything runs smoothly. Your mind works like a precision organizer, creating systematic approaches and maintaining stability.',
      'ISFJ':
          'You are "The Protector" - a caring, loyal, and detail-oriented individual. You have a natural gift for supporting others and maintaining harmony. Your mind works like a caring guardian, always considering how to help and protect others.',
      'ESTJ':
          'You are "The Executive" - an organized, practical, and decisive individual. You excel at managing people and resources to achieve concrete results. Your mind works like an efficient manager, organizing systems and people to achieve clear objectives.',
      'ESFJ':
          'You are "The Consul" - a caring, sociable, and helpful individual. You thrive on building relationships and creating harmony in your environment. Your mind works like a social harmonizer, constantly considering others\' needs and building connections.',
      'ISTP':
          'You are "The Virtuoso" - a practical, observant, and adaptable individual. You excel at understanding how things work and solving practical problems. Your mind works like a master craftsperson, analyzing systems and finding practical solutions.',
      'ISFP':
          'You are "The Adventurer" - an artistic, gentle, and flexible individual driven by your values. You seek authentic self-expression and value beauty and harmony. Your mind works like an artist\'s palette, creating authentic expressions while staying true to your values.',
      'ESTP':
          'You are "The Entrepreneur" - an energetic, practical, and adaptable individual. You thrive in dynamic environments and excel at seizing opportunities. Your mind works like an opportunity detector, quickly responding to immediate situations and possibilities.',
      'ESFP':
          'You are "The Entertainer" - an enthusiastic, spontaneous, and people-focused individual. You bring joy and excitement to every situation. Your mind works like a joy spreader, naturally creating positive experiences and connecting with others.',
    };

    return explanations[mbtiType] ??
        'You have a unique personality type with distinctive strengths and characteristics.';
  }

  // Get personality type URLs for more information
  String getPersonalityTypeUrl(String mbtiType) {
    // Using reliable MBTI information sources
    return 'https://www.16personalities.com/${mbtiType.toLowerCase()}-personality';
  }

  // Get famous people with the same type
  List<String> getFamousExamples(String mbtiType) {
    final examples = {
      'INTJ': [
        'Elon Musk',
        'Isaac Newton',
        'Nikola Tesla',
        'Friedrich Nietzsche',
        'Ayn Rand',
      ],
      'INTP': [
        'Albert Einstein',
        'Bill Gates',
        'Abraham Lincoln',
        'Charles Darwin',
        'Marie Curie',
      ],
      'ENTJ': [
        'Steve Jobs',
        'Franklin D. Roosevelt',
        'Margaret Thatcher',
        'Napoleon Bonaparte',
        'Gordon Ramsay',
      ],
      'ENTP': [
        'Mark Twain',
        'Walt Disney',
        'Thomas Edison',
        'Benjamin Franklin',
        'Richard Feynman',
      ],
      'INFJ': [
        'Martin Luther King Jr.',
        'Nelson Mandela',
        'Mother Teresa',
        'Mahatma Gandhi',
        'Carl Jung',
      ],
      'INFP': [
        'William Shakespeare',
        'J.R.R. Tolkien',
        'Vincent van Gogh',
        'Johnny Depp',
        'Kurt Cobain',
      ],
      'ENFJ': [
        'Oprah Winfrey',
        'Barack Obama',
        'Maya Angelou',
        'John F. Kennedy',
        'Malala Yousafzai',
      ],
      'ENFP': [
        'Robin Williams',
        'Ellen DeGeneres',
        'Will Smith',
        'Quentin Tarantino',
        'Robert Downey Jr.',
      ],
      'ISTJ': [
        'George Washington',
        'Warren Buffett',
        'Condoleezza Rice',
        'Jeff Bezos',
        'Natalie Portman',
      ],
      'ISFJ': [
        'Mother Teresa',
        'Kate Middleton',
        'Jimmy Carter',
        'Captain America',
        'Selena Gomez',
      ],
      'ESTJ': [
        'Henry Ford',
        'John D. Rockefeller',
        'Frank Sinatra',
        'Judge Judy',
        'Vince Lombardi',
      ],
      'ESFJ': [
        'Taylor Swift',
        'Bill Clinton',
        'Jennifer Garner',
        'Danny Glover',
        'Mary Tyler Moore',
      ],
      'ISTP': [
        'Clint Eastwood',
        'Michael Jordan',
        'Tiger Woods',
        'Amelia Earhart',
        'Steve Jobs',
      ],
      'ISFP': [
        'Michael Jackson',
        'Rihanna',
        'Bob Dylan',
        'Frida Kahlo',
        'Avril Lavigne',
      ],
      'ESTP': [
        'Donald Trump',
        'Madonna',
        'Eddie Murphy',
        'Bruce Willis',
        'Samuel L. Jackson',
      ],
      'ESFP': [
        'Marilyn Monroe',
        'Elvis Presley',
        'Justin Bieber',
        'Katy Perry',
        'Adele',
      ],
    };

    return examples[mbtiType] ?? ['Various influential people'];
  }

  // Get career suggestions
  List<String> _getCareerSuggestions(String mbtiType) {
    final careers = {
      'INTJ': [
        'Software Architect',
        'Research Scientist',
        'Strategic Planner',
        'Systems Analyst',
        'Investment Banker',
        'Professor',
      ],
      'INTP': [
        'Software Developer',
        'Research Scientist',
        'Data Analyst',
        'University Professor',
        'Philosopher',
        'Technical Writer',
      ],
      'ENTJ': [
        'CEO',
        'Executive',
        'Management Consultant',
        'Investment Banker',
        'Attorney',
        'Project Manager',
      ],
      'ENTP': [
        'Entrepreneur',
        'Marketing Manager',
        'Journalist',
        'Lawyer',
        'Psychologist',
        'Inventor',
      ],
      'INFJ': [
        'Counselor',
        'Writer',
        'Social Worker',
        'Teacher',
        'Psychologist',
        'Human Rights Advocate',
      ],
      'INFP': [
        'Writer',
        'Artist',
        'Counselor',
        'Social Worker',
        'Journalist',
        'Environmental Scientist',
      ],
      'ENFJ': [
        'Teacher',
        'Counselor',
        'Social Worker',
        'HR Manager',
        'Public Relations',
        'Life Coach',
      ],
      'ENFP': [
        'Marketing Manager',
        'Journalist',
        'Actor',
        'Teacher',
        'Social Worker',
        'Event Planner',
      ],
      'ISTJ': [
        'Accountant',
        'Engineer',
        'Manager',
        'Administrator',
        'Auditor',
        'Project Manager',
      ],
      'ISFJ': [
        'Nurse',
        'Teacher',
        'Social Worker',
        'Administrator',
        'Counselor',
        'Human Resources',
      ],
      'ESTJ': [
        'Manager',
        'Administrator',
        'Executive',
        'Sales Manager',
        'Military Officer',
        'Judge',
      ],
      'ESFJ': [
        'Teacher',
        'Nurse',
        'Social Worker',
        'Event Planner',
        'HR Manager',
        'Counselor',
      ],
      'ISTP': [
        'Engineer',
        'Mechanic',
        'Technician',
        'Pilot',
        'Carpenter',
        'Software Developer',
      ],
      'ISFP': [
        'Artist',
        'Designer',
        'Musician',
        'Counselor',
        'Teacher',
        'Photographer',
      ],
      'ESTP': [
        'Sales Manager',
        'Entrepreneur',
        'Police Officer',
        'Paramedic',
        'Coach',
        'Real Estate Agent',
      ],
      'ESFP': [
        'Teacher',
        'Actor',
        'Event Planner',
        'Social Worker',
        'Photographer',
        'Tour Guide',
      ],
    };

    return careers[mbtiType] ?? ['Consultant', 'Analyst', 'Specialist'];
  }
}

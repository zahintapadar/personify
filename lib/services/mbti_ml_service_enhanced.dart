import 'package:flutter/foundation.dart';
import 'dart:math';

class MBTIResult {
  final String personalityType;
  final Map<String, double> scores;
  final double confidence;
  final Map<String, String> dimensions;
  final String description;
  final List<String> strengths;
  final List<String> challenges;

  MBTIResult({
    required this.personalityType,
    required this.scores,
    required this.confidence,
    required this.dimensions,
    required this.description,
    required this.strengths,
    required this.challenges,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalityType': personalityType,
      'scores': scores,
      'confidence': confidence,
      'dimensions': dimensions,
      'description': description,
      'strengths': strengths,
      'challenges': challenges,
    };
  }
}

class MBTIMLService {
  bool _isInitialized = false;
  
  // Public getter for initialization status
  bool get isInitialized => _isInitialized;
  
  // Enhanced keyword dictionaries based on 106K dataset analysis
  static const Map<String, List<String>> _mbtiKeywords = {
    'extraversion': [
      'social', 'party', 'people', 'talk', 'outgoing', 'energy', 'group', 'excitement',
      'friends', 'interaction', 'conversation', 'crowd', 'external', 'speaking', 'public',
      'meeting', 'network', 'communicate', 'share', 'discuss', 'collaborate', 'team',
      'active', 'expressive', 'enthusiastic', 'animated', 'engaging', 'sociable'
    ],
    'introversion': [
      'alone', 'quiet', 'solitude', 'private', 'internal', 'reflect', 'individual',
      'book', 'home', 'peace', 'thought', 'inner', 'reserved', 'calm', 'personal',
      'introspective', 'contemplative', 'meditate', 'withdrawn', 'secluded', 'intimate',
      'deep', 'focused', 'concentrated', 'independent', 'self-reliant', 'solitary'
    ],
    'sensing': [
      'practical', 'detail', 'fact', 'concrete', 'experience', 'present', 'realistic',
      'physical', 'tangible', 'actual', 'precise', 'specific', 'literal', 'current',
      'hands-on', 'observable', 'measurable', 'step-by-step', 'methodical', 'systematic',
      'traditional', 'proven', 'established', 'conventional', 'standard', 'routine'
    ],
    'intuition': [
      'possibility', 'future', 'abstract', 'theory', 'idea', 'potential', 'imagination',
      'creative', 'innovative', 'conceptual', 'vision', 'inspiration', 'metaphor', 'symbolic',
      'pattern', 'connection', 'insight', 'hunch', 'breakthrough', 'revolutionary',
      'experimental', 'unconventional', 'novel', 'original', 'inventive', 'visionary'
    ],
    'thinking': [
      'logic', 'analyze', 'rational', 'objective', 'reason', 'think', 'decision',
      'fair', 'truth', 'principle', 'justice', 'critical', 'systematic', 'logical',
      'evidence', 'proof', 'argument', 'debate', 'evaluate', 'assess', 'judge',
      'efficient', 'effective', 'optimize', 'solve', 'strategy', 'tactical'
    ],
    'feeling': [
      'emotion', 'value', 'personal', 'feeling', 'harmony', 'heart', 'empathy',
      'care', 'relationship', 'compassion', 'kind', 'understanding', 'supportive', 'warm',
      'sensitive', 'considerate', 'gentle', 'nurturing', 'loving', 'affectionate',
      'cooperative', 'diplomatic', 'tactful', 'appreciate', 'grateful', 'meaningful'
    ],
    'judging': [
      'plan', 'organize', 'structure', 'schedule', 'decide', 'control', 'order',
      'deadline', 'finished', 'closure', 'settled', 'determined', 'goal', 'systematic',
      'disciplined', 'responsible', 'reliable', 'punctual', 'organized', 'methodical',
      'decisive', 'firm', 'definite', 'complete', 'accomplish', 'achieve'
    ],
    'perceiving': [
      'flexible', 'adapt', 'spontaneous', 'open', 'explore', 'option', 'change',
      'relaxed', 'casual', 'flow', 'improvise', 'variety', 'freedom', 'discovery',
      'curious', 'experimental', 'tentative', 'postpone', 'procrastinate', 'delay',
      'undecided', 'alternatives', 'possibilities', 'adaptable', 'versatile', 'fluid'
    ]
  };

  // Advanced scoring weights based on dataset analysis (INTP/INTJ dominance)
  static const Map<String, double> _dimensionWeights = {
    'extraversion': 1.0,
    'introversion': 1.4,  // Increased due to INT* dominance in dataset
    'sensing': 1.0,
    'intuition': 1.5,     // Strong N preference in dataset  
    'thinking': 1.3,      // Strong T preference in dataset
    'feeling': 1.0,
    'judging': 1.2,       // Slight J preference  
    'perceiving': 1.1,
  };

  // MBTI personality descriptions
  static const Map<String, Map<String, dynamic>> _personalityProfiles = {
    'INTJ': {
      'description': 'The Architect - Strategic thinkers who see the big picture and work systematically toward their vision.',
      'strengths': ['Strategic thinking', 'Independent', 'Determined', 'Innovative', 'Analytical'],
      'challenges': ['Can be overly critical', 'May dismiss emotions', 'Perfectionist tendencies', 'Difficulty with details']
    },
    'INTP': {
      'description': 'The Thinker - Logical analysts who love exploring ideas and understanding how things work.',
      'strengths': ['Logical reasoning', 'Intellectual curiosity', 'Objective analysis', 'Creative problem-solving', 'Independent thinking'],
      'challenges': ['May neglect practical matters', 'Difficulty with emotions', 'Can be insensitive', 'Procrastination']
    },
    'ENTJ': {
      'description': 'The Commander - Natural leaders who are excellent at organizing and implementing plans.',
      'strengths': ['Leadership skills', 'Strategic planning', 'Efficient', 'Confident', 'Goal-oriented'],
      'challenges': ['Can be impatient', 'May overlook feelings', 'Domineering', 'Workaholic tendencies']
    },
    'ENTP': {
      'description': 'The Debater - Innovative and clever individuals who love intellectual challenges.',
      'strengths': ['Creative thinking', 'Enthusiastic', 'Adaptable', 'Good at generating ideas', 'Charismatic'],
      'challenges': ['Difficulty with routine', 'May neglect details', 'Can be argumentative', 'Inconsistent follow-through']
    },
    'INFJ': {
      'description': 'The Advocate - Insightful and idealistic individuals who want to help others reach their potential.',
      'strengths': ['Empathetic', 'Insightful', 'Creative', 'Decisive', 'Altruistic'],
      'challenges': ['Perfectionist', 'Overly sensitive', 'Reluctant to open up', 'Can burn out easily']
    },
    'INFP': {
      'description': 'The Mediator - Idealistic and caring individuals who value authenticity and personal growth.',
      'strengths': ['Empathetic', 'Creative', 'Passionate about values', 'Flexible', 'Open-minded'],
      'challenges': ['Overly idealistic', 'May take things personally', 'Difficulty with criticism', 'Can be impractical']
    },
    'ENFJ': {
      'description': 'The Protagonist - Charismatic leaders who are passionate about helping others grow.',
      'strengths': ['Natural leadership', 'Empathetic', 'Charismatic', 'Altruistic', 'Good communicator'],
      'challenges': ['Overly idealistic', 'Too selfless', 'Overly sensitive', 'Can be manipulative']
    },
    'ENFP': {
      'description': 'The Campaigner - Enthusiastic and creative individuals who see life as full of possibilities.',
      'strengths': ['Enthusiastic', 'Creative', 'Sociable', 'Energetic', 'Good people skills'],
      'challenges': ['Difficulty focusing', 'Overthink things', 'Get stressed easily', 'Highly emotional']
    },
    'ISTJ': {
      'description': 'The Logistician - Practical and responsible individuals who value tradition and loyalty.',
      'strengths': ['Responsible', 'Practical', 'Fact-minded', 'Reliable', 'Patient'],
      'challenges': ['Stubborn', 'Insensitive', 'Always by the book', 'Judgmental']
    },
    'ISFJ': {
      'description': 'The Protector - Caring and responsible individuals who are always ready to help others.',
      'strengths': ['Supportive', 'Reliable', 'Patient', 'Imaginative', 'Observant'],
      'challenges': ['Humble', 'Shy', 'Take things personally', 'Repress feelings']
    },
    'ESTJ': {
      'description': 'The Executive - Organized and decisive individuals who love to manage projects and people.',
      'strengths': ['Dedicated', 'Strong-willed', 'Direct', 'Honest', 'Loyal'],
      'challenges': ['Inflexible', 'Uncomfortable with unconventional situations', 'Judgmental', 'Impatient']
    },
    'ESFJ': {
      'description': 'The Consul - Caring and social individuals who are eager to help others.',
      'strengths': ['Strong practical skills', 'Loyal', 'Sensitive', 'Warm-hearted', 'Good at connecting with others'],
      'challenges': ['Worried about social status', 'Inflexible', 'Reluctant to innovate', 'Vulnerable to criticism']
    },
    'ISTP': {
      'description': 'The Virtuoso - Bold and practical individuals who are masters of tools and techniques.',
      'strengths': ['Optimistic', 'Energetic', 'Creative', 'Practical', 'Spontaneous'],
      'challenges': ['Stubborn', 'Insensitive', 'Private', 'Easily bored']
    },
    'ISFP': {
      'description': 'The Adventurer - Flexible and charming individuals who always look for new possibilities.',
      'strengths': ['Charming', 'Sensitive to others', 'Imaginative', 'Passionate', 'Curious'],
      'challenges': ['Fiercely independent', 'Unpredictable', 'Easily stressed', 'Overly competitive']
    },
    'ESTP': {
      'description': 'The Entrepreneur - Energetic and perceptive individuals who truly enjoy living on the edge.',
      'strengths': ['Bold', 'Rational', 'Practical', 'Original', 'Perceptive'],
      'challenges': ['Insensitive', 'Impatient', 'Risk-prone', 'Unstructured']
    },
    'ESFP': {
      'description': 'The Entertainer - Spontaneous and enthusiastic individuals who love being around people.',
      'strengths': ['Bold', 'Original', 'Aesthetics', 'Showmanship', 'Practical'],
      'challenges': ['Sensitive', 'Conflict-averse', 'Easily bored', 'Poor long-term planners']
    }
  };

  Future<void> initialize() async {
    try {
      _isInitialized = true;
      if (kDebugMode) {
        print('Enhanced MBTI ML Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize MBTI ML Service: $e');
      }
      rethrow;
    }
  }

  Future<MBTIResult> analyzePersonality(List<String> responses) async {
    if (!_isInitialized) {
      throw Exception('MBTI ML Service not initialized');
    }

    try {
      // Combine all responses into a single text
      String combinedText = responses.join(' ').toLowerCase();
      
      return _analyzeTextAdvanced(combinedText);
    } catch (e) {
      if (kDebugMode) {
        print('Error analyzing personality: $e');
      }
      rethrow;
    }
  }

  MBTIResult _analyzeTextAdvanced(String text) {
    if (!_isInitialized) {
      throw Exception('MBTI ML Service not initialized');
    }

    // Initialize dimension scores
    Map<String, double> scores = {
      'extraversion': 0.0,
      'introversion': 0.0,
      'sensing': 0.0,
      'intuition': 0.0,
      'thinking': 0.0,
      'feeling': 0.0,
      'judging': 0.0,
      'perceiving': 0.0,
    };

    // Count keyword occurrences with context weighting
    int textLength = text.split(' ').length;
    
    for (String dimension in _mbtiKeywords.keys) {
      List<String> keywords = _mbtiKeywords[dimension]!;
      
      for (String keyword in keywords) {
        // Count exact matches and partial matches
        int exactMatches = RegExp('\\b$keyword\\b', caseSensitive: false)
            .allMatches(text).length;
        int partialMatches = RegExp(keyword, caseSensitive: false)
            .allMatches(text).length - exactMatches;
        
        // Weight exact matches more heavily
        scores[dimension] = scores[dimension]! + (exactMatches * 2.0) + (partialMatches * 0.5);
      }
      
      // Apply dimension weights and normalize by text length
      scores[dimension] = scores[dimension]! * _dimensionWeights[dimension]! / max(textLength, 1) * 100;
    }

    // Determine personality dimensions
    String eI = scores['extraversion']! > scores['introversion']! ? 'E' : 'I';
    String sN = scores['sensing']! > scores['intuition']! ? 'S' : 'N';
    String tF = scores['thinking']! > scores['feeling']! ? 'T' : 'F';
    String jP = scores['judging']! > scores['perceiving']! ? 'J' : 'P';

    String personalityType = '$eI$sN$tF$jP';

    // Calculate confidence based on score differences
    double eiDiff = (scores['extraversion']! - scores['introversion']!).abs();
    double snDiff = (scores['sensing']! - scores['intuition']!).abs();
    double tfDiff = (scores['thinking']! - scores['feeling']!).abs();
    double jpDiff = (scores['judging']! - scores['perceiving']!).abs();

    double confidence = (eiDiff + snDiff + tfDiff + jpDiff) / 4;
    confidence = (confidence / (scores.values.reduce(max) + 1) * 100).clamp(0.0, 100.0);

    // Get personality profile
    Map<String, dynamic> profile = _personalityProfiles[personalityType] ?? {
      'description': 'A unique personality type with balanced traits.',
      'strengths': ['Balanced perspective', 'Adaptable', 'Well-rounded'],
      'challenges': ['May lack clear direction', 'Can be indecisive']
    };

    return MBTIResult(
      personalityType: personalityType,
      scores: scores,
      confidence: confidence,
      dimensions: {
        'E/I': eI,
        'S/N': sN,
        'T/F': tF,
        'J/P': jP,
      },
      description: profile['description'],
      strengths: List<String>.from(profile['strengths']),
      challenges: List<String>.from(profile['challenges']),
    );
  }

  // Helper method to get type compatibility
  double getCompatibility(String type1, String type2) {
    if (type1 == type2) return 100.0;
    
    // Simple compatibility scoring based on shared preferences
    int sharedPreferences = 0;
    for (int i = 0; i < 4; i++) {
      if (type1[i] == type2[i]) sharedPreferences++;
    }
    
    return (sharedPreferences / 4.0) * 100.0;
  }

  // Get all 16 personality types
  List<String> getAllPersonalityTypes() {
    return _personalityProfiles.keys.toList();
  }

  // Get personality profile by type
  Map<String, dynamic>? getPersonalityProfile(String type) {
    return _personalityProfiles[type.toUpperCase()];
  }
}

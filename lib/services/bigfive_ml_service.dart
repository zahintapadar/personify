import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class BigFiveMLService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  // Cluster labels and personality types from the trained model
  static const Map<int, String> _clusterLabels = {
    0: 'Neurotic Agreeable',
    1: 'Extraverted Agreeable', 
    2: 'Introverted Neurotic',
    3: 'Agreeable Open',
    4: 'Introverted Agreeable',
    5: 'Introverted Competitive',
    6: 'Extraverted Stable',
  };

  static const Map<int, String> _personalityDescriptions = {
    0: 'The Empathetic Worrier - You are deeply caring and sensitive to others\' needs, though you may experience emotions intensely.',
    1: 'The Social Harmonizer - You are outgoing, friendly, and skilled at bringing people together in positive ways.',
    2: 'The Thoughtful Introvert - You prefer quiet reflection and may be more sensitive to stress, but you think deeply about life.',
    3: 'The Creative Collaborator - You are open to new experiences while maintaining strong cooperative relationships with others.',
    4: 'The Gentle Soul - You are kind, considerate, and prefer meaningful one-on-one connections over large social gatherings.',
    5: 'The Independent Thinker - You are self-reliant and analytical, comfortable working alone and thinking critically.',
    6: 'The Confident Leader - You are emotionally stable, outgoing, and naturally drawn to leadership and social situations.',
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the TensorFlow Lite model
      _interpreter = await Interpreter.fromAsset('models/bigfive_clustering_model.tflite');
      _isInitialized = true;
      
      debugPrint('BigFive ML Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing BigFive ML Service: $e');
      // Continue without ML for graceful degradation
      _isInitialized = false;
    }
  }

  Future<Map<String, dynamic>> predictPersonality(Map<String, double> traitScores) async {
    try {
      if (!_isInitialized || _interpreter == null) {
        // Fallback prediction without ML
        return _fallbackPrediction(traitScores);
      }

      // Prepare input data: [O, C, E, A, N, age, gender]
      // Using default demographics since we don't collect them
      final input = Float32List.fromList([
        traitScores['O'] ?? 0.0,
        traitScores['C'] ?? 0.0,
        traitScores['E'] ?? 0.0,
        traitScores['A'] ?? 0.0,
        traitScores['N'] ?? 0.0,
        25.0, // Default age
        0.5,  // Default gender (neutral)
      ]);

      // Prepare output buffer for 7 clusters
      var output = List.filled(7, 0.0).reshape([1, 7]);

      // Run inference
      _interpreter!.run(input.reshape([1, 7]), output);

      // Get probabilities
      List<double> probabilities = output[0].cast<double>();
      
      // Find the cluster with highest probability
      int predictedCluster = 0;
      double maxProbability = probabilities[0];
      
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProbability) {
          maxProbability = probabilities[i];
          predictedCluster = i;
        }
      }

      // Calculate confidence as the max probability
      double confidence = maxProbability * 100;

      // Create probability map
      Map<String, double> clusterProbabilities = {};
      for (int i = 0; i < probabilities.length; i++) {
        String clusterName = _clusterLabels[i] ?? 'Unknown';
        clusterProbabilities[clusterName] = probabilities[i];
      }

      return {
        'cluster': _clusterLabels[predictedCluster] ?? 'Unknown',
        'personalityType': _personalityDescriptions[predictedCluster] ?? 'Unique Individual',
        'confidence': confidence,
        'probabilities': clusterProbabilities,
        'mlUsed': true,
      };

    } catch (e) {
      debugPrint('Error in BigFive ML prediction: $e');
      return _fallbackPrediction(traitScores);
    }
  }

  Map<String, dynamic> _fallbackPrediction(Map<String, double> traitScores) {
    // Rule-based fallback when ML is not available
    String personalityType = _determineFallbackPersonality(traitScores);
    
    return {
      'cluster': 'Rule-Based Classification',
      'personalityType': personalityType,
      'confidence': 75.0, // Default confidence for rule-based
      'probabilities': <String, double>{},
      'mlUsed': false,
    };
  }

  String _determineFallbackPersonality(Map<String, double> traitScores) {
    double o = traitScores['O'] ?? 0.0;
    double c = traitScores['C'] ?? 0.0;
    double e = traitScores['E'] ?? 0.0;
    double a = traitScores['A'] ?? 0.0;
    double n = traitScores['N'] ?? 0.0;

    // Simple rule-based classification
    if (e > 1.0 && a > 1.0 && n < 0.0) {
      return 'The Social Harmonizer - You are outgoing, friendly, and emotionally stable.';
    } else if (e < -1.0 && c > 1.0 && n < 0.0) {
      return 'The Organized Introvert - You are detail-oriented, reliable, and prefer quiet environments.';
    } else if (o > 1.0 && a > 1.0) {
      return 'The Creative Collaborator - You are imaginative, open-minded, and enjoy working with others.';
    } else if (n > 1.0 && a > 1.0) {
      return 'The Empathetic Worrier - You care deeply about others but may experience stress intensely.';
    } else if (e < -1.0 && a > 1.0) {
      return 'The Gentle Soul - You are kind and thoughtful, preferring meaningful connections.';
    } else if (e > 1.0 && c > 1.0) {
      return 'The Confident Leader - You are organized, outgoing, and naturally take charge.';
    } else if (e < -1.0 && a < 0.0) {
      return 'The Independent Thinker - You are self-reliant and analytical, comfortable working alone.';
    } else {
      return 'The Balanced Individual - You show a healthy balance across personality traits.';
    }
  }

  // Get personality insights based on trait scores
  Map<String, List<String>> getPersonalityInsights(Map<String, double> traitScores) {
    List<String> strengths = [];
    List<String> growthAreas = [];

    // Analyze each trait
    for (String trait in ['O', 'C', 'E', 'A', 'N']) {
      double score = traitScores[trait] ?? 0.0;
      
      switch (trait) {
        case 'O': // Openness
          if (score > 1.0) {
            strengths.addAll(['Creative thinking', 'Open to new experiences', 'Imaginative']);
          } else if (score < -1.0) {
            growthAreas.addAll(['Try new experiences', 'Practice creative thinking']);
          }
          break;
          
        case 'C': // Conscientiousness
          if (score > 1.0) {
            strengths.addAll(['Highly organized', 'Reliable', 'Goal-oriented']);
          } else if (score < -1.0) {
            growthAreas.addAll(['Improve organization', 'Set clear goals']);
          }
          break;
          
        case 'E': // Extraversion
          if (score > 1.0) {
            strengths.addAll(['Strong social skills', 'Natural leadership', 'Energetic']);
          } else if (score < -1.0) {
            growthAreas.addAll(['Practice social interaction', 'Share ideas more']);
          }
          break;
          
        case 'A': // Agreeableness
          if (score > 1.0) {
            strengths.addAll(['Empathetic', 'Team player', 'Cooperative']);
          } else if (score < -1.0) {
            growthAreas.addAll(['Practice empathy', 'Collaborate more']);
          }
          break;
          
        case 'N': // Neuroticism
          if (score < -1.0) {
            strengths.addAll(['Emotionally stable', 'Stress resilient', 'Calm']);
          } else if (score > 1.0) {
            growthAreas.addAll(['Develop stress management', 'Practice emotional regulation']);
          }
          break;
      }
    }

    return {
      'strengths': strengths.take(6).toList(),
      'growthAreas': growthAreas.take(5).toList(),
    };
  }

  // Get career suggestions based on trait profile
  List<String> getCareerSuggestions(Map<String, double> traitScores) {
    List<String> careers = [];
    
    double o = traitScores['O'] ?? 0.0;
    double c = traitScores['C'] ?? 0.0;
    double e = traitScores['E'] ?? 0.0;
    double a = traitScores['A'] ?? 0.0;
    double n = traitScores['N'] ?? 0.0;

    // High Openness careers
    if (o > 1.0) {
      careers.addAll(['Creative Director', 'Research Scientist', 'Artist/Designer']);
    }

    // High Conscientiousness careers
    if (c > 1.0) {
      careers.addAll(['Project Manager', 'Accountant', 'Engineer']);
    }

    // High Extraversion careers
    if (e > 1.0) {
      careers.addAll(['Sales Manager', 'Public Relations', 'Teacher/Trainer']);
    }

    // High Agreeableness careers
    if (a > 1.0) {
      careers.addAll(['Counselor/Therapist', 'Social Worker', 'Human Resources']);
    }

    // Low Neuroticism (high emotional stability) careers
    if (n < -1.0) {
      careers.addAll(['Emergency Responder', 'Surgeon', 'CEO/Executive']);
    }

    // Default careers if no strong traits
    if (careers.isEmpty) {
      careers.addAll([
        'Business Analyst',
        'Marketing Coordinator', 
        'Software Developer',
        'Operations Manager',
        'Customer Success Manager',
        'Data Analyst'
      ]);
    }

    return careers.take(6).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

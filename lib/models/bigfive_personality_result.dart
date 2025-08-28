class BigFivePersonalityResult {
  final Map<String, double> traitScores; // O, C, E, A, N scores
  final String dominantCluster; // Main personality cluster
  final String personalityType; // Human-readable type name
  final double confidence;
  final Map<String, double> clusterProbabilities;
  final DateTime timestamp;
  final List<Map<String, dynamic>> answers;

  const BigFivePersonalityResult({
    required this.traitScores,
    required this.dominantCluster,
    required this.personalityType,
    required this.confidence,
    required this.clusterProbabilities,
    required this.timestamp,
    required this.answers,
  });

  // Get trait score for a specific trait
  double getTraitScore(String trait) {
    return traitScores[trait.toUpperCase()] ?? 0.0;
  }

  // Get trait percentile (0-100)
  double getTraitPercentile(String trait) {
    final score = getTraitScore(trait);
    // Convert score to percentile (assuming scores are roughly -3 to +3)
    return ((score + 3.0) / 6.0 * 100).clamp(0.0, 100.0);
  }

  // Get trait level description
  String getTraitLevel(String trait) {
    final percentile = getTraitPercentile(trait);
    if (percentile >= 80) return 'Very High';
    if (percentile >= 60) return 'High';
    if (percentile >= 40) return 'Moderate';
    if (percentile >= 20) return 'Low';
    return 'Very Low';
  }

  // Get trait description
  String getTraitDescription(String trait) {
    final level = getTraitLevel(trait);
    final traitUpper = trait.toUpperCase();
    
    switch (traitUpper) {
      case 'O': // Openness
        return level == 'Very High' || level == 'High'
            ? 'You are very open to new experiences, creative, and imaginative. You enjoy exploring ideas and trying new things.'
            : 'You tend to prefer familiar experiences and practical approaches. You value tradition and established ways of doing things.';
      
      case 'C': // Conscientiousness
        return level == 'Very High' || level == 'High'
            ? 'You are highly organized, disciplined, and goal-oriented. You plan ahead and follow through on commitments.'
            : 'You tend to be more spontaneous and flexible. You prefer to go with the flow rather than stick to rigid plans.';
      
      case 'E': // Extraversion
        return level == 'Very High' || level == 'High'
            ? 'You are outgoing, energetic, and sociable. You gain energy from being around people and enjoy being the center of attention.'
            : 'You are more reserved and introspective. You prefer smaller groups and quieter activities, and gain energy from solitude.';
      
      case 'A': // Agreeableness
        return level == 'Very High' || level == 'High'
            ? 'You are compassionate, trusting, and cooperative. You tend to see the best in people and prefer harmony in relationships.'
            : 'You tend to be more skeptical and competitive. You value honesty over diplomacy and are willing to challenge others when necessary.';
      
      case 'N': // Neuroticism
        return level == 'Very High' || level == 'High'
            ? 'You tend to experience emotions intensely and may be more sensitive to stress. You are deeply empathetic and emotionally aware.'
            : 'You tend to be emotionally stable and resilient. You remain calm under pressure and recover quickly from setbacks.';
      
      default:
        return 'Unknown trait description.';
    }
  }

  // Get strengths based on dominant traits
  List<String> getStrengths() {
    List<String> strengths = [];
    
    if (getTraitPercentile('O') >= 60) {
      strengths.addAll(['Creative thinking', 'Open to new ideas', 'Imaginative problem-solving']);
    }
    if (getTraitPercentile('C') >= 60) {
      strengths.addAll(['Highly organized', 'Reliable and dependable', 'Goal-oriented']);
    }
    if (getTraitPercentile('E') >= 60) {
      strengths.addAll(['Strong social skills', 'Natural leadership', 'Energetic and enthusiastic']);
    }
    if (getTraitPercentile('A') >= 60) {
      strengths.addAll(['Empathetic and caring', 'Team player', 'Conflict resolution']);
    }
    if (getTraitPercentile('N') <= 40) {
      strengths.addAll(['Emotionally stable', 'Stress resilient', 'Calm under pressure']);
    }
    
    return strengths.take(6).toList();
  }

  // Get growth areas based on lower traits
  List<String> getGrowthAreas() {
    List<String> growthAreas = [];
    
    if (getTraitPercentile('O') <= 40) {
      growthAreas.addAll(['Try new experiences', 'Practice creative thinking', 'Be more open to change']);
    }
    if (getTraitPercentile('C') <= 40) {
      growthAreas.addAll(['Improve organization skills', 'Set clear goals', 'Follow through on commitments']);
    }
    if (getTraitPercentile('E') <= 40) {
      growthAreas.addAll(['Practice social interaction', 'Take leadership opportunities', 'Share ideas more openly']);
    }
    if (getTraitPercentile('A') <= 40) {
      growthAreas.addAll(['Practice empathy', 'Collaborate more effectively', 'Consider others\' perspectives']);
    }
    if (getTraitPercentile('N') >= 60) {
      growthAreas.addAll(['Develop stress management', 'Practice emotional regulation', 'Build resilience']);
    }
    
    return growthAreas.take(5).toList();
  }

  BigFivePersonalityResult copyWith({
    Map<String, double>? traitScores,
    String? dominantCluster,
    String? personalityType,
    double? confidence,
    Map<String, double>? clusterProbabilities,
    DateTime? timestamp,
    List<Map<String, dynamic>>? answers,
  }) {
    return BigFivePersonalityResult(
      traitScores: traitScores ?? this.traitScores,
      dominantCluster: dominantCluster ?? this.dominantCluster,
      personalityType: personalityType ?? this.personalityType,
      confidence: confidence ?? this.confidence,
      clusterProbabilities: clusterProbabilities ?? this.clusterProbabilities,
      timestamp: timestamp ?? this.timestamp,
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traitScores': traitScores,
      'dominantCluster': dominantCluster,
      'personalityType': personalityType,
      'confidence': confidence,
      'clusterProbabilities': clusterProbabilities,
      'timestamp': timestamp.toIso8601String(),
      'answers': answers,
    };
  }

  factory BigFivePersonalityResult.fromJson(Map<String, dynamic> json) {
    return BigFivePersonalityResult(
      traitScores: Map<String, double>.from(json['traitScores'] as Map),
      dominantCluster: json['dominantCluster'] as String,
      personalityType: json['personalityType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      clusterProbabilities: Map<String, double>.from(json['clusterProbabilities'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      answers: List<Map<String, dynamic>>.from(json['answers'] as List),
    );
  }

  @override
  String toString() {
    return 'BigFivePersonalityResult(personalityType: $personalityType, confidence: ${confidence.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigFivePersonalityResult &&
        other.dominantCluster == dominantCluster &&
        other.personalityType == personalityType &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(dominantCluster, personalityType, confidence);
  }
}

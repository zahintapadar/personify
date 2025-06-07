class PersonalityResult {
  final String personalityType;
  final double confidence;
  final String description;
  final List<String> traits;
  final List<String> strengths;
  final List<String> tips;
  final Map<String, dynamic> answers;
  final DateTime timestamp;
  
  PersonalityResult({
    required this.personalityType,
    required this.confidence,
    required this.description,
    required this.traits,
    required this.strengths,
    required this.tips,
    required this.answers,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'personalityType': personalityType,
      'confidence': confidence,
      'description': description,
      'traits': traits,
      'strengths': strengths,
      'tips': tips,
      'answers': answers,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory PersonalityResult.fromJson(Map<String, dynamic> json) {
    return PersonalityResult(
      personalityType: json['personalityType'],
      confidence: json['confidence'],
      description: json['description'],
      traits: List<String>.from(json['traits']),
      strengths: List<String>.from(json['strengths'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      answers: Map<String, dynamic>.from(json['answers']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  String get confidencePercentage => '${(confidence * 100).toInt()}%';
}

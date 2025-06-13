class MBTIPersonalityResult {
  final String mbtiType;
  final double confidence;
  final String description;
  final List<String> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> tips;
  final Map<String, double> typeProbabilities;
  final Map<String, dynamic> answers;
  final DateTime timestamp;
  final String cognitiveStack;
  final List<String> careerSuggestions;

  MBTIPersonalityResult({
    required this.mbtiType,
    required this.confidence,
    required this.description,
    required this.traits,
    required this.strengths,
    required this.weaknesses,
    required this.tips,
    required this.typeProbabilities,
    required this.answers,
    required this.cognitiveStack,
    required this.careerSuggestions,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'mbtiType': mbtiType,
      'confidence': confidence,
      'description': description,
      'traits': traits,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'tips': tips,
      'typeProbabilities': typeProbabilities,
      'answers': answers,
      'timestamp': timestamp.toIso8601String(),
      'cognitiveStack': cognitiveStack,
      'careerSuggestions': careerSuggestions,
    };
  }

  factory MBTIPersonalityResult.fromJson(Map<String, dynamic> json) {
    return MBTIPersonalityResult(
      mbtiType: json['mbtiType'],
      confidence: json['confidence'],
      description: json['description'],
      traits: List<String>.from(json['traits']),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      typeProbabilities: Map<String, double>.from(json['typeProbabilities'] ?? {}),
      answers: Map<String, dynamic>.from(json['answers']),
      timestamp: DateTime.parse(json['timestamp']),
      cognitiveStack: json['cognitiveStack'] ?? '',
      careerSuggestions: List<String>.from(json['careerSuggestions'] ?? []),
    );
  }

  String get confidencePercentage => '${(confidence * 100).toInt()}%';
  
  String get dimensionBreakdown {
    final e = mbtiType[0] == 'E' ? 'Extraversion' : 'Introversion';
    final s = mbtiType[1] == 'S' ? 'Sensing' : 'Intuition';
    final t = mbtiType[2] == 'T' ? 'Thinking' : 'Feeling';
    final j = mbtiType[3] == 'J' ? 'Judging' : 'Perceiving';
    return '$e • $s • $t • $j';
  }

  List<String> get topAlternativeTypes {
    final sorted = typeProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted
        .where((entry) => entry.key != mbtiType)
        .take(3)
        .map((entry) => entry.key)
        .toList();
  }
}

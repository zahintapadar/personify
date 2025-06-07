class PersonalityQuestion {
  final String id;
  final String title;
  final String question;
  final List<String> options;
  final List<int> values;
  
  PersonalityQuestion({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
    required this.values,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'options': options,
      'values': values,
    };
  }
  
  factory PersonalityQuestion.fromJson(Map<String, dynamic> json) {
    return PersonalityQuestion(
      id: json['id'],
      title: json['title'],
      question: json['question'],
      options: List<String>.from(json['options']),
      values: List<int>.from(json['values']),
    );
  }
}

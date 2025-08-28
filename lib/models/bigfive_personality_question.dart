class BigFivePersonalityQuestion {
  final String id;
  final String title;
  final String question;
  final List<String> options;
  final List<int> values;
  final String trait; // 'O', 'C', 'E', 'A', 'N'
  final bool isReversed;

  const BigFivePersonalityQuestion({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
    required this.values,
    required this.trait,
    this.isReversed = false,
  });

  BigFivePersonalityQuestion copyWith({
    String? id,
    String? title,
    String? question,
    List<String>? options,
    List<int>? values,
    String? trait,
    bool? isReversed,
  }) {
    return BigFivePersonalityQuestion(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      options: options ?? this.options,
      values: values ?? this.values,
      trait: trait ?? this.trait,
      isReversed: isReversed ?? this.isReversed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'options': options,
      'values': values,
      'trait': trait,
      'isReversed': isReversed,
    };
  }

  factory BigFivePersonalityQuestion.fromJson(Map<String, dynamic> json) {
    return BigFivePersonalityQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      values: List<int>.from(json['values'] as List),
      trait: json['trait'] as String,
      isReversed: json['isReversed'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'BigFivePersonalityQuestion(id: $id, title: $title, trait: $trait, isReversed: $isReversed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigFivePersonalityQuestion &&
        other.id == id &&
        other.title == title &&
        other.question == question &&
        other.trait == trait &&
        other.isReversed == isReversed;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, question, trait, isReversed);
  }
}

class PersonalityQuestion {
  final String id;
  final String title;
  final String question;
  final PersonalityQuestionType type;
  final List<String>? options;
  final List<int>? values;
  final int? maxLength;
  final String? placeholder;

  PersonalityQuestion({
    required this.id,
    required this.title,
    required this.question,
    this.type = PersonalityQuestionType.multipleChoice,
    this.options,
    this.values,
    this.maxLength,
    this.placeholder,
  });

  bool get isTextInput => type == PersonalityQuestionType.textInput;
  bool get isMultipleChoice => type == PersonalityQuestionType.multipleChoice;
}

enum PersonalityQuestionType {
  multipleChoice,
  textInput,
}

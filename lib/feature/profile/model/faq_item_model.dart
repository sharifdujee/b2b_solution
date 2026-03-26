class FaqItemModel {
  final String id;
  final String question;
  final String answer;
  final bool isExpanded;

  FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  FaqItemModel copyWith({bool? isExpanded}) {
    return FaqItemModel(
      id: id,
      question: question,
      answer: answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
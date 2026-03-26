import '../../model/faq_item_model.dart';

class FaqState {
  final List<FaqItemModel> faqs;
  final bool isLoading;
  final String? errorMessage;

  FaqState({
    this.faqs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FaqState copyWith({
    List<FaqItemModel>? faqs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FaqState(
      faqs: faqs ?? this.faqs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

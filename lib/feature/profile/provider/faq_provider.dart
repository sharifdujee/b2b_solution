import 'package:b2b_solution/feature/profile/provider/states/faq_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/faq_item_model.dart';

class FaqNotifier extends StateNotifier<FaqState> {
  FaqNotifier() : super(FaqState()) {
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate Backend API Call
      await Future.delayed(const Duration(seconds: 2));

      final mockData = [
        FaqItemModel(
            id: '1',
            question: 'How do I create an account?',
            answer: 'Tap the "Sign Up" button on the login screen, enter your email address, create a secure password, and verify your email.'
        ),
        FaqItemModel(
            id: '2',
            question: 'What is the "Ping" feature?',
            answer: 'The Ping feature allows you to send quick location-based alerts to your business network.'
        ),
        FaqItemModel(
            id: '3',
            question: 'Do I need to be connected with someone to message them?',
            answer: 'Yes, both parties must accept a connection request before messaging.'
        ),
      ];

      state = state.copyWith(faqs: mockData, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load FAQs. Please try again.'
      );
    }
  }

  void toggleFaq(String id) {
    final updatedFaqs = state.faqs.map((faq) {
      if (faq.id == id) {
        return faq.copyWith(isExpanded: !faq.isExpanded);
      }
      // If you want accordion style (only one open at a time),
      // return faq.copyWith(isExpanded: false);
      return faq;
    }).toList();

    state = state.copyWith(faqs: updatedFaqs);
  }
}

final faqProvider = StateNotifierProvider<FaqNotifier, FaqState>((ref) {
  return FaqNotifier();
});
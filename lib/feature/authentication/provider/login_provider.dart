import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/login_state_model.dart';

// 1. Extend StateNotifier instead of AutoDisposeNotifier
class LoginNotifier extends StateNotifier<LoginStateModel> {

  // 2. Pass the initial state to the super constructor
  LoginNotifier() : super(LoginStateModel());

  // 3. Methods remain mostly the same, as 'state' is still used
  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }

  void toggleVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<void> login() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please fill in all fields',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Login failed",
      );
    }
  }
}

// 4. Use StateNotifierProvider.autoDispose instead of NotifierProvider
final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginStateModel>((ref) {
  return LoginNotifier();
});
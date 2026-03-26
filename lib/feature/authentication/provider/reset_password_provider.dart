import 'package:b2b_solution/feature/authentication/models/reset_password_state_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordStateModel> {
  ResetPasswordNotifier() : super(ResetPasswordStateModel());

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updateVerificationCode(String verificationCode) {
    state = state.copyWith(verificationCode: verificationCode, clearError: true);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, clearError: true);
  }

  void toggleVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  void toggleIsLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }


}

final ResetPasswordProvider = StateNotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordStateModel>((ref) {
  return ResetPasswordNotifier();
});

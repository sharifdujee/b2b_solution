import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/change_password_state_model.dart';

class ChangePasswordNotifier extends StateNotifier<ChangePasswordStateModel> {
  ChangePasswordNotifier() : super(ChangePasswordStateModel());

  // Update Methods
  void updateOldPassword(String value) =>
      state = state.copyWith(oldPassword: value, clearError: true);

  void updateNewPassword(String value) =>
      state = state.copyWith(newPassword: value, clearError: true);

  void updateConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value, clearError: true);

  // Visibility Toggles
  void toggleOldPasswordVisibility() =>
      state = state.copyWith(obscureOldPassword: !state.obscureOldPassword);

  void toggleNewPasswordVisibility() =>
      state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);

  void toggleConfirmPasswordVisibility() =>
      state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);

  // Logic to call the API
  Future<bool> changePassword() async {
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match");
      return false;
    }

    if (state.newPassword.length < 6) {
      state = state.copyWith(errorMessage: "Password too short");
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate API Call
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to change password");
      return false;
    }
  }
}

final changePasswordProvider = StateNotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordStateModel>((ref) {
  return ChangePasswordNotifier();
});
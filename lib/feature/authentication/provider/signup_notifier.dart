
import 'package:flutter_riverpod/legacy.dart';

import '../models/signup_state_model.dart';

class SignupNotifier extends StateNotifier<SignupStateModel> {

  SignupNotifier() : super(SignupStateModel());

  void updateLegalName(String legalName) {
    state = state.copyWith(legalName: legalName, clearError: true);
  }

  void updateBusinessName(String businessName) {
    state = state.copyWith(businessName: businessName, clearError: true);
  }

  void updateName(String name) {
    state = state.copyWith(name: name, clearError: true);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updatePosition(String position) {
    state = state.copyWith(position: position, clearError: true);
  }

  void updateFoodCategory(String foodCategory) {
    state = state.copyWith(foodCategory: foodCategory, clearError: true);
  }

  void updateYearsOfOperation(String yearsOfOperation) {
    state = state.copyWith(yearsOfOperation: yearsOfOperation, clearError: true);
  }

  void updateBusinessImage(String businessImage) {
    state = state.copyWith(businessImage: businessImage, clearError: true);
  }

  void updateProfileImage(String profileImage) {
    state = state.copyWith(profileImage: profileImage, clearError: true);
  }

  void updateBusinessLicenseImage(String businessLicenseImage) {
    state = state.copyWith(businessLicenseImage: businessLicenseImage, clearError: true);
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

  bool validateForm() {
    if (state.legalName.isEmpty ||
        state.businessName.isEmpty ||
        state.email.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty) {
      state = state.copyWith(errorMessage: "Please fill in all required fields");
      return false;
    }

    if (!state.email.contains('@')) {
      state = state.copyWith(errorMessage: "Please enter a valid email");
      return false;
    }

    if (state.password.length < 6) {
      state = state.copyWith(errorMessage: "Password must be at least 6 characters");
      return false;
    }

    if (state.password != state.confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match");
      return false;
    }

    state = state.copyWith(clearError: true);
    return true;
  }

  Future<void> signup() async {
    if (!validateForm())return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Signup failed",
      );
    }
  }

}


final signupProvider = StateNotifierProvider.autoDispose<SignupNotifier, SignupStateModel>((ref) {
  return SignupNotifier();
});

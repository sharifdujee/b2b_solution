
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        if (type == 'business') {
          state = state.copyWith(businessImage: pickedFile.path, clearError: true);
        } else if (type == 'profile') {
          state = state.copyWith(profileImage: pickedFile.path, clearError: true);
        } else if (type == 'license') {
          state = state.copyWith(businessLicenseImage: pickedFile.path, clearError: true);
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to pick image");
    }
  }

  // Public methods that now accept the Source
  Future<void> pickBusinessImage(ImageSource source) => _pickImage(source, 'business');
  Future<void> pickProfileImage(ImageSource source) => _pickImage(source, 'profile');
  Future<void> pickLicenseImage(ImageSource source) => _pickImage(source, 'license');

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

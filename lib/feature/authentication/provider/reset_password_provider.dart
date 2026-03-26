import 'dart:async'; // Required for Timer
import 'package:b2b_solution/feature/authentication/models/reset_password_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordStateModel> {
  ResetPasswordNotifier() : super(ResetPasswordStateModel());

  Timer? _timer;

  // --- Timer Logic ---

  void startTimer() {
    // Reset state to initial timer values
    state = state.copyWith(timer: 60, canResend: false);

    // Cancel any existing timer to avoid memory leaks/multiple instances
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timer > 0) {
        state = state.copyWith(timer: state.timer - 1);
      } else {
        state = state.copyWith(canResend: true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Always cancel timers when the provider is disposed
    super.dispose();
  }

  // --- OTP & Email Actions ---

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updateVerificationCode(String verificationCode) {
    state = state.copyWith(verificationCode: verificationCode, clearError: true);
  }

  Future<void> sendOtp() async {
    if (state.email.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate API Call
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isLoading: false);

      // Start the countdown once the OTP is successfully sent
      startTimer();

    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send OTP. Please try again.'
      );
    }
  }

  Future<void> verifyOtp() async {
    if (state.verificationCode.length != 4) {
      state = state.copyWith(errorMessage: 'Please enter a 4-digit code');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      if (state.verificationCode == "1234") {
        state = state.copyWith(isLoading: false);
        _timer?.cancel(); // Stop timer on success
        // Logic for navigation goes here
      } else {
        throw Exception('Invalid verification code');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid verification code. Please try again.',
      );
    }
  }

  // --- Password Visibility & Other UI Logic ---

  void updatePassword(String password) => state = state.copyWith(password: password, clearError: true);
  void updateConfirmPassword(String confirmPassword) => state = state.copyWith(confirmPassword: confirmPassword, clearError: true);
  void toggleVisibility() => state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleConfirmPasswordVisibility() => state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
}

final resetPasswordProvider = StateNotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordStateModel>((ref) {
  return ResetPasswordNotifier();
});
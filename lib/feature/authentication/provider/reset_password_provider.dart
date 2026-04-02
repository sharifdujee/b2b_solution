import 'dart:async';
import 'dart:developer';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:b2b_solution/feature/authentication/models/reset_password_state_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordStateModel> {
  ResetPasswordNotifier() : super(ResetPasswordStateModel());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final NetworkCaller networkCaller = NetworkCaller();
  Timer? _timer;

  // --- Helpers ---
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void startTimer() {
    state = state.copyWith(timer: 60, canResend: false);
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

  // --- State Updates ---
  void updateEmail(String email) => state = state.copyWith(email: email, clearError: true);
  void updateVerificationCode(String code) => state = state.copyWith(verificationCode: code, clearError: true);
  void updatePassword(String pw) => state = state.copyWith(password: pw, clearError: true);
  void updateConfirmPassword(String cpw) => state = state.copyWith(confirmPassword: cpw, clearError: true);
  void toggleVisibility() => state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleConfirmPasswordVisibility() => state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);

  // --- Logic ---

  Future<bool> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address');
      return false;
    }
    if (!_isValidEmail(email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email address');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await networkCaller.postRequest(
        AppUrl.forgetPasswordOtp,
        body: {'email': email},
      );

      if (!mounted) return false;
      state = state.copyWith(isLoading: false);

      if (response.isSuccess && response.responseData != null) {
        final String message = response.responseData['message'] ?? '';
        log("Message : $message");

        startTimer();
        return true;
      } else {
        state = state.copyWith(errorMessage: response.errorMessage);
        return false;
      }
    } catch (e) {
      log("Error in sendOtp: $e");
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to send OTP.');
      return false;
    }
  }

  /// Returns the forgetToken as a String if successful, otherwise null
  Future<String?> verifyOtp(String pin) async {
    if (pin.length != 4) {
      state = state.copyWith(errorMessage: 'Please enter a 4-digit code');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await networkCaller.postRequest(
        AppUrl.verifyForgotOtp,
        body: {
          'email': emailController.text.trim(),
          'otp': pin,
        },
      );

      if (!mounted) return null;
      state = state.copyWith(isLoading: false);

      if (response.isSuccess && response.responseData != null) {
        final result = response.responseData['result'];
        final String token = result['forgetToken'] ?? '';
        final String message = response.responseData['message'] ?? '';

        log("Token received : $token");

        return token;
      } else {
        state = state.copyWith(errorMessage: response.errorMessage);
        return null;
      }
    } catch (e) {
      log("Error in verifyOtp: $e");
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to verify OTP.');
      return null;
    }
  }

  Future<bool> resetPassword(String forgetToken) async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // --- Validation ---
    if (password.isEmpty || confirmPassword.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill in all password fields');
      return false;
    }
    if (password.length < 8) {
      state = state.copyWith(errorMessage: 'Password must be at least 8 characters long');
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      state = state.copyWith(errorMessage: 'Need at least one uppercase letter');
      return false;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      state = state.copyWith(errorMessage: 'Need at least one lowercase letter');
      return false;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      state = state.copyWith(errorMessage: 'Need at least one number');
      return false;
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
      state = state.copyWith(errorMessage: 'Need at least one special character (@\$!%*?&)');
      return false;
    }
    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await networkCaller.postRequest(
        AppUrl.resetPassword,
        body: {'newPassword': password},
        token: forgetToken, // Using the token passed as argument
      );

      if (!mounted) return false;
      state = state.copyWith(isLoading: false);

      if (response.isSuccess && response.responseData != null) {
        final message = response.responseData['message'];
        log("Reset Success Message: $message");
        return true;
      } else {
        state = state.copyWith(errorMessage: response.errorMessage);
        return false;
      }
    } catch (e) {
      log("Error in resetPassword: $e");
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to reset password.');
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    verificationCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, ResetPasswordStateModel>((ref) {
  return ResetPasswordNotifier();
});
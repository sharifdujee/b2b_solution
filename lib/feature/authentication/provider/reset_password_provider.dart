import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:b2b_solution/feature/authentication/models/reset_password_state_model.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordStateModel> {
  ResetPasswordNotifier() : super(ResetPasswordStateModel());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final NetworkCaller networkCaller = NetworkCaller();
  Timer? _timer;

  // ---------------- HELPERS ----------------
  bool _isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  void startTimer() {
    _timer?.cancel();

    state = state.copyWith(
      errorMessage: null,
      timer: 60,
      canResend: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (state.timer > 0) {
        state = state.copyWith(timer: state.timer - 1);
      } else {
        state = state.copyWith(canResend: true);
        _timer?.cancel();
      }
    });
  }

  // ---------------- STATE METHODS ----------------
  void updateEmail(String email) =>
      state = state.copyWith(email: email, errorMessage: null);

  void updateVerificationCode(String code) =>
      state = state.copyWith(verificationCode: code, errorMessage: null);

  void updatePassword(String pw) =>
      state = state.copyWith(password: pw, errorMessage: null);

  void updateConfirmPassword(String cpw) =>
      state = state.copyWith(confirmPassword: cpw, errorMessage: null);

  void toggleVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleConfirmPasswordVisibility() =>
      state = state.copyWith(
        obscureConfirmPassword: !state.obscureConfirmPassword,
      );

  void resetErrorMessage() {
    state = state.copyWith(errorMessage: null);
  }

  /// 🔥 Full reset (recommended after success or screen change)
  void clearAll() {
    _timer?.cancel();
    state = ResetPasswordStateModel();

    emailController.clear();
    verificationCodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  // ---------------- API LOGIC ----------------

  /// Step 1: Send OTP
  /// Step 1: Send OTP
  Future<bool> sendOtp() async {
    final email = emailController.text.trim();

    state = state.copyWith(errorMessage: null); // Clear old error immediately

    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(errorMessage: 'Invalid email format');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await networkCaller.postRequest(
        AppUrl.forgetPasswordOtp,
        body: {'email': email},
      );

      if (!mounted) return false;

      if (response.isSuccess) {
        log('OTP sent successfully');
        startTimer();
        state = state.copyWith(isLoading: false, errorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? 'This email is not registered',
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Try again.',
      );
      return false;
    }
  }

  /// Step 2: Verify OTP
  Future<String?> verifyOtp(String pin) async {
    state = state.copyWith(errorMessage: null);

    if (pin.length < 4) {
      state = state.copyWith(
        errorMessage: 'Enter full 4-digit code',
      );
      return null;
    }

    state = state.copyWith(isLoading: true);

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
        final token =
            response.responseData['result']?['forgetToken'] ?? '';

        log("Token: $token");
        return token;
      } else {
        state = state.copyWith(
          errorMessage:
          response.errorMessage ?? 'Invalid or expired code',
        );
        return null;
      }
    } catch (e) {
      log("verifyOtp error: $e");

      if (!mounted) return null;

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed',
      );
      return null;
    }
  }

  /// Step 3: Reset Password
  Future<bool> resetPassword(String token) async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    state = state.copyWith(errorMessage: null);

    if (password.isEmpty || confirmPassword.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Both fields are required',
      );
      return false;
    }

    if (password.length < 8) {
      state = state.copyWith(
        errorMessage: 'Minimum 8 characters required',
      );
      return false;
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).+$',
    ).hasMatch(password)) {
      state = state.copyWith(
        errorMessage:
        'Must include upper, lower, number & special char',
      );
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        errorMessage: 'Passwords do not match',
      );
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await networkCaller.postRequest(
        AppUrl.resetPassword,
        body: {'newPassword': password},
        token: token,
      );

      if (!mounted) return false;

      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        clearAll();
        return true;
      } else {
        state = state.copyWith(
          errorMessage:
          response.errorMessage ?? 'Reset failed',
        );
        return false;
      }
    } catch (e) {
      log("resetPassword error: $e");

      if (!mounted) return false;

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.clear();
    verificationCodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    super.dispose();
  }
}

final resetPasswordProvider = StateNotifierProvider.autoDispose<
    ResetPasswordNotifier,
    ResetPasswordStateModel>((ref) {
  return ResetPasswordNotifier();
});
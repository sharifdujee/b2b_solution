import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../models/login_state_model.dart';

class LoginNotifier extends StateNotifier<LoginStateModel> {
  final Ref ref;
  LoginNotifier(this.ref) : super(LoginStateModel());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void toggleVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!mounted) return false;

    // 1. Reset state before validation
    state = state.copyWith(errorMessage: null, isLoading: false);

    // 2. Client-side Validation
    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Email address is required');
      return false;
    }
    if (!_emailRegExp.hasMatch(email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email address');
      return false;
    }
    if (password.isEmpty) {
      state = state.copyWith(errorMessage: 'Password is required');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(errorMessage: 'Password must be at least 6 characters');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await NetworkCaller().postRequest(
        AppUrl.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.responseData != null) {
        final result = response.responseData['result'];

        await AuthService.saveToken(result['accessToken']);
        await AuthService.saveId(result['userId']);
        await AuthService.saveProfileSetup(result['isProfileComplete']);
        await AuthService.saveRole(result['role']);

        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Invalid credentials. Please try again.",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Connection error: ${e.toString()}");
      return false;
    }
  }

  @override
  void dispose() {
    emailController.clear();
    passwordController.clear();
    super.dispose();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginStateModel>((ref) {
  return LoginNotifier(ref);
});
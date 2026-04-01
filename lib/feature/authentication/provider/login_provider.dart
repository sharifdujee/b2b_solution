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

    // Validation using controller values
    if (!_emailRegExp.hasMatch(email)) {
      state = state.copyWith(errorMessage: 'A valid email is required');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(errorMessage: 'Password is too short');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

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

        log("The token After login : ${AuthService.token}");


        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Login failed",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginStateModel>(
  (ref) => LoginNotifier(ref),
);
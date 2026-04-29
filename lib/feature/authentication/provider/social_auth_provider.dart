

import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ❌ REMOVE: import 'package:http/http.dart' as ref;  ← this was the root cause
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../../../core/service/push_notification_service.dart';



// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

class SocialAuthState {
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final String? errorMessage;
  final String? successMessage;

  SocialAuthState({
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SocialAuthState copyWith({
    bool? isGoogleLoading,
    bool? isAppleLoading,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return SocialAuthState(
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      errorMessage:
      clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
      clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER — parse response and save to AuthService
// ─────────────────────────────────────────────

Future<bool> _saveAuthData(Map<String, dynamic> responseData) async {
  try {
    final result = responseData['result'] as Map<String, dynamic>?;
    if (result == null) return false;

    final String? token = result['accessToken'] as String?;
    final bool isSetup = result['isSetup'] as bool? ?? false;
    final String? userId =
        result['_id'] as String? ?? result['id'] as String?;
    final String? role = result['role'] as String?;

    if (token == null || token.isEmpty) return false;

    await AuthService.saveToken(token);
    await AuthService.saveStatus(isSetup);
    if (userId != null && userId.isNotEmpty) await AuthService.saveId(userId);
    if (role != null && role.isNotEmpty) await AuthService.saveRole(role);

    log("✅ Auth data saved — isSetup: $isSetup, userId: $userId, role: $role");
    return true;
  } catch (e) {
    log("❌ Error saving auth data: $e");
    return false;
  }
}

String _resolveNextRoute() {
  final isSetUp = AuthService.hasToken();
  return isSetUp ? '/nav' : '/loginScreen';
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class SocialAuthNotifier extends StateNotifier<SocialAuthState> {
  final Ref ref; // ✅ Riverpod Ref — works because http import is removed
  SocialAuthNotifier(this.ref) : super(SocialAuthState());

  final NetworkCaller _networkCaller = NetworkCaller();

  // ── GOOGLE LOGIN ──────────────────────────────

  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
      isGoogleLoading: true,
    );

    try {
      // ✅ Correctly read FCM token from the global provider
      final String? fcmToken = ref.read(fcmTokenProvider);
      log("Using FCM Token: $fcmToken");

      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final String email = googleUser.email;
      final String userName =
          googleUser.displayName ?? email.split('@').first;

      log("Google user: email=$email, name=$userName");

      final response = await _networkCaller.postRequest(
        AppUrl.googleLogin,
        body: {
          "email": email,
          "fullName": userName,
          "fcmToken": ?fcmToken, // ✅ only sent if not null
        },
      );

      if (response.isSuccess && response.responseData != null) {
        log("Google login success");

        final saved = await _saveAuthData(
          response.responseData as Map<String, dynamic>,
        );

        if (!saved) {
          state = state.copyWith(
            isGoogleLoading: false,
            errorMessage: "Failed to save login data. Please try again.",
            clearSuccessMessage: true,
          );
          return;
        }

        state = state.copyWith(
          isGoogleLoading: false,
          successMessage: "Logged in successfully with Google!",
          clearErrorMessage: true,
        );

        if (context.mounted) context.go(_resolveNextRoute());
      } else {
        state = state.copyWith(
          isGoogleLoading: false,
          errorMessage: response.errorMessage,
          clearSuccessMessage: true,
        );
      }
    } on Exception catch (e) {
      log("Google sign-in exception: ${e.toString()}");
      final bool cancelled = e.toString().toLowerCase().contains('cancel');
      state = state.copyWith(
        isGoogleLoading: false,
        errorMessage: cancelled
            ? "Google sign-in was cancelled."
            : "An error occurred during Google sign-in. Please try again.",
        clearSuccessMessage: true,
      );
    }
  }

  // ── APPLE LOGIN ───────────────────────────────

  Future<void> signInWithApple(BuildContext context) async {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
      isAppleLoading: true,
    );

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String appleId = appleCredential.userIdentifier ?? '';

      if (appleId.isEmpty) {
        state = state.copyWith(
          isAppleLoading: false,
          errorMessage: "Apple sign-in failed. Could not retrieve Apple ID.",
          clearSuccessMessage: true,
        );
        return;
      }

      final String? email = appleCredential.email;
      final String? givenName = appleCredential.givenName;
      final String? familyName = appleCredential.familyName;

      // ✅ Correctly read FCM token from the global provider
      final String? fcmToken = ref.read(fcmTokenProvider);
      log("Using FCM Token: $fcmToken");

      Map<String, dynamic> body;

      if (email != null && email.isNotEmpty) {
        final String userName = [givenName, familyName]
            .where((p) => p != null && p.isNotEmpty)
            .join(' ')
            .trim();

        log("Apple first-time login: appleId=$appleId, email=$email, name=$userName");

        body = {
          "appleId": appleId,
          "email": email,
          "fullName": userName.isNotEmpty ? userName : email.split('@').first,
          "fcmToken": ?fcmToken, // ✅ only sent if not null
        };
      } else {
        log("Apple subsequent login: appleId=$appleId");
        body = {
          "appleId": appleId,
          "fcmToken": ?fcmToken, // ✅ only sent if not null
        };
      }

      final response = await _networkCaller.postRequest(
        AppUrl.appleLogin,
        body: body,
      );

      if (response.isSuccess && response.responseData != null) {
        log("Apple login success");

        final saved = await _saveAuthData(
          response.responseData as Map<String, dynamic>,
        );

        if (!saved) {
          state = state.copyWith(
            isAppleLoading: false,
            errorMessage: "Failed to save login data. Please try again.",
            clearSuccessMessage: true,
          );
          return;
        }

        state = state.copyWith(
          isAppleLoading: false,
          successMessage: "Logged in successfully with Apple!",
          clearErrorMessage: true,
        );

        if (context.mounted) context.go(_resolveNextRoute());
      } else {
        state = state.copyWith(
          isAppleLoading: false,
          errorMessage: response.errorMessage,
          clearSuccessMessage: true,
        );
      }
    } catch (e) {
      log("Apple sign-in exception: ${e.toString()}");
      final bool cancelled = e.toString().toLowerCase().contains('cancel');
      state = state.copyWith(
        isAppleLoading: false,
        errorMessage: cancelled
            ? "Apple sign-in was cancelled."
            : "An error occurred during Apple sign-in. Please try again.",
        clearSuccessMessage: true,
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }
}



final socialAuthProvider =
StateNotifierProvider<SocialAuthNotifier, SocialAuthState>(
      (ref) => SocialAuthNotifier(ref), // ✅ pass ref
);
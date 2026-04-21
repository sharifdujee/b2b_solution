import 'package:b2b_solution/core/service/app_url.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../model/change_password_state_model.dart';

class ChangePasswordNotifier extends StateNotifier<ChangePasswordStateModel> {
  ChangePasswordNotifier() : super(ChangePasswordStateModel());


  final NetworkCaller networkCaller = NetworkCaller();


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

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await networkCaller.patchRequest(
          AppUrl.changePassword,
          token: AuthService.token,
          body: {
            "oldPassword": state.oldPassword,
            "newPassword": state.newPassword,
          }
      );
      if (!response.isSuccess) {
        state = state.copyWith(isLoading: false, errorMessage: response.errorMessage);
        return false;
      }
      state = state.copyWith(errorMessage: null);


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
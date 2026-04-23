import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_dialog.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../provider/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  // 1. Initialize the Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final controller = ref.read(changePasswordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 120.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w)),

                SizedBox(height: 16.h),
                CustomText(
                  text: "Change Password",
                  fontSize: 24.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.w600,
                ),

                SizedBox(height: 32.h),
                _buildLabel("Old Password"),
                CustomTextFormField(
                    onChanged: (value) => controller.updateOldPassword(value),
                    hintText: "Old Password",
                    hintTextColor: AppColor.grey400,
                    textColor: AppColor.black,
                    borderRadius: 12.r,
                    obscureText: state.obscureOldPassword,
                    // Validation for Old Password
                    validator: (value) => (value == null || value.isEmpty) ? "Please enter old password" : null,
                    suffixIcon: IconButton(
                        onPressed: () => controller.toggleOldPasswordVisibility(),
                        icon: Icon(state.obscureOldPassword ? Icons.visibility_off : Icons.visibility, color: AppColor.grey400))),

                SizedBox(height: 24.h),
                _buildLabel("New Password"),
                CustomTextFormField(
                    onChanged: (value) => controller.updateNewPassword(value),
                    hintText: "New Password",
                    borderRadius: 12.r,
                    hintTextColor: AppColor.grey400,
                    obscureText: state.obscureNewPassword,
                    textColor: AppColor.black,

                    // Validation for New Password
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter new password";
                      if (value.length < 8) return "Password must be at least 8 characters";
                      if (!RegExp(r'[0-9]').hasMatch(value)) return "Must contain at least one number";
                      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) return "Must contain a symbol";
                      return null;
                    },
                    suffixIcon: IconButton(
                        onPressed: () => controller.toggleNewPasswordVisibility(),
                        icon: Icon(state.obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: AppColor.grey400))),

                SizedBox(height: 24.h),
                _buildLabel("Confirm Password"),
                CustomTextFormField(
                    hintText: "Confirm password",
                    hintTextColor: AppColor.grey400,
                    borderRadius: 12.r,
                    obscureText: state.obscureConfirmPassword,
                    textColor: AppColor.black,

                    // Validation to check if matches New Password
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please confirm your password";
                      if (value != state.newPassword) return "Passwords do not match";
                      return null;
                    },
                    suffixIcon: IconButton(
                        onPressed: () => controller.toggleConfirmPasswordVisibility(),
                        icon: Icon(state.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColor.grey400))),

                const Spacer(),

                CustomButton(
                    backgroundColor: AppColor.primary,
                    textColor: AppColor.black,
                    borderRadius: 12.r,
                    text: state.isLoading ? "Updating..." : "Change Password",
                    onPressed: state.isLoading
                        ? null
                        : () async {
                      // 3. Trigger Validation
                      if (_formKey.currentState!.validate()) {
                        final success = await controller.changePassword();

                        if (success && context.mounted) {
                          showCustomDialog(
                            context,
                            imagePath: IconPath.shield,
                            title: "Password Changed",
                            message: "Password changed successfully, you can login again with new password",
                            buttonText: "Log in",
                            onPressed: () => context.go('/loginScreen'), // Use .go to clear stack
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage ?? "Update failed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomText(
        text: text,
        fontSize: 16.sp,
        color: AppColor.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
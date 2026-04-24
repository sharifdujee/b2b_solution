import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/authentication/provider/location_provider.dart';
import 'package:b2b_solution/feature/authentication/provider/reset_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_dialog.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';

class CreateNewPasswordScreen extends ConsumerWidget {
  final String forgetToken;

  const CreateNewPasswordScreen({super.key, required this.forgetToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordProvider);
    final controller = ref.read(resetPasswordProvider.notifier);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
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
                  text: "Create New Password",
                  fontSize: 24.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: "Your password must be different from previous used password",
                  color: AppColor.grey400,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 32.h),
                CustomText(
                  text: "New Password",
                  fontSize: 16.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 12.h),
                CustomTextFormField(
                    controller: controller.passwordController,
                    hintText: "New Password",
                    hintTextColor: AppColor.grey400,
                    textColor: AppColor.black,
                    borderRadius: 12.r,
                    obscureText: state.obscurePassword,
                    suffixIcon: IconButton(
                        onPressed: () => controller.toggleVisibility(),
                        icon: Icon(
                            state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColor.grey400)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }

                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return "Password must contain at least one number";
                    }

                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return "Password must contain at least one special symbol";
                    }

                    return null;
                  },
                ),
                SizedBox(height: 32.h),
                CustomText(
                  text: "Confirm password",
                  fontSize: 16.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 12.h),
                CustomTextFormField(
                    controller: controller.confirmPasswordController,
                    hintText: "Confirm password",
                    hintTextColor: AppColor.grey400,
                    textColor: AppColor.black,
                    borderRadius: 12.r,
                    obscureText: state.obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password required";
                      }
                      if (value != controller.passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                        onPressed: () => controller.toggleConfirmPasswordVisibility(),
                        icon: Icon(
                            state.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColor.grey400))),

                // --- Validation Error Display ---
                if (state.errorMessage != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CustomText(
                            text: state.errorMessage!,
                            fontSize: 13.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 32.h),
                CustomButton(
                    backgroundColor: AppColor.primary,
                    textColor: AppColor.black,
                    borderRadius: 12.r,
                    text: state.isLoading ? "Resetting..." : "Reset Password",
                    onPressed: state.isLoading
                        ? null
                        : () async {

                      if (_formKey.currentState!.validate()){
                        final success = await controller.resetPassword(forgetToken);
                        if (success && context.mounted) {
                          showCustomDialog(
                            context,
                            imagePath: IconPath.shield,
                            title: "Password Changed",
                            message: "Password changed successfully, you can login again with new password",
                            buttonText: "Log in",
                            onPressed: () {
                              controller.clearAll();
                              context.go('/loginScreen');
                              ref.read(locationProvider.notifier).dispose();
                            },
                          );
                        }
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
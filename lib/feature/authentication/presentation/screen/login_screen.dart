import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/custom_text_form_field.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/authentication/presentation/widgets/social_button.dart';
import 'package:b2b_solution/feature/authentication/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/presentation/screen.dart';
import '../../models/login_state_model.dart';
import '../../provider/social_auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final socialState = ref.watch(socialAuthProvider);
    final socialNotifier = ref.read(socialAuthProvider.notifier);
    // Listen for error messages from the provider
    ref.listen<LoginStateModel>(loginProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showSnackBar(context, next.errorMessage!, isError: true);
      }
    });

    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          // 2. Wrap the content in a Form
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Image.asset(IconPath.arrowLeft, height: 24.h),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: "Log in",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: "Log in to your account",
                  fontSize: 14.sp,
                  color: AppColor.grey400,
                ),

                SizedBox(height: 32.h),
                _buildLabel("Email Address"),
                CustomTextFormField(
                  controller: controller.emailController,
                  hintText: "Email Address",
                  hintTextColor: AppColor.grey300,
                  textColor: AppColor.black,
                  borderRadius: 12.r,
                  keyboardType: TextInputType.emailAddress,
                  // 3. Add Email Validation
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
                    return null;
                  },
                ),

                SizedBox(height: 16.h),
                _buildLabel("Password"),
                CustomTextFormField(
                  controller: controller.passwordController,
                  hintText: "Password",
                  hintTextColor: AppColor.grey300,
                  obscureText: state.obscurePassword,
                  textColor: AppColor.black,
                  borderRadius: 12.r,
                  // 4. Add Password Validation
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () => controller.toggleVisibility(),
                    icon: Icon(
                      state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColor.grey300,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                _buildForgotPassword(context),

                SizedBox(height: 32.h),
                CustomButton(
                  borderRadius: 16.r,
                  onPressed: state.isLoading
                      ? null
                      : () async {
                    // 5. Trigger Form Validation
                    if (_formKey.currentState!.validate()) {
                      final success = await controller.login();
                      if (success && context.mounted) {
                        _showSnackBar(context, "Login Successful!", isError: false);
                        ref.read(selectedIndexProvider.notifier).state = 0;
                        context.pushReplacement('/nav');
                        controller.dispose();
                      }
                    }
                  },
                  text: state.isLoading ? "Logging in..." : "Log in",
                  backgroundColor: AppColor.primary,
                  textColor: Colors.black,
                ),

                // ... Social Buttons & Sign Up (Keep existing code) ...
                _buildSocialSection(socialState, socialNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomText(
        text: text,
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  // --- Forgot Password Link ---
  Widget _buildForgotPassword(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.push('/resetPassword'),
        child: CustomText(
          text: "Forgot Password?",
          fontSize: 14.sp,
          color: AppColor.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- Social Login & Sign Up Section ---
  Widget _buildSocialSection(
      dynamic socialState,
      dynamic socialNotifier,
      ) {
    return Column(
      children: [
        SizedBox(height: 32.h),

        Row(
          children: [
            Expanded(
              child: Divider(thickness: 1, color: AppColor.grey50),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: CustomText(
                text: "Or log in with",
                fontSize: 14.sp,
                color: AppColor.grey400,
              ),
            ),
            Expanded(
              child: Divider(thickness: 1, color: AppColor.grey50),
            ),
          ],
        ),

        SizedBox(height: 32.h),

        /// 🔵 Google Login
        SocialLoginButton(
          text: socialState.isGoogleLoading
              ? "Signing in with Google..."
              : "Continue with Google",
          assetPath: IconPath.googleIcon,
          onTap: () {
            context.push("/completeProfileInfoScreen");
            if (!socialState.isGoogleLoading &&
                !socialState.isAppleLoading) {
              socialNotifier.signInWithGoogle(context);
            }
          },
        ),

        SizedBox(height: 16.h),

        /// 🍎 Apple Login
        SocialLoginButton(
          text: socialState.isAppleLoading
              ? "Signing in with Apple..."
              : "Continue with Apple",
          icon: Icons.apple_sharp,
          onTap: () {
            context.push("/completeProfileInfoScreen");
            if (!socialState.isGoogleLoading &&
                !socialState.isAppleLoading) {
              socialNotifier.signInWithApple(context);
            }
          },
        ),

        SizedBox(height: 32.h),

        /// 🔽 Sign Up Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: "Don't have an account?",
              fontSize: 14.sp,
              color: AppColor.grey400,
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => context.push('/roleSelectionScreen'),
              child: CustomText(
                text: "Sign Up",
                fontSize: 14.sp,
                color: AppColor.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 32.h),
      ],
    );
  }

  // Unified Snackbar Method
  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
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

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
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
              CustomText(
                text: "Email Address",
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),

              SizedBox(height: 12.h),
              CustomTextFormField(
                controller: controller.emailController,
                hintText: "Email Address",
                hintTextColor: AppColor.grey300,
                textColor: AppColor.black,
                borderRadius: 12.r,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h),
              CustomText(
                text: "Password",
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),

              SizedBox(height: 12.h),
              CustomTextFormField(
                controller: controller.passwordController,
                hintText: "Password",
                hintTextColor: AppColor.grey300,
                obscureText: state.obscurePassword,
                textColor: AppColor.black,
                borderRadius: 12.r,
                suffixIcon: IconButton(
                  onPressed: () => controller.toggleVisibility(),
                  icon: Icon(
                    state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColor.grey300,
                  ),
                ),
              ),

              SizedBox(height: 24.h),
              Container(
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
              ),



              SizedBox(height: 32.h),
              CustomButton(
                borderRadius: 16.r,
                onPressed: (state.isLoading
                    ? null
                    : () async {
                  final success = await controller.login();
                  if (success && context.mounted) {
                    ref.read(selectedIndexProvider.notifier).state = 0;
                    context.pushReplacement('/nav');
                    controller.dispose();
                  }
                }),
                text: state.isLoading ? "Logging in..." : "Log in",
                backgroundColor: AppColor.primary,
                textColor: Colors.black,
              ),

              SizedBox(height: 32.h),
              // ... Social Login Buttons & Sign Up Row ...
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1, color: AppColor.grey50)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: CustomText(text: "Or log in with", fontSize: 14.sp, color: AppColor.grey400),
                  ),
                  Expanded(child: Divider(thickness: 1, color: AppColor.grey50)),
                ],
              ),

              SizedBox(height: 32.h),
              SocialLoginButton(
                text: "Continue with Google",
                assetPath: IconPath.googleIcon,
                onTap: () {

                },
              ),

              SizedBox(height: 16.h),
              SocialLoginButton(
                text: "Continue with Apple",
                icon: Icons.apple_sharp,
                onTap: () {

                },
              ),

              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: "Don't have an account?", fontSize: 14.sp, color: AppColor.grey400),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => context.push('/roleSelectionScreen'),
                    child: CustomText(text: "Sign Up", fontSize: 14.sp, color: AppColor.secondary),
                  )
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
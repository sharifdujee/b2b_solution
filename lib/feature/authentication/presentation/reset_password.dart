import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_color.dart';
import '../../../core/gloabal/custom_text_form_field.dart';
import '../../../core/utils/local_assets/icon_path.dart';
import '../provider/reset_password_provider.dart';

class ResetPassword extends ConsumerWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ResetPasswordProvider);
    final controller = ref.read(ResetPasswordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              GestureDetector(
                child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.h),
                onTap: () => context.pop(),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: "Reset Password",
                fontSize: 24.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: "Enter your email address to get a verification code.",
                fontSize: 14.sp,
                color: AppColor.grey400,
              ),
              SizedBox(height: 24.h),
              CustomText(
                text: "Email Address",
                fontSize: 16.sp,
                color: AppColor.black,
              ),
              SizedBox(height: 12.h),
              CustomTextFormField(
                borderRadius: 12.r,
                onChanged: (value) => controller.updateEmail(value),
                hintText: "Email Address",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
              ),
              // Removed the button from here
              SizedBox(height: 100.h), // Add extra space so content isn't hidden by the fixed button
            ],
          ),
        ),
      ),
      // --- ADDED THIS SECTION ---
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 20.h,
        ),
        child: CustomButton(
          text: "Send Code",
          backgroundColor: AppColor.primary,
          textColor: AppColor.black,
          borderRadius: 16.r,
          onPressed: () {

          },
        ),
      ),
    );
  }
}
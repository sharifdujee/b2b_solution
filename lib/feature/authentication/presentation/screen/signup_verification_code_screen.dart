import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_dialog.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/authentication/provider/signup_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/gloabal/custom_button.dart';
import '../../../navigation/presentation/screen.dart';

class SignupVerificationCodeScreen extends ConsumerWidget {
  const SignupVerificationCodeScreen({super.key});


  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final controller = ref.read(signupProvider.notifier);

    final defaultPinTheme = PinTheme(
        width: 65.w,
        height: 65.h,
        textStyle: TextStyle(
            fontSize: 24.sp,
            color: AppColor.black,
            fontWeight: FontWeight.w700
        ),
        decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.primary, width: 2)
        )
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primary,
          width: 2,
        ),
      ),
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      ),
    );

    final emptyPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primary,
          width: 2,
        ),
      ),
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.black,
      ),
    );




    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w,top: 48.h,bottom: 48.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: ()=>context.pop(),
                    child: Image.asset(IconPath.arrowLeft,height: 24.h,width: 24.w,),
                  ),


                  SizedBox(height: 16.h,),
                  CustomText(
                    text: "Verification code",
                    fontSize: 24.sp,
                    color: AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),


                  SizedBox(height: 16.h,),
                  CustomText(
                    text: "We sent a four digit code to your email address",
                    fontSize: 14.sp,
                    color: AppColor.grey400,
                  ),


                  SizedBox(height: 32.h,),
                  Center(
                    child: Pinput(
                      length: 4,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      errorTextStyle: TextStyle(color: AppColor.error, fontSize: 12.sp),
                      errorPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColor.error, width: 2),
                        ),
                      ),
                      controller: controller.pinController,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                      validator: (value) {
                        if (value == null || value.length < 4) return "Enter 4 digits";

                        if (state.errorMessage == "Invalid code") return "Incorrect code, please try again";

                        return null;
                      },
                      cursor: Container(
                        width: 2,
                        height: 30.h,
                        color: AppColor.primary,
                      ),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                    ),
                  ),


                  SizedBox(height: 24.h),

                  CustomButton(
                    text: state.isLoading ? "Verifying..." : "Verify",
                    backgroundColor: AppColor.primary,
                    onPressed: state.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await controller.verify(controller.pinController.text);

                        if (success) {
                          ref.read(selectedIndexProvider.notifier).state = 0;
                          if (context.mounted) context.push("/nav");
                        } else {
                          _formKey.currentState!.validate();
                        }
                      }
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Resend Code Timer or Button
                  Center(
                    child: state.canResend
                        ? GestureDetector(
                      onTap: () async {
                        final success = await ref.read(signupProvider.notifier).resendOtp();                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("OTP Resent Successfully")),
                          );
                        }
                      },
                      child: CustomText(
                        text: "Resend Code",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(text: "Re-send code in ", /*...*/),
                        CustomText(
                          // Format as 0:59 for better UX
                          text: "${state.timer}s",
                          color: AppColor.secondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h,),
                  Center(
                    child: CustomText(
                      text: "Can't find the email? Check your spam folder.",
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColor.grey400,
                      textAlign: TextAlign.center,
                    ),
                  ),

                ]
            ),
          ),
        ),
      ),
    );
  }

}
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

class SignupVerificationCodeScreen extends ConsumerWidget {
  const SignupVerificationCodeScreen({super.key});

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
                    errorPinTheme: emptyPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    controller: controller.pinController,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    // --- ADD VALIDATOR HERE ---
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Code is required';
                      }
                      if (value.length < 4) {
                        return 'Please enter the full 4-digit code';
                      }
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
                  textColor: AppColor.black,
                  borderRadius: 16.r,
                  onPressed: () async {
                    final success = await controller.verify(controller.pinController.text);
                    if (success){
                      context.push("/nav");
                    }

                  }
                ),

                SizedBox(height: 24.h),

                // Resend Code Timer or Button
                Center(
                  child: state.canResend
                      ? GestureDetector(
                    onTap: () {

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
                      CustomText(
                        text: "Re-send code in ",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.grey400,
                      ),
                      CustomText(
                        text: state.timer.toString(),
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
    );
  }

}
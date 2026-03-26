import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/gloabal/custom_button.dart';
import '../../provider/reset_password_provider.dart';

class ResetVerificationCodeScreen extends ConsumerWidget {
  const ResetVerificationCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetPasswordProvider);
    final controller = ref.read(resetPasswordProvider.notifier);

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
                  errorPinTheme: emptyPinTheme,
                  onChanged: (value) => controller.updateVerificationCode(value),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  cursor: Container(
                    width: 2,
                    height: 30.h,
                    color: AppColor.primary,
                  ),
                  onCompleted: (pin) => controller.verifyOtp(pin),
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                ),
              ),

              if(state.errorMessage != null)
                SizedBox(height: 16.h,),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      text: state.errorMessage!,
                      color: AppColor.error,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              CustomButton(
                text: "Verify",
                onPressed: state.isLoading
                    ? null
                    : () {
                  showCustomDialog(context, imagePath: IconPath.success, title: "Account  verified Successfully", buttonText: "Done",
                      onPressed: (){
                        context.pop();
                      }
                  );

                },
              ),

              SizedBox(height: 24.h),

              // Resend Code Timer or Button
              Center(
                child: state.canResend
                    ? GestureDetector(
                  onTap: () {
                    otpNotifier.resendOtp();
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
                      color: AppColor.textBody,
                    ),
                    CustomText(
                      text: otpNotifier.formattedTimer,
                      color: AppColor.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

            ]
          ),
        ),
      ),
    );
  }
  
}
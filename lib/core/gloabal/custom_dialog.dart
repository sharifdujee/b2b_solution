import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../design_system/app_color.dart';
import 'custom_button.dart';
import 'custom_text.dart';

void showCustomDialog(
    BuildContext context, {
      required String imagePath,
      required String title,
      String? message,
      required String buttonText,
      String? secondButtonText,
      void Function()? onPressed,
      void Function()? onSecondPressed,
      bool isDoubleButton = false,
      Color? button1Color,
      Color? button2Color,
      bool backgroundContainer = true,
    }) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  Widget buildRipple({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 30.r, vertical: 20.r),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF252525) : Colors.white,
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FIXED STACK LOGIC
              backgroundContainer? Stack(
                alignment: Alignment.center,
                children: [
                  buildRipple(
                    size: 150.r,
                    color: AppColor.primary.withValues(alpha: 0.4),
                  ),
                  buildRipple(
                    size: 127.r,
                    color: AppColor.primary.withValues(alpha: 0.5),
                  ),
                  buildRipple(
                    size: 104.r,
                    color: AppColor.primary,
                  ),
                  Image.asset(imagePath, height: 58.7.h, width: 58.7.w),
                ],
              )
                  :
              Image.asset(imagePath, height: 58.7.h, width: 58.7.w),

              SizedBox(height: 20.h),

              CustomText(
                text: title,
                textAlign: TextAlign.center,
                fontSize: 24.sp, // Using standard sp
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColor.white : AppColor.black,
              ),

              if (message != null && message.isNotEmpty) ...[
                SizedBox(height: 10.h),
                CustomText(
                  text: message,
                  textAlign: TextAlign.center,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? AppColor.white : AppColor.grey400,
                ),
              ],

              SizedBox(height: 20.h),

              isDoubleButton
                  ? Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      isOutlined: true,
                      // If button1Color is null, use transparent or a default grey/outline color
                      backgroundColor: button1Color ?? Colors.transparent,
                      textColor: AppColor.primary,
                      borderGradient: LinearGradient(
                        colors: [
                          AppColor.primary,
                          AppColor.primary,
                        ],
                      ),
                      borderRadius: 16.r,
                      text: buttonText,
                      onPressed: onPressed ?? () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomButton(
                      // If button2Color is null, use your theme's primary color
                      backgroundColor: button2Color ?? AppColor.primary,
                      textColor: Colors.white,
                      borderRadius: 16.r,
                      borderGradient: LinearGradient(
                        colors: [
                          AppColor.primary,
                          AppColor.primary,
                        ],
                      ),
                      text: secondButtonText ?? 'Cancel',
                      onPressed: onSecondPressed ?? () => Navigator.pop(context),
                    ),
                  ),
                ],
              )
                  : CustomButton(
                text: buttonText,
                // Apply the color here too if you want the single button to be dynamic
                backgroundColor: button1Color ?? AppColor.primary,
                borderRadius: 20.r,
                textColor: AppColor.black,
                onPressed: onPressed ?? () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/design_system/app_color.dart';
import '../../../core/gloabal/custom_text.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String? assetPath;
  final IconData? icon;
  final double? height;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onTap,
    this.assetPath,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 56.h,
        width: double.infinity, // Ensures it matches your main button width
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.5.w, color: AppColor.grey200),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logic to show either an Image or an Icon
            if (assetPath != null)
              Image.asset(
                assetPath!,
                height: 24.h,
                width: 24.w,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24.h,
                color: Colors.black,
              ),

            SizedBox(width: 12.w),

            CustomText(
              text: text,
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
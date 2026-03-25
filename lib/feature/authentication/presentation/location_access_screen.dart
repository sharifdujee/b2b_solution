import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LocationAccessScreen extends ConsumerWidget {
  const LocationAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),

          // 1. Circular Map Preview with Ripples
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildRipple(size: 280.w, color: AppColor.primary.withValues(alpha: .4)),
                _buildRipple(size: 220.w, color: AppColor.primary),

                // The Map Circle
                Container(
                  height: 180.w,
                  width: 180.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),

                // Pin Icon
                Image.asset(
                  IconPath.locationKey,
                  width: 48.w,
                )
              ],
            ),
          ),

          const Spacer(),

          // 2. Bottom Information Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "Allow Access",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: "Service unavailable at your location. We'll notify you when access is enabled.",
                  textAlign: TextAlign.center,
                  fontSize: 14.sp,
                  color: AppColor.grey500,
                ),
                SizedBox(height: 32.h),

                // 3. Action Button
                CustomButton(
                    text: "Done",
                    backgroundColor: AppColor.primary,
                    textColor: Colors.black,
                    borderRadius: 16.r,
                    onPressed: (){
                      context.push('/loginScreen');
                    }
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
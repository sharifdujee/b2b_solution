import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';

class QuickActionItem extends ConsumerWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const QuickActionItem({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          onTap!();

        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColor.quickActionColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColor.white, size: 24.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
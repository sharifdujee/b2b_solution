import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';

class QuickActionItem extends ConsumerWidget {
  final String label;
  final String icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const QuickActionItem({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.quickActionColor : AppColor.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                offset:  Offset(0, 1),
                color: AppColor.secondary.withValues(alpha: 0.6)
              ),
              BoxShadow(
                  blurRadius: 8,
                  offset:  Offset(0, 4),
                  color: AppColor.secondary.withValues(alpha: 0.12)
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                icon,
                height: 40.h,
                width: 40.w,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColor.white : AppColor.black,
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
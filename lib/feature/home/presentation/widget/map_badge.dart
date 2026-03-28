import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';


class MapBadge extends ConsumerWidget {
  final String label;
  final IconData icon;

  const MapBadge({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.white, size: 14.sp),
          SizedBox(width: 4.w),
          CustomText(
            text:  label,

            color: AppColor.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,

          ),
        ],
      ),
    );
  }
}
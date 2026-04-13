import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/app_color.dart';
import '../gloabal/custom_text.dart';

class PriorityBadge extends StatelessWidget {
  final String? urgencyLevel;

  const PriorityBadge({
    super.key,
    required this.urgencyLevel,
  });



  Color _getBgColor(String level) {
    switch (level.toUpperCase()) {
      case 'EMERGENCY':
        return AppColor.emergencyBadgeText;
      case 'MODERATE':
        return AppColor.moderateBadgeText;
      case 'GENERAL':
      default:
        return AppColor.generalBadgeText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayLevel = urgencyLevel?.toUpperCase() ?? 'GENERAL';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getBgColor(displayLevel),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: CustomText(
        text: displayLevel,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        color: AppColor.white,
        letterSpacing: 0.5,
      ),
    );
  }
}
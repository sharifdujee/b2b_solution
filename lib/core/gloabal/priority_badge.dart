import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../feature/ping/model/ping_model.dart';
import '../design_system/app_color.dart';
import '../gloabal/custom_text.dart';

class PriorityBadge extends StatelessWidget {
  final PingPriority priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  Color _getBgColor() {
    switch (priority) {
      case PingPriority.emergency:
        return AppColor.emergencyBadge;
      case PingPriority.moderate:
        return AppColor.moderateBadge;
      case PingPriority.general:
        return AppColor.generalBadge;
    }
  }

  Color _getTextColor() {
    switch (priority) {
      case PingPriority.emergency:
        return AppColor.emergencyBadgeText;
      case PingPriority.moderate:
        return AppColor.moderateBadgeText;
      case PingPriority.general:
        return AppColor.generalBadgeText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: CustomText(
        text: priority.name.toUpperCase(),
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        color: _getTextColor(),
        letterSpacing: 0.5,
      ),
    );
  }
}
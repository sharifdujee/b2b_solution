import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../feature/ping/model/create_ping_model.dart';
import '../design_system/app_color.dart';
import '../gloabal/custom_text.dart';

class UrgencySelector extends StatelessWidget {
  final UrgencyLevel selected;
  final Function(UrgencyLevel) onSelected;

  static const List<UrgencyLevel> urgencyOptions = UrgencyLevel.values;

  const UrgencySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  Color _getColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.EMERGENCY:
        return AppColor.emergencyBadgeText;
      case UrgencyLevel.MODERATE:
        return AppColor.moderateBadgeText;
      case UrgencyLevel.GENERAL:
        return AppColor.generalBadgeText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: urgencyOptions.map((level) {
        final isSelected = level == selected;
        final color = _getColor(level);
        final bool isLast = level == urgencyOptions.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? color : AppColor.grey100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 18.h,
                    width: 18.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: level.name[0] + level.name.substring(1).toLowerCase(),
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? color : AppColor.grey700,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
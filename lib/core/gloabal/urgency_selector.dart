import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/app_color.dart';
import '../gloabal/custom_text.dart';

class UrgencySelector extends StatelessWidget {
  final String selected; // Changed from PingPriority to String
  final Function(String) onChanged;

  // Define the available options as a static list for consistency
  static const List<String> urgencyOptions = ['EMERGENCY', 'MODERATE', 'GENERAL'];

  const UrgencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  // Helper to get theme colors based on the string value
  Color _getColor(String level) {
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
    return Row(
      children: urgencyOptions.map((level) {
        final isSelected = level.toUpperCase() == selected.toUpperCase();
        final color = _getColor(level);

        // Check if this is the last item to remove the right margin
        final bool isLast = level == urgencyOptions.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? color : AppColor.grey100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Indicator Dot/Square
                  Container(
                    height: 18.h,
                    width: 18.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Priority Text (Capitalized first letter)
                  CustomText(
                    text: level[0].toUpperCase() + level.substring(1).toLowerCase(),
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
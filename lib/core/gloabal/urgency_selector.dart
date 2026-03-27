import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../feature/ping/model/ping_model.dart';
import '../design_system/app_color.dart';
import '../gloabal/custom_text.dart';

class UrgencySelector extends StatelessWidget {
  final PingPriority selected;
  final Function(PingPriority) onChanged;

  const UrgencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Color _getColor(PingPriority priority) {
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
    return Row(
      children: PingPriority.values.map((priority) {
        final isSelected = priority == selected;
        final color = _getColor(priority);

        // PIXEL PERFECT: Check if this is the last item to remove the right margin
        final bool isLast = priority == PingPriority.values.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(priority),
            child: AnimatedContainer( // Switched to AnimatedContainer for smooth transitions
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 10.w), // Space between items
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  // When not selected, use a subtle grey border to define the shape
                  color: isSelected ? color : AppColor.grey100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Indicator Dot
                  Container(
                    height: 18.h,
                    width: 18.w,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.r)
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Priority Text
                  CustomText(
                    text: priority.name[0].toUpperCase() +
                        priority.name.substring(1),
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../design_system/app_color.dart';
import 'custom_text.dart';

class RadiusSelector extends StatelessWidget {
  final int selectedRadius;
  final Function(int) onChanged;

  const RadiusSelector({
    super.key,
    required this.selectedRadius,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> radiusOptions = [5, 10, 15, 20];

    return Row(
      children: radiusOptions.map((radius) {
        final isSelected = radius == selectedRadius;
        final bool isLast = radius == radiusOptions.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 10.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColor.primary : AppColor.grey100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: CustomText(
                  text: "$radius KM",
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColor.primary : AppColor.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
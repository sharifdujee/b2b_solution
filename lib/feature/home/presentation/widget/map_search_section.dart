import 'package:flutter/material.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';

class MapSearchSection extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const MapSearchSection({super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: TextStyle(fontSize: 14.sp, color: AppColor.black),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                  TextStyle(color: AppColor.grey500, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.grey500, size: 20.sp),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close,
                        color: AppColor.grey500, size: 18.sp),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColor.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.tune_rounded,
                  color: AppColor.black, size: 22.sp),
            ),
          )
        ],
      ),
    );
  }
}
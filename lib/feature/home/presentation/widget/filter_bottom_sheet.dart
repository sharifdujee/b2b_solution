import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../data/place_location.dart';
import '../../provider/filter_provider.dart';
class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingFilterProvider);
    final notifier = ref.read(pendingFilterProvider.notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Center(
            child: Text('Filter By',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.black)),
          ),
          SizedBox(height: 24.h),

          // ── Category ─────────────────────────────
          Text('Category',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: FoodCategory.values.map((cat) {
              final selected = pending.selectedCategory == cat;
              return FilterChip(
                label: cat.label,
                selected: selected,
                onTap: () => notifier.setCategory(cat),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // ── Radius ───────────────────────────────
          Text('Radius',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: RadiusOption.values.map((r) {
              final selected = pending.selectedRadius == r;
              return FilterChip(
                label: r.label,
                selected: selected,
                onTap: () => notifier.setRadius(r),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),

          // ── Apply Button ─────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                // Apply pending filter → live filter
                ref.read(filterProvider.notifier).state = FilterState(
                  selectedCategory: pending.selectedCategory,
                  selectedRadius:   pending.selectedRadius,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.accent,
                foregroundColor: AppColor.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text('Apply',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE FILTER CHIP
// ─────────────────────────────────────────────

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChip({super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppColor.secondary : AppColor.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColor.primary ,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: selected ? AppColor.primary : AppColor.black,
          ),
        ),
      ),
    );
  }
}
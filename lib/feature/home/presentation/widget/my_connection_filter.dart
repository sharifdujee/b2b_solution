import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';

class MyConnectionFilter extends ConsumerWidget {
  const MyConnectionFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(connectionFilterProvider);
    final counts = ref.watch(connectionCountsProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.grey300, width: 1.h),
        ),
      ),
      // Added SingleChildScrollView for horizontal scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildTab(
              ref,
              label: 'Connected',
              count: counts[ConnectionFilterOption.Connected],
              targetFilter: ConnectionFilterOption.Connected,
              isSelected: activeFilter == ConnectionFilterOption.Connected,
            ),
            _buildTab(
              ref,
              label: 'Pending',
              count: counts[ConnectionFilterOption.Pending],
              targetFilter: ConnectionFilterOption.Pending,
              isSelected: activeFilter == ConnectionFilterOption.Pending,
            ),
            _buildTab(
              ref,
              label: 'Find',
              targetFilter: ConnectionFilterOption.Find,
              isSelected: activeFilter == ConnectionFilterOption.Find,
            ),
            _buildTab(
              ref,
              label: 'Requests',
              count: counts[ConnectionFilterOption.Requests],
              targetFilter: ConnectionFilterOption.Requests,
              isSelected: activeFilter == ConnectionFilterOption.Requests,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
      WidgetRef ref, {
        required String label,
        int? count,
        required ConnectionFilterOption targetFilter,
        required bool isSelected,
      }) {
    final displayText = (count != null) ? '$label ($count)' : label;

    return GestureDetector(
      onTap: () => ref.read(connectionFilterProvider.notifier).updateFilter(targetFilter),
      behavior: HitTestBehavior.opaque,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColor.primary : AppColor.grey400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3.h,
              width: double.infinity, // Now "infinity" means "the width of the IntrinsicWidth"
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(2.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
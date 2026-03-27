import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Assuming you use this for sizing

import '../../provider/ping_provider.dart';

class PingFilterBar extends ConsumerWidget {
  const PingFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state from your NotifierProvider
    final activeFilter = ref.watch(pingFilterProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.grey300, width: 1.h),
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            ref,
            label: 'Active Pings',
            targetFilter: PingFilter.active,
            isSelected: activeFilter == PingFilter.active,
          ),
          _buildTab(
            ref,
            label: 'Accepted',
            targetFilter: PingFilter.accepted,
            isSelected: activeFilter == PingFilter.accepted,
          ),
          _buildTab(
            ref,
            label: 'My Pings',
            targetFilter: PingFilter.myPings,
            isSelected: activeFilter == PingFilter.myPings,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      WidgetRef ref, {
        required String label,
        required PingFilter targetFilter,
        required bool isSelected,
      }) {
    return Expanded(
      child: GestureDetector(
        // Calling the method defined in your Notifier class
        onTap: () => ref.read(pingFilterProvider.notifier).updateFilter(targetFilter),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColor.primary : AppColor.grey400,
                ),
              ),
            ),
            // Use AnimatedContainer for a smooth color transition
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3.h,
              width: double.infinity,
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
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart'; // Assuming you use this for sizing


class MyConnectionFilter extends ConsumerWidget {
  const MyConnectionFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state from your NotifierProvider
    final activeFilter = ref.watch(connectionFilterProvider);

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
            label: 'Connected',
            targetFilter: ConnectionFilterOption.Connected,
            isSelected: activeFilter == ConnectionFilterOption.Connected,
          ),
          _buildTab(
            ref,
            label: 'Pending',
            targetFilter: ConnectionFilterOption.Pending,
            isSelected: activeFilter == ConnectionFilterOption.Pending,
          ),
          _buildTab(
            ref,
            label: 'Find',
            targetFilter: ConnectionFilterOption.Find,
            isSelected: activeFilter == ConnectionFilterOption.Find,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      WidgetRef ref, {
        required String label,
        required ConnectionFilterOption targetFilter,
        required bool isSelected,
      }) {
    return Expanded(
      child: GestureDetector(
        // Calling the method defined in your Notifier class
        onTap: () => ref.read(connectionFilterProvider.notifier).updateFilter(targetFilter),
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
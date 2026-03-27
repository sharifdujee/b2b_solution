import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../provider/ping_provider.dart';
import '../widgets/ping_filter_bar.dart';
import '../widgets/ping_card.dart';

class PingScreen extends ConsumerWidget {
  const PingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Section
            Container(
              color: AppColor.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  CustomText(
                      text: "Ping",
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold
                  ),
                  const Spacer(),
                  _buildCreatePingButton(context),
                ],
              ),
            ),

            /// Fixed elements: Divider and Filter Bar
            const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
            SizedBox(height: 24.h,),
            Container(
              color: AppColor.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: PingFilterBar()
            ),

            /// Scrollable Card Area
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final filteredPings = ref.watch(filteredPingsProvider);

                  if (filteredPings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredPings.length,
                    itemBuilder: (context, index) => PingCard(ping: filteredPings[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create Ping Button consistent with screenshot
  Widget _buildCreatePingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/createPingScreen');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: AppColor.black, size: 18.sp),
            SizedBox(width: 4.w),
            CustomText(
              text: "Create Ping",
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder when no pings match the selected filter
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 48.sp, color: AppColor.grey400),
          SizedBox(height: 12.h),
          CustomText(
            text: "No pings found for this category",
            fontSize: 14.sp,
            color: AppColor.grey500,
          ),
        ],
      ),
    );
  }
}
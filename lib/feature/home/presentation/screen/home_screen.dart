import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/feature/navigation/presentation/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../ping/presentation/widgets/ping_card.dart';
import '../../../ping/provider/ping_provider.dart';
import '../widget/map_section.dart';
import '../widget/quick_action.dart';
import '../widget/top_section.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(

      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 48.h),

            // ── Top Bar ──────────────────────────────────────────────────────
            TopSection(),

            SizedBox(height: 16.h),

            // ── Map Section ──────────────────────────────────────────────────
            MapSection(),

            SizedBox(height: 24.h),

            // ── Quick Actions ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomText(
                text: "Quick Actions",
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,

              ),
            ),
            SizedBox(height: 12.h),
            QuickActions(),

            SizedBox(height: 24.h),

            // ── Nearby Ping Requests ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Nearby Ping Requests",
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: AppColor.black,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state =1;
                    },
                    child: CustomText(
                      text: "View All",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
        Consumer(
          builder: (context, ref, child) {
            final filteredPings = ref.watch(filteredPingsProvider);

            if (filteredPings.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPings.length > 3 ? 3 : filteredPings.length, // Logic for "itemCount: 3"
              itemBuilder: (context, index) => PingCard(ping: filteredPings[index]),
            );
          },),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
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






















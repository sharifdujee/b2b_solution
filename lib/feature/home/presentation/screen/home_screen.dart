import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


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
                    onTap: () {},
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


            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}






















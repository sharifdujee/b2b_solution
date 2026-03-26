import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class PrivacyPolicy extends ConsumerWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(
                      IconPath.arrowLeft,
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CustomText(
                    text: "Privacy Policy",
                    fontSize: 20.sp,
                    color: AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Divider(thickness: 0.5),
              SizedBox(height: 24.h),

              // --- Scrollable Content ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1
                      _SectionTitle(title: "1. Information We Collect"),
                      SizedBox(height: 12.h),
                      _BulletItem(text: "Business & Profile Information"),
                      _BulletItem(text: "Email address and phone number"),
                      _BulletItem(
                          text: "Profile details (services, availability, pricing)"),
                      _BulletItem(
                          text: "Business location (address, GPS location)"),

                      SizedBox(height: 24.h),

                      // Section 2
                      _SectionTitle(title: "2. Usage & Activity Data"),
                      SizedBox(height: 12.h),
                      _BulletItem(text: "Pings you send or receive"),
                      _BulletItem(
                          text: "Messages and interactions with other users"),
                      _BulletItem(
                          text:
                          "App usage behavior (features used, activity logs)"),

                      SizedBox(height: 24.h),

                      // Section 3
                      _SectionTitle(title: "3. Sharing of Information"),
                      SizedBox(height: 12.h),
                      _BulletItem(
                          text:
                          "With other users: Basic business details (name, location, services) are visible to enable connections"),
                      _BulletItem(
                          text:
                          "With service providers: To support app functionality (e.g., hosting, notifications)"),
                      _BulletItem(
                          text:
                          "Legal requirements: If required by law or to protect our rights"),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: title,
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 8.w),
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: CustomText(
              text: text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
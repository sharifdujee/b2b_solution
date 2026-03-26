import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class TermsConditions extends ConsumerWidget {
  const TermsConditions({super.key});

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
                    text: "Terms of Service",
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
                      // Section 1 - Introduction
                      _SectionTitle(title: "1. Introduction"),
                      SizedBox(height: 10.h),
                      _BodyText(
                        text:
                        "Welcome to our platform. This app connects restaurant owners and business vendors, enabling them to request and provide urgent supplies through a real-time \"Ping\" system. By using our services, you agree to these terms.",
                      ),

                      SizedBox(height: 24.h),

                      // Section 2 - Account & Registration
                      _SectionTitle(title: "2. Account & Registration"),
                      SizedBox(height: 12.h),
                      _BulletItem(
                          text:
                          "You must provide accurate and complete business information when creating an account."),
                      _BulletItem(
                          text:
                          "You are responsible for maintaining the confidentiality of your account credentials."),
                      _BulletItem(
                          text:
                          "Only verified businesses (restaurants/vendors) are allowed to use the platform."),
                      _BulletItem(
                          text:
                          "We reserve the right to suspend or terminate accounts that violate these terms."),

                      SizedBox(height: 24.h),

                      // Section 3 - Use of the Platform
                      _SectionTitle(title: "2. Use of the Platform"),
                      SizedBox(height: 12.h),
                      _BulletItem(
                          text:
                          "The platform is intended for business-to-business support and supply sharing."),
                      _BulletItem(
                          text:
                          "Users can send \"Pings\" to request items such as ingredients, tools, or urgent supplies."),
                      _BulletItem(
                          text:
                          "You agree to use the platform honestly and not misuse it for spam, fraud, or illegal activities."),
                      _BulletItem(
                          text:
                          "Any agreement made between users (pricing, delivery, etc.) is their own responsibility."),

                      SizedBox(height: 24.h),

                      // Section 4 - Data & Privacy
                      _SectionTitle(title: "2. Data & Privacy"),
                      SizedBox(height: 12.h),
                      _BulletItem(
                          text:
                          "Business profile details (name, contact info, location)"),
                      _BulletItem(
                          text: "Verification data (e.g., registration details)"),
                      _BulletItem(
                          text: "Service information (availability, pricing, items)"),

                      SizedBox(height: 24.h),

                      // Contact Us
                      _SectionTitle(title: "Contact Us"),
                      SizedBox(height: 10.h),
                      _BodyText(
                        text:
                        "Questions about your privacy? Reach out to us:\nEmail: support@sha3ra.com",
                      ),

                      SizedBox(height: 32.h),
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
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColor.black,
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
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/priority_badge.dart'; // ✅ import this
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../model/ping_model.dart';
import '../../provider/ping_provider.dart';

class PingCard extends StatelessWidget {
  final PingModel ping;

  const PingCard({super.key, required this.ping});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 0), // shadow all sides
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  padding: EdgeInsets.all(1.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColor.grey100,
                    backgroundImage: AssetImage(ping.logoUrl),
                  ),
                ),

                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: ping.shopName,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),

                          // ✅ Reusable Badge
                          PriorityBadge(priority: ping.priority),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      CustomText(
                        text: "Needs: ${ping.needs}",
                        fontSize: 14.sp,
                        color: AppColor.grey600,
                      ),

                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          Image.asset(
                            IconPath.location05,
                            height: 16.h,
                            width: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: ping.distance,
                            fontSize: 12.sp,
                            color: AppColor.grey500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            if (ping.category != PingFilter.accepted)...[
              CustomButton(
                text: "Details",
                height: 44.h,
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                borderRadius: 10.r,
                backgroundColor: AppColor.primary,
                textColor: AppColor.black,
                onPressed: () {
                  context.push(
                    '/pingDetails',
                    extra: ping,
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
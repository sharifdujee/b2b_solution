import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/priority_badge.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// Note: Ensure this points to the file where Datum is defined
import '../../model/ping_model.dart';

class PingCard extends StatelessWidget {
  final Datum ping;

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
            color: AppColor.secondary.withValues(alpha: 0.6),
            blurRadius: 15,
            offset: const Offset(0, 0),
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
                Container(
                  padding: EdgeInsets.all(1.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.secondary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      )
                    ]
                  ),
                  child: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColor.grey100,
                    backgroundImage: NetworkImage(ping.user!.profileImage),
                  ),
                ),

                SizedBox(width: 12.w),

                // --- Content ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: ping.user!.businessName,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          PriorityBadge(urgencyLevel: ping.urgencyLevel),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      CustomText(
                        text: "Needs: ${ping.itemName}",
                        fontSize: 14.sp,
                        color: AppColor.grey600,
                      ),

                      SizedBox(height: 8.h),

                      // Distance Row
                      Row(
                        children: [
                          Image.asset(
                            IconPath.location05,
                            height: 16.h,
                            width: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: "${ping.distanceKm} km away",
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

            // Details Button
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
          ],
        ),
      ),
    );
  }

  dynamic _parsePriority(String urgency) {
    return urgency;
  }
}
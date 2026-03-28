import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/notification_procider.dart';


class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        // Added bottom padding to ensure content isn't cut off
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
                  ),
                  SizedBox(width: 10.w),
                  CustomText(
                    text: "Notification",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Divider(color: AppColor.grey50),
              SizedBox(height: 24.h),

              // --- FIXED SECTION ---
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.length,
                itemBuilder: (context, index) {
                  final notification = state[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: notification.isRead ? AppColor.white : AppColor.secondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(width: 2, color: notification.isRead ? AppColor.grey50 : AppColor.primary.withValues(alpha: 0.5))
                    ),
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                            child: notification.isRead? Icon(Icons.notifications_none, color: AppColor.primary, size: 20.r) : Icon(Icons.notifications_active, color: AppColor.primary, size: 20.r),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: notification.title,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: AppColor.black,
                                ),
                                SizedBox(height: 4.h),
                                CustomText(
                                  text: notification.subTitle,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.grey400,
                                ),
                              ],
                            ),
                          ),
                          CustomText(
                            text: notification.formattedTime,
                            fontSize: 10.sp,
                            color: AppColor.grey400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
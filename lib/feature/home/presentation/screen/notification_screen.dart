import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    // Initial fetch
    Future.microtask(() =>
        ref.read(notificationProvider.notifier).fetchNotifications(filter: selectedFilter)
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final controller = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom AppBar with Filter ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
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
                  const Spacer(),



                  // --- Filter Menu ---
                  PopupMenuButton<String>(
                    initialValue: selectedFilter,
                    icon: Icon(Icons.tune, color: AppColor.primary, size: 24.r),
                    onSelected: (value) {
                      setState(() => selectedFilter = value);
                      controller.fetchNotifications(filter: value);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    itemBuilder: (context) => [
                      _buildMenuItem("all", "All Notifications", Icons.clear_all),
                      _buildMenuItem("false", "Unread", Icons.mark_as_unread),
                      _buildMenuItem("true", "Read", Icons.done_all),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: AppColor.grey50, height: 1),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 20.w),
                  GestureDetector(
                    onTap: () => controller.toggleAllReadStatus(
                      state.notifications.every((n) => n.isRead == true),
                    ),
                    child: CustomText(
                      text: "Mark All as Read",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),

            // --- Body Content ---
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(filter: selectedFilter),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];

                    // Dynamic styling based on read status
                    final isUnread = notification.isRead == false;

                    return Container(
                      decoration: BoxDecoration(
                        color: isUnread
                            ? AppColor.primary.withValues(alpha: 0.05)
                            : AppColor.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            width: 1,
                            color: isUnread ? AppColor.primary.withOpacity(0.2) : AppColor.grey50
                        ),
                      ),
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.r),
                        leading: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColor.primary.withOpacity(0.1),
                          child: Icon(
                            isUnread ? Icons.notifications_active : Icons.notifications_none,
                            color: AppColor.primary,
                            size: 20.r,
                          ),
                        ),
                        title: CustomText(
                          text: notification.title ?? "No Title",
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColor.black,
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: CustomText(
                            text: notification.body ?? "",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColor.grey400,
                            maxLines: 2,
                          ),
                        ),
                        trailing: CustomText(
                          text: notification.createdAt != null
                              ? DateFormat('hh:mm a').format(notification.createdAt!)
                              : "",
                          fontSize: 10.sp,
                          color: AppColor.grey400,
                        ),
                        onTap: () {
                          if (isUnread) {
                            controller.markAsRead(notification.id!);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: selectedFilter == value ? AppColor.primary : AppColor.grey400),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(
              color: selectedFilter == value ? AppColor.primary : AppColor.black,
              fontWeight: selectedFilter == value ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64.r, color: AppColor.grey300),
          SizedBox(height: 16.h),
          CustomText(text: "No notifications found", color: AppColor.grey400),
        ],
      ),
    );
  }
}
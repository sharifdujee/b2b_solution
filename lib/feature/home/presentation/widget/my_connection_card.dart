import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../model/find_connecion_state_model.dart';
import '../../model/my_connection_state_model.dart';
import '../../model/send_request_state_model.dart'; // Ensure this is imported
import '../../provider/my_connection_filter_provider.dart';

class MyConnectionCard extends ConsumerWidget {
  final dynamic connectionData;
  final String currentUserId;

  const MyConnectionCard({
    super.key,
    required this.connectionData,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(connectionFilterProvider);

    // --- Data Extraction Logic ---
    final bool isFindModel = connectionData is FindDatum;
    final bool isRequestModel = connectionData is SendRequestResultDatum;

    // Helper to get the correct user data based on type
    final dynamic displayUser;
    if (isFindModel) {
      displayUser = connectionData;
    } else if (isRequestModel) {
      // For Requests, the data is in the receiver object
      displayUser = connectionData.receiver;
    } else {
      // For Connected/Pending, we use your existing helper method
      displayUser = (connectionData as MyConnectionStateModel).getDisplayUser(currentUserId);
    }

    // Now safely extract fields from the 'displayUser' we identified
    final String fullName = displayUser?.businessName ?? displayUser?.fullName ?? "Unknown";
    final String? profileImage = displayUser?.profileImage;
    final String position = displayUser?.position ?? "Business Member";

    final String categories = (displayUser?.businessCategory is List)
        ? (displayUser.businessCategory as List).join(", ")
        : "No categories listed";

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(profileImage),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: fullName,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                      ),
                    ),
                    _buildTopAction(currentFilter, context, ref),
                  ],
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(IconPath.location05, position),
                SizedBox(height: 8.h),
                CustomText(
                  text: categories,
                  fontSize: 13.sp,
                  color: AppColor.grey800,
                  maxLines: 2,
                ),
                // Show Accept/Reject only for the Pending tab
                if (!isFindModel && !isRequestModel && currentFilter == ConnectionFilterOption.Pending)
                  _buildPendingActions(ref, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... rest of your helper methods (Avatar, InfoRow, etc.) remain the same

  Widget _buildAvatar(String? imageUrl) {
    return Container(
      padding: EdgeInsets.all(1.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColor.grey100,
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? NetworkImage(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: AppColor.grey400, size: 24.r)
            : null,
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      children: [
        Image.asset(icon, height: 14.h, width: 14.w),
        SizedBox(width: 4.w),
        Expanded(
          child: CustomText(
            text: text,
            fontSize: 12.sp,
            color: AppColor.grey500,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAction(ConnectionFilterOption filter, BuildContext context, WidgetRef ref) {
    return _actionButton(
      text: "Details",
      bg: AppColor.primary,
      txtColor: AppColor.black,
      onTap: () {
        String statusHint;
        switch (filter) {
          case ConnectionFilterOption.Find:
            statusHint = 'FIND';
            break;
          case ConnectionFilterOption.Pending:
            statusHint = 'PENDING';
            break;
          case ConnectionFilterOption.Connected:
            statusHint = 'CONNECTED';
            break;
          case ConnectionFilterOption.Requests:
            statusHint = 'REQUEST';
            break;
        }

        context.push(
          "/businessCardScreen",
          extra: {
            'connectionData': connectionData,
            'currentUserId': currentUserId,
            'status': statusHint,
          },
        );
      },
    );
  }

  Widget _buildPendingActions(WidgetRef ref, BuildContext context) {
    final notifier = ref.read(myConnectionListProvider.notifier);
    final connection = connectionData as MyConnectionStateModel;

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _actionButton(
            text: "Reject",
            bg: AppColor.emergencyBadgeText,
            txtColor: AppColor.white,
            onTap: () => notifier.rejectConnection(connection.id, context),
          ),
          SizedBox(width: 8.w),
          _actionButton(
            text: "Accept",
            bg: AppColor.primary,
            txtColor: AppColor.black,
            onTap: () => notifier.acceptConnection(connection.id, context),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required VoidCallback onTap,
    required Color bg,
    required Color txtColor,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.r, color: txtColor),
              SizedBox(width: 4.w),
            ],
            CustomText(
              text: text,
              color: txtColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
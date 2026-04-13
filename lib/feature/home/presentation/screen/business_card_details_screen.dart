import 'dart:developer';

import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../model/my_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';

class BusinessCardScreen extends ConsumerWidget {
  final MyConnectionStateModel connection;
  final String currentUserId;

  const BusinessCardScreen({
    super.key,
    required this.connection,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get display data for the "other" person
    final displayUser = connection.getDisplayUser(currentUserId);

    // Watch the list provider to get the most up-to-date status
    // (e.g., if Accept/Reject is clicked while on this screen)
    final connectionState = ref.watch(myConnectionListProvider);
    final activeConnection = connectionState.items.firstWhere(
          (element) => element.id == connection.id,
      orElse: () => connection,
    );

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    text: "Business Card Details",
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // --- Brand Image Card ---
              _buildBrandImage(displayUser),

              SizedBox(height: 14.h),

              // --- Name and Membership Header ---
              _buildNameHeader(displayUser, activeConnection),

              SizedBox(height: 16.h),

              _buildDashedLine(),

              SizedBox(height: 14.h),

              // --- Detail Rows ---
              _buildDetailRow(
                IconPath.restaurantIcon,
                "Fast Food Restaurant",
                displayUser?.businessCategory.firstOrNull ?? "N/A",
              ),
              SizedBox(height: 14.h),
              _buildDetailRow(
                IconPath.phoneCall,
                "Phone",
                "${displayUser?.operationYears ?? 0} Years",
              ),
              SizedBox(height: 14.h),
              // Added Legal Name row back into the details
              _buildDetailRow(
                IconPath.mail,
                "Email",
                displayUser?.legalName ?? "N/A",
              ),

              SizedBox(height: 42.h),

              _buildActionButtons(ref, activeConnection, context),

              SizedBox(height: 16.h),

              if (activeConnection.status == "accepted")
                _buildMessageButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandImage(ConnectionUserData? displayUser) {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: displayUser?.businessImage != null && displayUser!.businessImage!.isNotEmpty
            ? Image.network(
          displayUser.businessImage!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.business,
            size: 60.r,
            color: AppColor.black.withOpacity(0.3),
          ),
        )
            : Icon(Icons.business, size: 60.r, color: AppColor.black.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildNameHeader(ConnectionUserData? displayUser, MyConnectionStateModel activeConnection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomText(
                text: displayUser?.businessName ?? displayUser?.fullName ?? "N/A",
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
                maxLines: 1,
              ),
            ),
            Row(
              children: [
                CustomText(text: "Member Since: ", fontSize: 12.sp, color: AppColor.grey400),
                CustomText(
                  text: activeConnection.createdAt.year.toString(),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: displayUser?.position ?? "Business Professional",
          fontSize: 12.sp,
          color: AppColor.grey400,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Row(
      children: [
        Image.asset(icon, height: 20.h, width: 20.w),
        SizedBox(width: 8.w),
        CustomText(text: label, fontSize: 14.sp, color: AppColor.grey400),
        const Spacer(),
        CustomText(
          text: value,
          fontSize: 14.sp,
          textAlign: TextAlign.right,
          fontWeight: FontWeight.w500,
          color: AppColor.black,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 4.w,
              height: 1.h,
              child: DecoratedBox(decoration: BoxDecoration(color: AppColor.grey100)),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButtons(WidgetRef ref, MyConnectionStateModel item, BuildContext context) {
    final notifier = ref.read(myConnectionListProvider.notifier);
    final String status = item.status?.toLowerCase() ?? "";

    // 1. Current user is the receiver and the request is pending
    if (status == "pending" && item.receiverId == currentUserId) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Reject",
              textColor: AppColor.white,
              backgroundColor: AppColor.emergencyBadgeText,
              borderRadius: 16.r,
              onPressed: () => notifier.rejectConnection(item.id),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomButton(
              text: "Accept",
              textColor: AppColor.black,
              backgroundColor: AppColor.primary,
              borderRadius: 16.r,
              onPressed: () => notifier.acceptConnection(item.id),
            ),
          ),
        ],
      );
    }

    // 2. Current user is the sender and request is still pending
    if (status == "pending" && item.senderId == currentUserId) {

      return CustomButton(
        text: "Request Sent",
        textColor: AppColor.grey400,
        backgroundColor: AppColor.grey100,
        borderRadius: 16.r,
        onPressed: null, // Disabled state
      );
    }

    // 3. Already connected
    if (status == "accepted") {
      log("status : $status");
      return CustomButton(
        text: "Connected",
        textColor: AppColor.white,
        backgroundColor: AppColor.secondary,
        borderRadius: 16.r,
        onPressed: () {}, // Perhaps open connection info
      );
    }

    // 4. Fallback/Default (For 'Find' tab or unknown states)
    return CustomButton(
      text: "Connect",
      textColor: AppColor.black,
      backgroundColor: AppColor.primary,
      borderRadius: 16.r,
      onPressed: () {
        // notifier.sendConnectionRequest(item.id);
      },
    );
  }

  Widget _buildMessageButton() {
    return GestureDetector(
      onTap: () {/* Message Logic */},
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(width: 1, color: AppColor.primary),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(IconPath.chat, height: 24.h, width: 24.w),
            SizedBox(width: 8.w),
            CustomText(
              text: "Message",
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.primary,
            ),
          ],
        ),
      ),
    );
  }
}
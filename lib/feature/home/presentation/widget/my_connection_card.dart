import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/home/model/my_connection_state_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../provider/my_connection_filter_provider.dart';

class MyConnectionCard extends ConsumerWidget {
  final MyConnectionStateModel connection;
  const MyConnectionCard({super.key, required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(connectionFilterProvider);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: connection.name,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                      ),
                    ),
                    _buildTopAction(currentFilter, context, connection),
                  ],
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(IconPath.location05, connection.address),
                SizedBox(height: 8.h),
                CustomText(
                  text: connection.note,
                  fontSize: 13.sp,
                  color: AppColor.grey800,
                  maxLines: 2,
                ),
                if (currentFilter == ConnectionFilterOption.Pending)
                  _buildPendingActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAvatar() {
    return Container(
      padding: EdgeInsets.all(1.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColor.grey100,
        backgroundImage: AssetImage(connection.icon),
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

  Widget _buildTopAction(ConnectionFilterOption filter, BuildContext context, MyConnectionStateModel connection) {
    if (filter == ConnectionFilterOption.Connected || filter == ConnectionFilterOption.Find) {
      return _actionButton(
        text: "Details",
        bg: AppColor.primary,
        txtColor: AppColor.black,
        onTap: () {
          context.push("/businessCardScreen", extra: connection);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPendingActions() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _actionButton(
            text: "Reject",
            bg: AppColor.emergencyBadgeText,
            txtColor: AppColor.white,
            onTap: () {
              debugPrint("Rejecting request");
            },
          ),
          SizedBox(width: 8.w),
          _actionButton(
            text: "Accept",
            bg: AppColor.primary,
            txtColor: AppColor.black,
            onTap: () {
              debugPrint("Accepting request");
            },
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
              Icon(icon, size: 16.r),
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
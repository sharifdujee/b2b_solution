import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../ping/model/ping_model.dart';

class SelectedPingCard extends ConsumerWidget {
  final Datum ping;

  const SelectedPingCard({super.key, required this.ping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Shop Profile Image ──────────────────────────────────────────
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              image: ping.user?.profileImage != null
                  ? DecorationImage(
                  image: NetworkImage(ping.user!.profileImage),
                  fit: BoxFit.cover)
                  : null,
            ),
            child: ping.user?.profileImage == null
                ? Icon(Icons.storefront, color: AppColor.primary, size: 20.sp)
                : null,
          ),
          SizedBox(width: 10.w),

          // ── Text Content ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ping.user?.businessName ?? "Unknown Business",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  "${ping.itemName} • ${ping.distanceKm} km away",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.welcomeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Action Button ───────────────────────────────────────────────
          GestureDetector(
            onTap: () {

              _showSnack(context, "Requesting details...");
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Details", // Changed to Details as per modern B2B flows
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
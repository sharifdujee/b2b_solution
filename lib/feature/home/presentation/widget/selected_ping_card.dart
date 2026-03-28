import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../data/ping_request.dart';
import '../../provider/png_provider.dart';

class SelectedPingCard extends ConsumerWidget {
  final PingRequest ping;

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
            color: AppColor.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon circle
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _categoryIcon(ping.category),
                color: AppColor.primary,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ping.title,
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
                  "${ping.vendorName}  •  ${ping.distanceKm} km away",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.welcomeColor,
                  ),
                ),
              ],
            ),
          ),

          // Accept quick action
          GestureDetector(
            onTap: () {
              ref.read(pingProvider.notifier).updatePingStatus(ping.id, PingStatus.accepted);
              _showSnack(context, "Ping accepted ✓");
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Accept",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Coffee':
        return Icons.local_cafe_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Retail':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../ping/model/connection_model.dart';
import '../../model/connected_state_model.dart' hide ConnectionUser;
import '../../model/find_connecion_state_model.dart';
import '../../model/my_connection_state_model.dart';
import '../../model/pending_connection_state_model.dart' hide ConnectionUser;
import '../../model/send_request_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';

class MyConnectionCard extends ConsumerWidget {
  final dynamic connectionData;
  final String currentUserId;

  const MyConnectionCard({
    super.key,
    required this.connectionData,
    required this.currentUserId, required void Function() onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(connectionFilterProvider);

    // --- Type Check Flags ---
    final bool isFindModel = connectionData is FindDatum;
    final bool isRequestModel = connectionData is SendRequestResultDatum;
    final bool isPendingModel = connectionData is PendingConnection;
    final bool isConnectedModel = connectionData is ConnectedConnection;
    final bool isSearchModel = connectionData is ConnectionModel;

    // --- Resolve Display User ---
    final dynamic displayUser;
    if (isSearchModel) {
      displayUser = (connectionData as ConnectionModel).getDisplayUser(currentUserId);
    } else if (isFindModel) {
      displayUser = connectionData;
    } else if (isRequestModel) {
      displayUser = (connectionData as SendRequestResultDatum).receiver;
    } else if (isPendingModel) {
      displayUser = (connectionData as PendingConnection).getDisplayPartner(currentUserId);
    } else if (isConnectedModel) {
      displayUser = (connectionData as ConnectedConnection).getDisplayPartner(currentUserId);
    } else {
      displayUser = null;
    }

    final String fullName = displayUser?.fullName ?? "Unknown";
    final String businessName = displayUser?.businessName ?? "No Business Name";
    final String? profileImage = displayUser?.profileImage;
    final String position = displayUser?.position ?? "Business Professional";

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
            color: Colors.black.withValues(alpha: 0.08),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: businessName, fontSize: 16.sp, fontWeight: FontWeight.w700, maxLines: 1),
                          CustomText(text: fullName, fontSize: 13.sp, color: AppColor.grey500, maxLines: 1),
                        ],
                      ),
                    ),
                    _buildTopAction(context),
                  ],
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(IconPath.location05, position),
                SizedBox(height: 8.h),
                CustomText(text: categories, fontSize: 12.sp, color: AppColor.grey800, maxLines: 2),
                if (isPendingModel && currentFilter == ConnectionFilterOption.Pending) _buildPendingActions(ref, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAction(BuildContext context) {
    return _actionButton(
      text: "Details",
      bg: AppColor.primary,
      txtColor: AppColor.white,
      onTap: () {
        // --- NEW NAVIGATION LOGIC ---
        if (connectionData is FindDatum) {
          context.push('/findBusinessCard', extra: connectionData);
        }
        else if (connectionData is SendRequestResultDatum) {
          context.push('/requestBusinessCard', extra: connectionData);
        }
        else if (connectionData is PendingConnection) {
          context.push('/pendingBusinessCard', extra: {
            'connection': connectionData,
            'currentUserId': currentUserId,
          });
        }
        else if (connectionData is ConnectedConnection) {
          context.push('/connectedBusinessCard', extra: {
            'connection': connectionData,
            'currentUserId': currentUserId,
          });
        }
        else if (connectionData is ConnectionModel) {
          // Logic for general Search Model mapping
          final searchModel = connectionData as ConnectionModel;
          if (searchModel.senderId.isEmpty) {
            // If sender is empty, treat as a "Find" result
            // Note: You may need to map ConnectionModel to FindDatum if types don't match
            context.push('/findBusinessCard', extra: searchModel);
          } else {
            // Treat as connected
            context.push('/connectedBusinessCard', extra: {
              'connection': searchModel,
              'currentUserId': currentUserId,
            });
          }
        }
      },
    );
  }

  Widget _buildPendingActions(WidgetRef ref, BuildContext context) {
    final notifier = ref.read(myConnectionListProvider.notifier);
    final connection = connectionData as PendingConnection;
    final partnerUserId = AuthService.id == connection.sender?.id ? connection.receiver?.id : connection.sender?.id;

    if (AuthService.id == connection.senderId) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: CustomText(text: "Request Sent", color: AppColor.grey400, fontSize: 12.sp),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _actionButton(
            text: "Reject",
            bg: AppColor.error,
            txtColor: AppColor.white,
            onTap: () => notifier.rejectConnection(partnerUserId!, context),
          ),
          SizedBox(width: 8.w),
          _actionButton(
            text: "Accept",
            bg: AppColor.secondary,
            txtColor: AppColor.white,
            onTap: () => notifier.acceptConnection(partnerUserId!, context),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required String text, required VoidCallback onTap, required Color bg, required Color txtColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
        child: CustomText(text: text, color: txtColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColor.grey100,
      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
      child: (imageUrl == null || imageUrl.isEmpty) ? Icon(Icons.person, color: AppColor.grey400, size: 24.r) : null,
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      children: [
        Image.asset(icon, height: 14.h, width: 14.w, color: AppColor.primary),
        SizedBox(width: 4.w),
        Expanded(child: CustomText(text: text, fontSize: 12.sp, color: AppColor.grey500, maxLines: 1)),
      ],
    );
  }
}
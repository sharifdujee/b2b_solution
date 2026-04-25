import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../../../core/gloabal/custom_dialog.dart' show showCustomDialog;
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/service/app_url.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/service/socket_service.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../message/provider/provider/message_provider.dart';
import '../../model/connected_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/base_business_card_layout.dart';

class ConnectedBusinessCardScreen extends ConsumerWidget {
  final ConnectedConnection connection;
  final String currentUserId;

  const ConnectedBusinessCardScreen({
    super.key,
    required this.connection,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = connection.getDisplayPartner(currentUserId);
    final partnerId = connection.getPartnerId(currentUserId);
    final isLoading = ref.watch(myConnectionListProvider).isLoading;

    return BaseBusinessCardLayout(
      title: "Connection Details",
      businessName: partner?.businessName ?? "N/A",
      fullName: partner?.fullName ?? "Unknown",
      position: partner?.position ?? "Business Professional",
      businessImage: partner?.businessImage,
      email: partner?.email ?? "N/A",
      lat: partner?.businessLatitude ?? 0.0,
      lng: partner?.businessLongitude ?? 0.0,
      memberSince: connection.createdAt,
      actions: [
        CustomButton(
          text: "Remove Connection",
          backgroundColor: AppColor.error,
          // Trigger the Popup here
          onPressed: isLoading ? null : () {
            showCustomDialog(
              context,
              imagePath: IconPath.confirmation,
              title: "Remove Connection?",
              message: "Are you sure you want to remove ${partner?.fullName} from your connections?",
              buttonText: "Cancel",
              button1Color: AppColor.white,
              secondButtonText: "Remove",
              isDoubleButton: true,
              button2Color: AppColor.error,
              onSecondPressed: () async {
                context.pop();
                await ref.read(myConnectionListProvider.notifier).removeConnection(partnerId, context);
                if (context.mounted) context.pop();
              },
            );
          },
        ),
        SizedBox(height: 16.h),
        _buildMessageButton(context, partnerId,ref),
      ],
    );
  }

  Widget _buildMessageButton(BuildContext context, String partnerId, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final notifier = ref.read(messagesProvider.notifier);

        SocketService _socket = SocketService();
        _socket.joinRoom(partnerId);
        final String? roomId = await notifier.getRoomId(partnerId);

        if (roomId != null && context.mounted) {
          notifier.joinRoom(roomId);
          context.push("/chatScreen", extra: roomId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to join chat room")),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColor.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(IconPath.chat, height: 24.h, width: 24.w, color: AppColor.primary),
            SizedBox(width: 8.w),
            CustomText(text: "Message", color: AppColor.primary, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
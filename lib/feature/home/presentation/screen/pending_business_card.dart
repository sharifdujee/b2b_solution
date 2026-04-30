import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../model/pending_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/base_business_card_layout.dart';

class PendingBusinessCardScreen extends ConsumerWidget {
  final PendingConnection connection;
  final String currentUserId;

  const PendingBusinessCardScreen({
    super.key,
    required this.connection,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = connection.getDisplayPartner(currentUserId);
    final notifier = ref.read(myConnectionListProvider.notifier);
    final isLoading = ref.watch(myConnectionListProvider).isLoading;

    return BaseBusinessCardLayout(
      title: "Pending Request",
      businessName: partner?.businessName ?? "N/A",
      fullName: partner?.fullName ?? "Unknown",
      position: partner?.position ?? "Business Professional",
      businessImage: partner?.businessImage,
      email: partner?.fullName ?? "N/A",
      lat: partner?.businessLatitude ?? 0.0,
      lng: partner?.businessLongitude ?? 0.0,
      memberSince: connection.createdAt,
      actions: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Reject",
                backgroundColor: AppColor.error.withOpacity(0.1),
                textColor: AppColor.error,
                onPressed: isLoading ? null : () async {
                  await notifier.rejectConnection(partner!.id, context);
                  if (context.mounted) context.pop();
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomButton(
                text: "Accept",
                backgroundColor: AppColor.primary,
                onPressed: isLoading ? null : () async {
                  await notifier.acceptConnection(partner!.id, context);
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
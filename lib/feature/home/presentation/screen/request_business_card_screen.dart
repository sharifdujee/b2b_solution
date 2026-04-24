import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../model/send_request_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/base_business_card_layout.dart';

class RequestBusinessCardScreen extends ConsumerWidget {
  final SendRequestResultDatum request;

  const RequestBusinessCardScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiver = request.receiver;
    final isLoading = ref.watch(myConnectionListProvider).isLoading;

    return BaseBusinessCardLayout(
      title: "Request Sent",
      businessName: receiver.businessName,
      fullName: receiver.fullName,
      position: receiver.position ?? "Business Professional",
      businessImage: receiver.businessImage,
      email: receiver.email,
      lat: receiver.businessLatitude,
      lng: receiver.businessLongitude,
      actions: [
        CustomButton(
          text: "Cancel Request",
          backgroundColor: AppColor.error,
          onPressed: isLoading ? null : () async {
            await ref.read(myConnectionListProvider.notifier).cancelRequest(request.id, context);
            if (context.mounted) context.pop();
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../model/find_connecion_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/base_business_card_layout.dart';

class FindBusinessCardScreen extends ConsumerWidget {
  final FindDatum user;

  const FindBusinessCardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(myConnectionListProvider).isLoading;

    return BaseBusinessCardLayout(
      title: "Business Card Details",
      businessName: user.businessName,
      fullName: user.fullName,
      position: user.position ?? "Business Professional",
      businessImage: user.businessImage,
      email: user.email,
      lat: user.businessLatitude,
      lng: user.businessLongitude,
      actions: [
        CustomButton(
          text: "Connect",
          backgroundColor: AppColor.primary,
          onPressed: isLoading ? null : () async {
            await ref.read(myConnectionListProvider.notifier).sendConnectionRequest(user.id, context);
            if (context.mounted) context.pop();
          },
        ),
      ],
    );
  }
}
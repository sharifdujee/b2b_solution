import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/gloabal/custom_dialog.dart';
import '../../../../core/gloabal/priority_badge.dart';
import '../../model/ping_model.dart';
import '../../provider/ping_provider.dart';

class PingDetails extends ConsumerWidget {
  final Datum ping;

  const PingDetails({super.key, required this.ping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(pingFilterProvider);
    final user = ping.user;
    final shopName = user?.businessName ?? "Unknown Shop";
    final profileImage = user?.profileImage ?? "";
    final address = "Lat: ${user?.businessLatitude}, Long: ${user?.businessLongitude}";

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    text: "Ping Details",
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Shop/Item Image - Updated to use NetworkImage for profileImage from Model
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: AppColor.grey100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: profileImage.isNotEmpty
                      ? Image.network(profileImage, fit: BoxFit.cover)
                      : Icon(Icons.business, size: 50.r, color: AppColor.grey400),
                ),
              ),

              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: shopName,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                  ),
                  // Note: Membership year isn't in your new model,
                  // using neededWithin or static as placeholder
                  CustomText(text: "Legal: ", fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColor.grey400),
                  CustomText(text: user?.legalName ?? "N/A", fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColor.black)
                ],
              ),

              CustomText(
                text: address,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.grey400,
              ),

              SizedBox(height: 16.h),
              _buildDashedDivider(),

              SizedBox(height: 16.h),
              Row(
                children: [
                  const Spacer(),
                  PriorityBadge(urgencyLevel: ping.urgencyLevel),
                ],
              ),

              SizedBox(height: 14.h),
              _buildInfoRow(IconPath.vegetarianFood, "Item Needed", ping.itemName),
              _buildInfoRow(IconPath.package, "Quantity", ping.quantity.toString()),
              _buildInfoRow(IconPath.unit, "Unit", ping.unit),
              _buildInfoRow(IconPath.timer02, "Needed within", "${ping.neededWithin} Days"),
              _buildInfoRow(IconPath.locationUser, "Distance", "${ping.distanceKm} Km"),


              _buildInfoRow(IconPath.notebook, "Notes", "General Requirement"),
              _buildInfoRow(IconPath.agreement, "Connection", "Direct"),

              SizedBox(height: 42.h),
              if(ping.userId != AuthService.id && currentFilter != PingFilter.accepted)...[
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                          text: "Decline Ping",
                          isOutlined: true,
                          textColor: AppColor.emergencyBadgeText,
                          backgroundColor: AppColor.white,
                          borderGradient: const LinearGradient(
                              colors: [AppColor.emergencyBadgeText, AppColor.emergencyBadgeText]
                          ),
                          borderWidth: 1,
                          borderRadius: 16.r,
                          onPressed: () {
                            showCustomDialog(
                              context,
                              imagePath: IconPath.confirmation,
                              title: "Decline",
                              buttonText: "cancel",
                              secondButtonText: "Decline",
                              button2Color: AppColor.error,
                              button1Color: AppColor.white,
                              isDoubleButton: true,
                              onPressed: () => context.pop(),
                              onSecondPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                );

                                await ref.read(pingListProvider.notifier).rejectPing(ping.id);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  context.pop();
                                }
                              },
                            );
                          }
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                          text: "Accept Ping",
                          textColor: AppColor.black,
                          backgroundColor: AppColor.primary,
                          borderRadius: 16.r,
                          onPressed: () {
                            showCustomDialog(
                              context,
                              imagePath: IconPath.shield,
                              title: "Accept",
                              buttonText: "Cancel",
                              secondButtonText: "Accept",
                              button2Color: AppColor.primary,
                              button1Color: AppColor.white,
                              isDoubleButton: true,
                              onPressed: () => context.pop(),
                              onSecondPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                );

                                await ref.read(pingListProvider.notifier).acceptPing(ping.id);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  context.pop();
                                }
                              },
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ]else if (ping.userId == AuthService.id && ping.user == null)...[
                CustomButton(
                    text: "Delete Ping",
                    isOutlined: true,
                    textColor: AppColor.black,
                    backgroundColor: AppColor.error,
                    borderWidth: 1,
                    borderRadius: 16.r,
                    onPressed: () {
                      showCustomDialog(
                        context,
                        imagePath: IconPath.confirmation,
                        title: "Delete Ping",
                        message: "Are you sure you want to delete this ping?",
                        buttonText: "Delete",
                        button1Color: AppColor.error,
                        isDoubleButton: true,
                        onSecondPressed: () => context.pop(),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: CircularProgressIndicator(
                                color: AppColor.primary,
                              ),
                            ),
                          );

                          await ref.read(pingListProvider.notifier).deletePing(ping.id);

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            context.pop();
                          }
                        },
                      );
                    }
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Helper to keep code clean
  Widget _buildInfoRow(String icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Image.asset(icon, height: 20.h, width: 20.w),
          SizedBox(width: 8.w),
          CustomText(
            text: title,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.grey400,
          ),
          const Spacer(),
          CustomText(
            text: value,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColor.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: AppColor.grey100)),
            );
          }),
        );
      },
    );
  }
}
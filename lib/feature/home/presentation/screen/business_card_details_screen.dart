import 'dart:developer';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../../model/find_connecion_state_model.dart';
import '../../model/my_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';

class BusinessCardScreen extends ConsumerWidget {
  final dynamic connectionData;
  final String currentUserId;
  final String status;

  const BusinessCardScreen({
    super.key,
    required this.connectionData,
    required this.currentUserId,
    required this.status,
  });

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Building a clean string: "City, Country"
        String street = place.street ?? '';
        String subLocality = place.subLocality ?? '';
        String city = place.locality ?? '';
        String country = place.country ?? '';

        return "$street, $subLocality, $city, $country".trim().replaceAll(RegExp(r'^, '), '');
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return "Localisation trouvée";
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFindModel = connectionData is FindDatum;

    // --- 1. Initialize variables with defaults to avoid "Non-nullable" errors ---
    String fullName = "N/A";
    String businessName = "N/A";
    String? businessImage;
    String position = "Business Professional";
    String experience = "0 Years";
    String email = "N/A"; // Fixed
    DateTime? memberSince;
    double lat = 0.0;
    double lng = 0.0;
    String address = "N/A";

    if (isFindModel) {
      final data = connectionData as FindDatum;
      fullName = data.fullName;
      businessName = data.businessName;
      businessImage = data.businessImage;
      position = data.position ?? "Business Professional";
      experience = "${data.operationYears} Years";
      email = data.email;
      memberSince = null;
      lat = data.businessLatitude;
      lng = data.businessLongitude;
    } else {
      final connection = connectionData as MyConnectionStateModel;
      final user = connection.getDisplayUser(currentUserId);
      fullName = user?.fullName ?? "N/A";
      email = user?.email ?? "N/A";
      businessName = user?.businessName ?? "N/A";
      businessImage = user?.businessImage;
      position = user?.position ?? "Business Professional";
      experience = "${user?.operationYears ?? 0} Years";
      memberSince = connection.createdAt;
    }

    final connectionState = ref.watch(myConnectionListProvider);

    MyConnectionStateModel? activeConnection;
    if (isFindModel) {
      activeConnection = connectionState.items.where(
              (e) => e.receiverId == (connectionData as FindDatum).id || e.senderId == (connectionData as FindDatum).id
      ).firstOrNull;
    } else {
      activeConnection = connectionState.items.where(
              (element) => element.id == (connectionData as MyConnectionStateModel).id
      ).firstOrNull ?? (connectionData as MyConnectionStateModel);
    }



    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 24.h),
              _buildBrandImage(businessImage),
              SizedBox(height: 14.h),
              _buildNameHeader(businessName, fullName, position, memberSince),
              SizedBox(height: 16.h),
              _buildDashedLine(),
              SizedBox(height: 14.h),
              FutureBuilder<String>(
                future: getAddressFromLatLng(lat, lng),
                builder: (context, snapshot) {
                  String displayAddress = "Loading...";

                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      displayAddress = snapshot.data!;
                    } else {
                      displayAddress = "Address not found";
                    }
                  }

                  return _buildDetailRow(
                    IconPath.restaurantIcon,
                    "Address",
                    displayAddress,
                  );
                },
              ),
              SizedBox(height: 14.h),
              //_buildDetailRow(IconPath.phoneCall, "Experience", experience),
              //SizedBox(height: 14.h),
              _buildDetailRow(IconPath.mail, "Email", email),
              SizedBox(height: 42.h),
              _buildUniversalActions(ref, activeConnection, isFindModel ? (connectionData as FindDatum).id : null, context),
              SizedBox(height: 16.h),
              if (activeConnection?.status?.toUpperCase() == "CONNECTED")
                _buildMessageButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header with conditional back button ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context)) ...[
          GestureDetector(
            onTap: () => context.pop(),
            child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
          ),
          SizedBox(width: 8.w),
        ],
        CustomText(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            text: "Business Card Details"
        ),
      ],
    );
  }

  Widget _buildBrandImage(String? imageUrl) {
    return Container(
      width: double.infinity, height: 300.h,
      decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(16.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.business, size: 60.r))
            : Icon(Icons.business, size: 60.r),
      ),
    );
  }

  Widget _buildNameHeader(String bName, String fName, String pos, DateTime? since) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: CustomText(text: bName, fontSize: 24.sp, fontWeight: FontWeight.w600, maxLines: 1)),
            if (since != null)
              CustomText(text: "Member Since: ${since.year}", fontSize: 12.sp, color: AppColor.grey400),
          ],
        ),
        SizedBox(height: 8.h),
        CustomText(text: pos, fontSize: 12.sp, color: AppColor.grey400),
      ],
    );
  }

  Widget _buildUniversalActions(WidgetRef ref, MyConnectionStateModel? item, String? findId, BuildContext context) {
    final notifier = ref.read(myConnectionListProvider.notifier);

    if (item == null) {
      return CustomButton(
        text: "Connect",
        backgroundColor: AppColor.primary,
        onPressed: () => notifier.sendConnectionRequest(findId!, context),
      );
    }

    final String itemStatus = item.status?.toUpperCase() ?? "";

    if (status == "PENDING" && item.receiverId == currentUserId) {
      return Row(
        children: [
          Expanded(child: CustomButton(text: "Reject", backgroundColor: AppColor.emergencyBadgeText, onPressed: () => notifier.rejectConnection(item.id, context))),
          SizedBox(width: 16.w),
          Expanded(child: CustomButton(text: "Accept", backgroundColor: AppColor.primary, onPressed: () => notifier.acceptConnection(item.id, context))),
        ],
      );
    }

    if (status == "PENDING") {
      return CustomButton(text: "Request Sent", backgroundColor: AppColor.grey100, textColor: AppColor.grey400, onPressed: null);
    }

    if (status == "CONNECTED") {
      return CustomButton(text: "Connected", backgroundColor: AppColor.secondary, onPressed: () {});
    }

    return CustomButton(text: "Connect", backgroundColor: AppColor.primary, onPressed: () => notifier.sendConnectionRequest(item.id ?? findId!, context));
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Row(
      children: [
        Image.asset(icon, height: 20.h, width: 20.w),
        SizedBox(width: 8.w),
        CustomText(text: label, fontSize: 14.sp, color: AppColor.grey400),
        const Spacer(),
        Expanded(child: CustomText(text: value, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Container(height: 1.h, width: double.infinity, color: AppColor.grey100);
  }

  Widget _buildMessageButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(IconPath.chat, height: 24.h, width: 24.w),
          SizedBox(width: 8.w),
          CustomText(text: "Message", color: AppColor.primary, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}
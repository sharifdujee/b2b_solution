import 'dart:developer';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../../model/find_connecion_state_model.dart';
import '../../model/my_connection_state_model.dart';
import '../../model/send_request_state_model.dart';
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
      if (lat == 0.0 && lng == 0.0) return "Location not available";
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
            .trim()
            .replaceAll(RegExp(r'^, | ,'), '');
      }
    } catch (e) {
      log("Geocoding error: $e");
    }
    return "Location found";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFindModel = connectionData is FindDatum;
    final bool isRequestModel = connectionData is SendRequestResultDatum;

    String fullName = "N/A";
    String businessName = "N/A";
    String? businessImage;
    String position = "Business Professional";
    String email = "N/A";
    DateTime? memberSince;
    double lat = 0.0;
    double lng = 0.0;

    // --- Data Extraction Logic ---
    if (isFindModel) {
      final data = connectionData as FindDatum;
      fullName = data.fullName;
      businessName = data.businessName;
      businessImage = data.businessImage;
      position = data.position ?? position;
      email = data.email;
      lat = data.businessLatitude;
      lng = data.businessLongitude;
    } else if (isRequestModel) {
      final data = connectionData as SendRequestResultDatum;
      final receiver = data.receiver;
      fullName = receiver.fullName;
      businessName = receiver.businessName;
      businessImage = receiver.businessImage;
      position = receiver.position ?? position;
      email = receiver.email;
      lat = receiver.businessLatitude;
      lng = receiver.businessLongitude;
    } else {
      final connection = connectionData as MyConnectionStateModel;
      final user = connection.getDisplayUser(currentUserId);
      fullName = user?.fullName ?? fullName;
      email = user?.email ?? email;
      businessName = user?.businessName ?? businessName;
      businessImage = user?.businessImage;
      position = user?.position ?? position;
      memberSince = connection.createdAt;
      lat = user?.businessLatitude ?? 0.0;
      lng = user?.businessLongitude ?? 0.0;
    }

    final connectionState = ref.watch(myConnectionListProvider);
    final bool isLoading = connectionState.isLoading;

    MyConnectionStateModel? activeConnection;
    if (isFindModel) {
      activeConnection = connectionState.items.where(
              (e) => e.receiverId == (connectionData as FindDatum).id ||
              e.senderId == (connectionData as FindDatum).id
      ).firstOrNull;
    } else if (!isRequestModel) {
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
                  String displayAddress = snapshot.connectionState == ConnectionState.done
                      ? (snapshot.data ?? "Address not found")
                      : "Loading address...";
                  return _buildDetailRow(IconPath.location05, "Address", displayAddress);
                },
              ),
              SizedBox(height: 14.h),
              _buildDetailRow(IconPath.mail, "Email", email),
              SizedBox(height: 42.h),
              _buildUniversalActions(ref, activeConnection, isFindModel ? (connectionData as FindDatum).id : null, context, isLoading),
              SizedBox(height: 16.h),
              if (status == "CONNECTED") _buildMessageButton(),
            ],
          ),
        ),
      ),
    );
  }

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
        CustomText(fontWeight: FontWeight.w700, fontSize: 20.sp, text: "Business Card Details"),
      ],
    );
  }

  Widget _buildBrandImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
          color: AppColor.grey100,
          borderRadius: BorderRadius.circular(16.r)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.business, size: 60.r, color: AppColor.grey400))
            : Icon(Icons.business, size: 60.r, color: AppColor.grey400),
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
        SizedBox(height: 4.h),
        CustomText(text: fName, fontSize: 16.sp, color: AppColor.grey600, fontWeight: FontWeight.w500),
        SizedBox(height: 4.h),
        CustomText(text: pos, fontSize: 12.sp, color: AppColor.grey400),
      ],
    );
  }

  Widget _buildUniversalActions(WidgetRef ref, MyConnectionStateModel? item, String? findId, BuildContext context, bool isLoading) {
    final notifier = ref.read(myConnectionListProvider.notifier);

    // 1. Handling "Cancel Request" logic for Sent Requests
    if (status == "REQUEST") {
      final String requestId = (connectionData as SendRequestResultDatum).receiver.id;
      return CustomButton(
        onPressed: isLoading ? null : (){
          notifier.cancelRequest(requestId, context);
          context.pop();
        },
        text: "Cancel Request",
        backgroundColor: AppColor.error,
        textColor: AppColor.white,
      );
    }

    // 2. Handling "Connect" for new profiles
    if (item == null && findId != null) {
      return CustomButton(
        text: "Connect",
        backgroundColor: AppColor.primary,
        onPressed: isLoading ? null : () => notifier.sendConnectionRequest(findId, context),
      );
    }

    // 3. Handling "Accept/Reject" for incoming requests
    if (status == "PENDING" && item?.receiverId == currentUserId) {
      return Row(
        children: [
          Expanded(
              child: CustomButton(
                  text: "Reject",
                  backgroundColor: AppColor.emergencyBadgeText,
                  onPressed: isLoading ? null : () => notifier.rejectConnection(item!.id, context)
              )
          ),
          SizedBox(width: 16.w),
          Expanded(
              child: CustomButton(
                  text: "Accept",
                  backgroundColor: AppColor.primary,
                  onPressed: isLoading ? null : () => notifier.acceptConnection(item!.id, context)
              )
          ),
        ],
      );
    }

    // 4. Default Request Sent / Connected states
    if (status == "PENDING") {
      return CustomButton(
          text: "Request Sent",
          backgroundColor: AppColor.grey100,
          textColor: AppColor.grey400,
          onPressed: null
      );
    }

    if (status == "CONNECTED") {

      return CustomButton(
          text: "Remove Connection",
          backgroundColor: AppColor.error,
          onPressed: () {
            String removeId = "";
            if(AuthService.id != item!.senderId){
              removeId = item!.senderId;
            }
            else{
              removeId = item!.receiverId;
            }
            isLoading? null:
            notifier.removeConnection(removeId, context);
            log("item ID: ${item!.receiverId}");
            context.pop();
          }
      );
    }

    return CustomButton(
        text: "Connect",
        backgroundColor: AppColor.primary,
        onPressed: isLoading ? null : () => notifier.sendConnectionRequest(item?.id ?? findId!, context)
    );
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, height: 20.h, width: 20.w, color: AppColor.primary),
        SizedBox(width: 8.w),
        CustomText(text: label, fontSize: 14.sp, color: AppColor.grey400),
        SizedBox(width: 16.w),
        Expanded(child: CustomText(text: value, fontSize: 14.sp, fontWeight: FontWeight.w500, textAlign: TextAlign.end)),
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
          Image.asset(IconPath.chat, height: 24.h, width: 24.w, color: AppColor.primary),
          SizedBox(width: 8.w),
          CustomText(text: "Message", color: AppColor.primary, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}
import 'dart:developer';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/service/socket_service.dart';
import '../../model/connected_state_model.dart';
import '../../model/find_connecion_state_model.dart';
import '../../model/pending_connection_state_model.dart';
import '../../model/send_request_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';

class BusinessCardScreen extends ConsumerWidget {
  final dynamic connectionData;
  final String currentUserId;
  final String status;
  final String? connectedUserId;

  const BusinessCardScreen({
    super.key,
    required this.connectionData,
    required this.currentUserId,
    required this.status,
    this.connectedUserId,
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
    final bool isPendingModel = connectionData is PendingConnection;
    final bool isConnectedModel = connectionData is ConnectedConnection;

    String fullName = "N/A";
    String businessName = "N/A";
    String? businessImage;
    String position = "Business Professional";
    String email = "N/A";
    DateTime? memberSince;
    double lat = 0.0;
    double lng = 0.0;

    // --- Unified Data Extraction ---
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
    } else if (isPendingModel) {
      final data = connectionData as PendingConnection;
      final partner = data.getDisplayPartner(currentUserId);
      fullName = partner?.fullName ?? "Unknown";
      businessName = partner?.businessName ?? "N/A";
      businessImage = partner?.businessImage;
      position = partner?.position ?? position;
      lat = partner?.businessLatitude ?? 0.0;
      lng = partner?.businessLongitude ?? 0.0;
      memberSince = data.createdAt;
    } else if (isConnectedModel) {
      final data = connectionData as ConnectedConnection;
      final partner = data.getDisplayPartner(currentUserId);
      fullName = partner?.fullName ?? "Unknown";
      businessName = partner?.businessName ?? "N/A";
      businessImage = partner?.businessImage;
      position = partner?.position ?? position;
      lat = partner?.businessLatitude ?? 0.0;
      lng = partner?.businessLongitude ?? 0.0;
      memberSince = data.createdAt;
    }

    final connectionState = ref.watch(myConnectionListProvider);
    final bool isLoading = connectionState.isLoading;

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
              _buildUniversalActions(ref, context, isLoading),
              SizedBox(height: 16.h),
              if (status == "CONNECTED") _buildMessageButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversalActions(WidgetRef ref, BuildContext context, bool isLoading) {
    final notifier = ref.read(myConnectionListProvider.notifier);

    if (status == "REQUEST") {
      final String requestId = (connectionData as SendRequestResultDatum).receiver.id;
      return CustomButton(
        onPressed: isLoading ? null : () {
          notifier.cancelRequest(requestId, context);
          context.pop();
        },
        text: "Cancel Request",
        backgroundColor: AppColor.error,
        textColor: AppColor.white,
      );
    }

    if (status == "PENDING") {
      final data = connectionData as PendingConnection;
      final bool isReceiver = data.receiverId == currentUserId;

      if (isReceiver) {
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Reject",
                backgroundColor: AppColor.error.withValues(alpha: 0.1),
                textColor: AppColor.error,
                onPressed: isLoading ? null : () {
                  final id = AuthService.id == data.sender!.id ? data.sender!.id : data.sender!.id;
                  notifier.rejectConnection(id, context);
                  context.pop();
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomButton(
                text: "Accept",
                backgroundColor: AppColor.primary,
                onPressed: isLoading ? null : () {
                  final id = AuthService.id == data.sender!.id ? data.sender!.id : data.sender!.id;
                  notifier.acceptConnection(id, context);
                  context.pop();
                },
              ),
            ),
          ],
        );
      } else {
        return CustomButton(
          text: "Request Sent",
          backgroundColor: AppColor.grey100,
          textColor: AppColor.grey400,
          onPressed: null,
        );
      }
    }

    if (status == "CONNECTED") {
      final data = connectionData as ConnectedConnection;
      final String partnerId = data.getPartnerId(currentUserId);

      return CustomButton(
        text: "Remove Connection",
        backgroundColor: AppColor.error,
        onPressed: isLoading ? null : () {
          notifier.removeConnection(partnerId, context);
          context.pop();
        },
      );
    }

    if (status == "FIND") {
      final String findId = (connectionData as FindDatum).id;
      return CustomButton(
        text: "Connect",
        backgroundColor: AppColor.primary,
        onPressed: isLoading ? null : () => notifier.sendConnectionRequest(findId, context),
      );
    }

    return const SizedBox.shrink();
  }

  // --- UI Components ---

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

  Widget _buildMessageButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("connected User id: $connectedUserId");

        if (connectedUserId != null) {
          final SocketService socketService = SocketService();
          socketService.connect(AppUrl.socketUrl, AuthService.token.toString());
          socketService.joinRoom(connectedUserId!);
          log("Joined room with: $connectedUserId");
          context.push("/chatScreen");
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
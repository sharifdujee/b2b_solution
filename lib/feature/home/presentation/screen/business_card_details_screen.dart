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
import '../../../../core/service/app_url.dart';
import '../../../../core/service/auth_service.dart';
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

  /// Logic to convert coordinates to a readable address
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
    // UI variables
    String fullName = "N/A";
    String businessName = "N/A";
    String? businessImage;
    String position = "Business Professional";
    String email = "N/A";
    DateTime? memberSince;
    double lat = 0.0;
    double lng = 0.0;
    String? activePartnerId;

    // --- Data Extraction Logic ---
    if (connectionData is FindDatum) {
      final data = connectionData as FindDatum;
      fullName = data.fullName;
      businessName = data.businessName;
      businessImage = data.businessImage;
      position = data.position ?? position;
      email = data.email;
      lat = data.businessLatitude;
      lng = data.businessLongitude;
      activePartnerId = data.id;
    } else if (connectionData is SendRequestResultDatum) {
      final data = connectionData as SendRequestResultDatum;
      fullName = data.receiver.fullName;
      businessName = data.receiver.businessName;
      businessImage = data.receiver.businessImage;
      position = data.receiver.position ?? position;
      email = data.receiver.email;
      lat = data.receiver.businessLatitude;
      lng = data.receiver.businessLongitude;
      activePartnerId = data.receiver.id;
    } else if (connectionData is PendingConnection) {
      final data = connectionData as PendingConnection;
      final partner = data.getDisplayPartner(currentUserId);
      fullName = partner?.fullName ?? "Unknown";
      businessName = partner?.businessName ?? "N/A";
      businessImage = partner?.businessImage;
      position = partner?.position ?? position;
      lat = partner?.businessLatitude ?? 0.0;
      lng = partner?.businessLongitude ?? 0.0;
      memberSince = data.createdAt;
      activePartnerId = partner?.id;
    } else if (connectionData is ConnectedConnection) {
      final data = connectionData as ConnectedConnection;
      final partner = data.getDisplayPartner(currentUserId);
      fullName = partner?.fullName ?? "Unknown";
      businessName = partner?.businessName ?? "N/A";
      businessImage = partner?.businessImage;
      position = partner?.position ?? position;
      lat = partner?.businessLatitude ?? 0.0;
      lng = partner?.businessLongitude ?? 0.0;
      memberSince = data.createdAt;
      activePartnerId = data.getPartnerId(currentUserId);
    }

    final connectionState = ref.watch(myConnectionListProvider);
    final bool isLoading = connectionState.isLoading;

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
          onPressed: () => context.pop(),
        ),
        title: CustomText(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            text: "Business Card Details"
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandImage(businessImage),
              SizedBox(height: 14.h),
              _buildNameHeader(businessName, fullName, position, memberSince),
              SizedBox(height: 16.h),
              _buildDashedLine(),
              SizedBox(height: 14.h),
              FutureBuilder<String>(
                future: getAddressFromLatLng(lat, lng),
                builder: (context, snapshot) {
                  String addr = snapshot.connectionState == ConnectionState.done
                      ? (snapshot.data ?? "Address not found")
                      : "Loading address...";
                  return _buildDetailRow(IconPath.location05, "Address", addr);
                },
              ),
              SizedBox(height: 14.h),
              _buildDetailRow(IconPath.mail, "Email", email),
              SizedBox(height: 42.h),
              _buildUniversalActions(ref, context, isLoading),
              if (status == "CONNECTED") ...[
                SizedBox(height: 16.h),
                _buildMessageButton(context, activePartnerId),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversalActions(WidgetRef ref, BuildContext context, bool isLoading) {
    final notifier = ref.read(myConnectionListProvider.notifier);

    // CASE: REQUEST SENT
    if (connectionData is SendRequestResultDatum && status == "REQUEST") {
      final data = connectionData as SendRequestResultDatum;
      if (data.receiver.id == currentUserId) return const SizedBox.shrink();

      return CustomButton(
        text: "Cancel Request",
        backgroundColor: AppColor.error,
        onPressed: isLoading ? null : () async {
          await notifier.cancelRequest(data.id, context);
          if (context.mounted) context.pop();
        },
      );
    }

    // CASE: PENDING (INCOMING)
    if (connectionData is PendingConnection && status == "PENDING") {
      final data = connectionData as PendingConnection;
      if (data.receiverId == currentUserId) {
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Reject",
                backgroundColor: AppColor.error.withOpacity(0.1),
                textColor: AppColor.error,
                onPressed: isLoading ? null : () async {
                  await notifier.rejectConnection(data.sender!.id, context);
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
                  await notifier.acceptConnection(data.sender!.id, context);
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ],
        );
      }
      return CustomButton(
          text: "Request Sent",
          backgroundColor: AppColor.grey100,
          textColor: AppColor.grey400,
          onPressed: null
      );
    }

    // CASE: REMOVE CONNECTION
    if (connectionData is ConnectedConnection && status == "CONNECTED") {
      final data = connectionData as ConnectedConnection;
      return CustomButton(
        text: "Remove Connection",
        backgroundColor: AppColor.error,
        onPressed: isLoading ? null : () async {
          await notifier.removeConnection(data.getPartnerId(currentUserId), context);
          if (context.mounted) context.pop();
        },
      );
    }

    // CASE: FIND/CONNECT
    if (status == "FIND" && connectionData is FindDatum) {
      return CustomButton(
        text: "Connect",
        backgroundColor: AppColor.primary,
        onPressed: isLoading ? null : () async {
          await notifier.sendConnectionRequest((connectionData as FindDatum).id, context);
          if (context.mounted) context.pop();
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageButton(BuildContext context, String? partnerId) {
    return GestureDetector(
      onTap: () {
        if (partnerId == null || partnerId.isEmpty) {
          log("CHAT ERROR: Partner ID is missing");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User ID missing. Cannot open chat."))
          );
          return;
        }

        log("Attempting chat with Partner ID: $partnerId");

        // Initialize Socket
        final socketService = SocketService();
        socketService.connect(AppUrl.socketUrl, AuthService.token ?? "");
        socketService.joinRoom(partnerId);

        // Navigate - passing partnerId as the key
        context.push("/chatScreen", extra: partnerId);
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

  Widget _buildBrandImage(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
          color: AppColor.grey100,
          borderRadius: BorderRadius.circular(16.r)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.business, size: 60.r, color: AppColor.grey400)
        )
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
            Expanded(
                child: CustomText(text: bName, fontSize: 22.sp, fontWeight: FontWeight.w600, maxLines: 1)
            ),
            if (since != null)
              CustomText(text: "Since ${since.year}", fontSize: 12.sp, color: AppColor.grey400),
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
      children: [
        Image.asset(icon, height: 18.h, width: 18.w, color: AppColor.primary),
        SizedBox(width: 8.w),
        CustomText(text: label, fontSize: 14.sp, color: AppColor.grey400),
        const Spacer(),
        Expanded(
            flex: 2,
            child: CustomText(
              text: value,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.end,
              maxLines: 2,
            )
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Divider(color: AppColor.grey100, thickness: 1.h);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';

class BaseBusinessCardLayout extends StatelessWidget {
  final String title;
  final String businessName;
  final String fullName;
  final String position;
  final String? businessImage;
  final String email;
  final double lat;
  final double lng;
  final DateTime? memberSince;
  final List<Widget> actions;

  const BaseBusinessCardLayout({
    super.key,
    required this.title,
    required this.businessName,
    required this.fullName,
    required this.position,
    this.businessImage,
    required this.email,
    required this.lat,
    required this.lng,
    this.memberSince,
    required this.actions,
  });

  /// Logic to convert coordinates to a readable address
  Future<String> getAddress(double lat, double lng) async {
    try {
      if (lat == 0.0 && lng == 0.0) return "Location not available";
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;
        return "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}"
            .trim()
            .replaceAll(RegExp(r'^, | ,'), '');
      }
    } catch (_) {}
    return "Location found";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
          onPressed: () => context.pop(),
        ),
        title: CustomText(
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          text: title,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              SizedBox(height: 14.h),
              _buildHeader(),
              SizedBox(height: 16.h),
              Divider(color: AppColor.grey100, thickness: 1.h),
              SizedBox(height: 14.h),
              FutureBuilder<String>(
                future: getAddress(lat, lng),
                builder: (context, snapshot) {
                  final addr = snapshot.connectionState == ConnectionState.done
                      ? (snapshot.data ?? "Address not found")
                      : "Loading address...";
                  return _buildRow(IconPath.location05, "Address", addr);
                },
              ),
              SizedBox(height: 14.h),
              _buildRow(IconPath.mail, "Email", email),
              SizedBox(height: 42.h),
              // Inject the screen-specific buttons here
              ...actions,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        color: AppColor.grey100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: (businessImage != null && businessImage!.isNotEmpty)
            ? Image.network(
          businessImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.business,
            size: 60.r,
            color: AppColor.grey400,
          ),
        )
            : Icon(Icons.business, size: 60.r, color: AppColor.grey400),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomText(
                text: businessName,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                maxLines: 1,
              ),
            ),
            if (memberSince != null)
              CustomText(
                text: "Since ${memberSince!.year}",
                fontSize: 12.sp,
                color: AppColor.grey400,
              ),
          ],
        ),
        SizedBox(height: 4.h),
        CustomText(
          text: fullName,
          fontSize: 16.sp,
          color: AppColor.grey600,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 4.h),
        CustomText(
          text: position,
          fontSize: 12.sp,
          color: AppColor.grey400,
        ),
      ],
    );
  }

  Widget _buildRow(String icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Image.asset(icon, height: 18.h, width: 18.w, color: AppColor.primary),
        ),
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
          ),
        ),
      ],
    );
  }
}
import 'dart:io';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';

class CustomImagePickerCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final VoidCallback onPickImage;

  const CustomImagePickerCard({
    super.key,
    required this.title,
    this.imagePath,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickImage, // Single tap listener for the whole area
          child: Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Slight off-white background
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              image: hasImage
                  ? DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasImage
                ? const SizedBox.shrink() // Clean view: Tap on image triggers onPickImage
                : _buildPlaceholder(),   // Placeholder view for empty state
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(IconPath.galleryAdd, height: 44.h, width: 44.w),
        SizedBox(height: 16.h),
        Text(
          "Upload $title",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        Text(
          "Supports: JPG, PNG",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 16.h),
        // The button only exists as a visual guide in the placeholder
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric( vertical: 10.h),
          margin: EdgeInsets.symmetric(horizontal: 20.h),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              "Choose Picture",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
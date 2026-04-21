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
  // 1. Added optional errorText parameter
  final String? errorText;

  const CustomImagePickerCard({
    super.key,
    required this.title,
    this.imagePath,
    required this.onPickImage,
    this.errorText, // Initialize here
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imagePath != null && imagePath!.isNotEmpty;
    bool hasError = errorText != null; // Check if there is an error

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              // 2. Change border color to Red if hasError is true
              border: Border.all(
                color: hasError ? Colors.red : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1,
              ),
              image: hasImage
                  ? DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasImage ? const SizedBox.shrink() : _buildPlaceholder(),
          ),
        ),
        // 3. Display the error message below the card if it exists
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 4.w),
            child: Text(
              errorText!,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h),
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
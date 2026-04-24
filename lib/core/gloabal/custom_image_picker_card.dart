import 'dart:io';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';

class CustomImagePickerCard extends StatelessWidget {
  final String title;
  final String? imagePath;      // Local file path
  final String? networkImage;   // URL from the server
  final VoidCallback onPickImage;
  final String? errorText;

  const CustomImagePickerCard({
    super.key,
    required this.title,
    this.imagePath,
    this.networkImage, // Initialize optional network image
    required this.onPickImage,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    bool hasLocalImage = imagePath != null && imagePath!.isNotEmpty;
    bool hasNetworkImage = networkImage != null && networkImage!.isNotEmpty;
    bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 200.h,
            clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: hasError ? Colors.red : const Color(0xFFE2E8F0),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: _buildImageContent(hasLocalImage, hasNetworkImage),
          ),
        ),
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

  Widget _buildImageContent(bool hasLocal, bool hasNetwork) {
    // Priority 1: Picked Local File
    if (hasLocal) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    // Priority 2: Existing Network Image
    if (hasNetwork) {
      return Image.network(
        networkImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isError: true),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          IconPath.galleryAdd,
          height: 44.h,
          width: 44.w,
          color: isError ? Colors.grey : null,
        ),
        SizedBox(height: 16.h),
        Text(
          isError ? "Error loading image" : "Upload $title",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        Text(
          isError ? "Tap to try again" : "Supports: JPG, PNG",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        if (!isError) ...[
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
      ],
    );
  }
}
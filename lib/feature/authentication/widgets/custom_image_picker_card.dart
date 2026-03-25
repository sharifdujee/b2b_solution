import 'dart:io';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Preview or Placeholder Icon
              if (imagePath != null && imagePath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(imagePath!),
                    height: 100.h,
                    width: 100.w,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(IconPath.galleryAdd,height: 44.h,width: 44.w,),

              SizedBox(height: 16.h),

              Text(
                imagePath != null && imagePath!.isNotEmpty
                    ? "Image Selected"
                    : "Upload $title",
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

              SizedBox(height: 24.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onPickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    imagePath != null && imagePath!.isNotEmpty ? "Change Picture" : "Choose Picture",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
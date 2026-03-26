import 'dart:io';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slight off-white background
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Profile",
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              SizedBox(height: 8.h),
              const Divider(),
              SizedBox(height: 24.h),

              // --- PROFILE HEADER SECTION ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (profileState.profileImage != null &&
                                profileState.profileImage!.isNotEmpty)
                                ? FileImage(File(profileState.profileImage!))
                                : null,
                            child: (profileState.profileImage == null ||
                                profileState.profileImage!.isEmpty)
                                ? Icon(Icons.person, size: 50.r, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 5.h,
                          right: 5.w,
                          child: GestureDetector(
                            onTap: () => _showImageSourceSheet(
                              context,
                                  (source) => notifier.pickProfileImage(source),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 18.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomText(
                      text: profileState.name ?? "Joe's Cafe",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(
                      text: profileState.position ?? "Foreman",
                      fontSize: 14.sp,
                      color: AppColor.grey400,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // --- MENU ITEMS CARD ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile(icon: Icons.person_outline, title: "Account Management"),
                    _buildDivider(),
                    _buildListTile(icon: Icons.lock_outline, title: "Change Password"),
                    _buildDivider(),
                    _buildListTile(icon: Icons.help_outline, title: "Help Center"),
                    _buildDivider(),
                    //_buildListTile(icon: Icons.description_outline, title: "Terms of Service"),
                    _buildDivider(),
                    //_buildListTile(icon: Icons.privacy_tip_outline, title: "Privacy Policy"),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.delete_outline,
                      title: "Delete Account",
                      color: Colors.red,
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.logout,
                      title: "Logout",
                      color: Colors.red,
                      showArrow: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for List Items
  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? color,
    bool showArrow = true,
  }) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black, size: 22.sp),
            CustomText(
              text: title,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black,
            ),
            Spacer(),
            Icon( showArrow ? Icons.arrow_forward_ios : null, size: 14.sp, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20);

  void _showImageSourceSheet(BuildContext context, Function(ImageSource) onSourceSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Select Image Source",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                )
              ],
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: _buildSourceCard(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    onTap: () => onSourceSelected(ImageSource.camera),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildSourceCard(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    onTap: () => onSourceSelected(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColor.primary),
            SizedBox(height: 10.h),
            CustomText(text: label, fontSize: 16.sp, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
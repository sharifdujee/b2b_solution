import 'dart:io';
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
              _buildDivider(),
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
                            //border: Border.all(color: AppColor.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 70.r,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (profileState.profileImage != null &&
                                profileState.profileImage!.isNotEmpty)
                                ? FileImage(File(profileState.profileImage!))
                                : null,
                            child: (profileState.profileImage == null ||
                                profileState.profileImage!.isEmpty)
                                ? Icon(Icons.person, size: 120.r, color: Colors.grey)
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
                                color: Color(0xFFE27932),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Image.asset(IconPath.avatarEdit,height: 12.h,width: 12.h,)
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: profileState.name ?? "Joe's Cafe",
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.black,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: profileState.position ?? "Foreman",
                      fontSize: 14.sp,
                      color: AppColor.grey300,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 13.h),

              // --- MENU ITEMS CARD ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF828282).withValues(alpha: 0.14),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile(
                        icon: IconPath.userEdit, title: "Account Management",
                      onTap: ()=> context.push("/editProfile")
                    ),
                    _buildDivider(),
                    _buildListTile(
                        icon: IconPath.lockPassword, title: "Change Password",
                      onTap: ()=> context.push("/changePasswordScreen")
                    ),
                    _buildDivider(),
                    _buildListTile(
                        icon: IconPath.helpCenter, title: "Help Center"
                    ),
                    _buildDivider(),
                    _buildListTile(
                        icon: IconPath.termsOfService, title: "Terms of Service"
                    ),
                    _buildDivider(),
                    _buildListTile(
                        icon: IconPath.privacyPolicy, title: "Privacy Policy"
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: IconPath.deleteAccount,
                      title: "Delete Account",
                      color: Colors.red,
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: IconPath.logout,
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
    required String icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16..h),
        child: Row(
          children: [
            Image.asset(icon, height: 24.h, width: 24.w, color: color,),
            SizedBox(width: 8.w,),
            CustomText(
              text: title,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black,
            ),
            Spacer(),
            showArrow?
            Image.asset(IconPath.arrowRight,height: 24.h,width: 24.w, color: AppColor.grey400,) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Color(0xFFEDEEF4));

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
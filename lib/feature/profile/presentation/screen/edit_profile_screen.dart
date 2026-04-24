
import 'dart:developer';

import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_dialog.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/core/gloabal/custom_image_picker_card.dart';
import 'package:b2b_solution/feature/profile/provider/edit_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../provider/profile_provider.dart';


class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  // 1. Add a Form Key
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(editProfileProvider);
    final editProfileController = ref.read(editProfileProvider.notifier);
    final profileState = ref.watch(profileProvider);
    final user = profileState.userModel;

    // Logic to check if anything has changed compared to the current user data
    bool hasChanges() {
      final isTextDirty =
          editProfileController.legalNameController.text != (user?.legalName ?? "") ||
              editProfileController.businessNameController.text != (user?.businessName ?? "") ||
              editProfileController.fullNameController.text != (user?.fullName ?? "") ||
              editProfileController.positionController.text != (user?.position ?? "") ||
              editProfileController.businessCategoryController.text != (user?.businessCategory.firstOrNull ?? "") ||
              editProfileController.operationYearsController.text != (user?.operationYears.toString() ?? "");

      final isImageDirty = editProfileState.profileImage != null ||
          editProfileState.businessImage != null;

      final isLocationDirty =
          (editProfileState.latitude != null && editProfileState.latitude != user?.businessLatitude) ||
              (editProfileState.longitude != null && editProfileState.longitude != user?.businessLongitude);

      return isTextDirty || isImageDirty || isLocationDirty;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),
                // --- Header ---
                Row(
                  children: [
                    GestureDetector(
                      child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.h),
                      onTap: () => context.pop(),
                    ),
                    SizedBox(width: 12.h),
                    CustomText(
                      text: "Edit Profile",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                const Divider(),

                // --- Email Address (Read Only) ---
                SizedBox(height: 16.h),
                const CustomText(text: "Email Address", fontWeight: FontWeight.w600),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    color: AppColor.magentaSoft,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: CustomText(
                    text: user?.email ?? "Email not found",
                    fontSize: 14.sp,
                    color: AppColor.grey400,
                  ),
                ),

                // --- Form Fields ---
                _buildFieldTitle("Legal Name"),
                CustomTextFormField(
                  controller: editProfileController.legalNameController,
                  hintText: "Ex. 101010 Ontario inc",
                  onChanged: (_) => setState(() {}), // Trigger rebuild for hasChanges()
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                ),

                _buildFieldTitle("Business Name"),
                CustomTextFormField(
                  controller: editProfileController.businessNameController,
                  hintText: "Ex. Subway",
                  onChanged: (_) => setState(() {}),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                ),

                _buildFieldTitle("Your Name"),
                CustomTextFormField(
                  controller: editProfileController.fullNameController,
                  hintText: "Ex. John Smith",
                  onChanged: (_) => setState(() {}),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                ),

                _buildFieldTitle("Position"),
                CustomTextFormField(
                  controller: editProfileController.positionController,
                  hintText: "Ex. Owner",
                  onChanged: (_) => setState(() {}),
                ),

                _buildFieldTitle("Food Category"),
                CustomTextFormField(
                  controller: editProfileController.businessCategoryController,
                  hintText: "Ex. Sandwich",
                  onChanged: (_) => setState(() {}),
                ),

                _buildFieldTitle("Years of Operation"),
                CustomTextFormField(
                  controller: editProfileController.operationYearsController,
                  hintText: "2024",
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),

                _buildFieldTitle("Business Location"),
                GestureDetector(
                  onTap: () => context.push('/businessLocation'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColor.primary),
                    ),
                    child: CustomText(
                      text: (editProfileState.businessAddress == null && editProfileState.latitude != null)
                          ? "Fetching address..."
                          : (editProfileState.businessAddress ?? "Select Location"),
                      fontSize: 14.sp,
                      color: editProfileState.businessAddress != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),

                // --- Image Pickers ---
                _buildFieldTitle("Profile image"),
                CustomImagePickerCard(
                  title: "Profile image",
                  imagePath: editProfileState.profileImage,
                  networkImage: user?.profileImage,
                  onPickImage: () => _showImageSourceSheet(context, (s) => editProfileController.pickProfileImage(s)),
                ),

                _buildFieldTitle("Upload business image"),
                CustomImagePickerCard(
                  title: "Business image",
                  imagePath: editProfileState.businessImage,
                  networkImage: user?.businessImage,
                  onPickImage: () => _showImageSourceSheet(context, (s) => editProfileController.pickBusinessImage(s)),
                ),

                SizedBox(height: 32.h),

                // --- Save Button ---
                CustomButton(
                  // 3. Disable button if no changes OR if loading
                  backgroundColor: hasChanges() && !editProfileState.isLoading
                      ? AppColor.primary
                      : AppColor.grey400.withValues(alpha: 0.5),
                  borderRadius: 16.r,
                  text: editProfileState.isLoading ? "Saving..." : "Save Changes",
                  textColor: Colors.black,
                  // 4. onPressed is null when disabled
                  onPressed: (hasChanges() && !editProfileState.isLoading)
                      ? () async {
                    if (_formKey.currentState!.validate()) {
                      final isSuccess = await editProfileController.saveChanges();
                      if (isSuccess && context.mounted) {
                        showCustomDialog(
                          context,
                          imagePath: IconPath.shield,
                          title: "Success",
                          buttonText: "ok",
                          onPressed: () {
                            context.pop();
                            context.pop();
                          },
                        );
                      }
                    }
                  }
                      : null,
                ),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
      child: CustomText(
        text: text,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, Function(ImageSource) onSourceSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Select Image Source",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: const Color(0xFF1E293B), // Slate 800
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9), // Slate 100
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20.sp, color: Colors.red),
                  ),
                )
              ],
            ),

            SizedBox(height: 32.h),

            // Selection Row
            Row(
              children: [
                // Camera Option
                Expanded(
                  child: _buildSourceCard(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    onTap: () => onSourceSelected(ImageSource.camera),
                  ),
                ),

                SizedBox(width: 16.w),

                // Gallery Option
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

  Widget _buildSourceCard(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close sheet
        onTap(); // Trigger picker
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Slate 50
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColor.primary),
            SizedBox(height: 10.h),
            CustomText(
              text: label,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}



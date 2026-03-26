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


class EditProfile extends ConsumerWidget{
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider);
    final controller = ref.read(editProfileProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h,),
                GestureDetector(
                    child: Image.asset(IconPath.arrowLeft, height:24.h, width: 24.h,),
                    onTap: ()=> context.pop()
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Edit Profile",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),


                SizedBox(height: 16.h,),
                CustomText(
                  text: "Email Address",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColor.magentaSoft, // Your soft background color
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0), // Soft border
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            // Use the state value if it exists, otherwise show the placeholder
                            text: state.email.isNotEmpty
                                ? state.email
                                : "Jhonsmith@gmail.com",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: state.email.isNotEmpty
                                ? Colors.black
                                : AppColor.grey400,
                          ),
                        ),
                      ],
                    ),
                ),


                SizedBox(height: 32.h,),
                CustomText(
                  text: "Legal Name",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateLegalName(value),
                  hintText: "Ex. 101010 Ontario inc",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Business Name",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateBusinessName(value),
                  hintText: "Ex. Subway",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Your Name",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateName(value),
                  hintText: "Ex. John smith",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                ),


                SizedBox(height: 16.h,),
                CustomText(
                  text: "Position",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updatePosition(value),
                  hintText: "Ex. Owner",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Food Category",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateFoodCategory(value),
                  hintText: "Ex. Sandwich",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Years of Operation",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateYearsOfOperation(value),
                  hintText: "Ex. Sandwich",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                ),

                SizedBox(height: 16.h,),

                CustomText(
                  text :"Profile image",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),

                SizedBox(height: 12.h,),
                CustomImagePickerCard(
                  title: "Profile image",
                  imagePath: state.profileImage,
                  onPickImage: () {
                    _showImageSourceSheet(context, (source) {
                      ref.read(editProfileProvider.notifier).pickProfileImage(source);
                    });
                  },
                ),

                SizedBox(height: 16.h,),
                CustomText(
                  text: "Upload business image",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                SizedBox(height: 12.h,),
                CustomImagePickerCard(
                  title: "business image",
                  imagePath: state.businessLicenseImage, // <--- Using businessImage here too!
                  onPickImage: () {
                    _showImageSourceSheet(context, (source) {
                      ref.read(editProfileProvider.notifier).pickLicenseImage(source);
                    });
                  },
                ),


                SizedBox(height: 12.h,),
                CustomTextFormField(
                  onChanged: (value) => controller.updateConfirmPassword(value),
                  hintText: "",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,

                  borderRadius: 12.r,
                  obscureText: state.obscureConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () => controller.toggleConfirmPasswordVisibility(),
                    icon: IconButton(
                      onPressed: () => controller.toggleConfirmPasswordVisibility(),
                      icon: Icon(
                        state.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.grey300,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h,),
                CustomButton(
                  backgroundColor: AppColor.primary,
                  borderRadius: 16.r,
                  text: "Save Changes",
                  textColor: Colors.black,
                  onPressed: (){
                    showCustomDialog(
                      context,
                      imagePath: IconPath.shield,
                      title: "Success",
                      buttonText: "ok",
                      onPressed: () {
                        context.pop();
                        context.pop();
                      },
                    );                  },
                ),


                SizedBox(height: 48.h,),
              ],
            )
        ),
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
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h), // Extra bottom padding for safe area
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

// Reusable Source Card Design
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
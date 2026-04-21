import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/core/gloabal/custom_image_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_selector.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../provider/signup_provider.dart';

class SignupScreen extends ConsumerWidget {
  SignupScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final controller = ref.read(signupProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.h),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: "Create an account",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: "Connect. Trade. Grow. It starts here.",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.grey400,
                ),
                SizedBox(height: 32.h),

                // --- Input Fields ---
                _buildSectionTitle("Legal Name"),
                CustomTextFormField(
                  controller: controller.legalNameController,
                  hintText: "Ex. 101010 Ontario inc",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) => value == null || value.isEmpty ? "Legal name required" : null,
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Business Name"),
                CustomTextFormField(
                  controller: controller.businessNameController,
                  hintText: "Ex. Subway",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) => value == null || value.isEmpty ? "Business name required" : null,
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Your Name"),
                CustomTextFormField(
                  controller: controller.nameController,
                  hintText: "Ex. John smith",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) => value == null || value.isEmpty ? "Name required" : null,
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Email Address"),
                CustomTextFormField(
                  controller: controller.emailController,
                  hintText: "Ex. Jhonsmith@gmail.com",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email required";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Invalid email format";
                    return null;
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Position"),
                CustomTextFormField(
                  controller: controller.positionController,
                  hintText: "Ex. Owner",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) => value == null || value.isEmpty ? "Position required" : null,
                ),

                SizedBox(height: 16.h),
                CustomSelectField<String>(
                  label: "Food Category",
                  hintText: "Select Categories",
                  items: const [
                    "Snacks", "Soups", "Salads", "Drinks",
                    "Appetizers", "Main Course", "Desserts",
                    "Bakery", "Dairy", "Frozen Food", "Meat & Poultry"
                  ],
                  // Use the list from your state
                  initialSelectedItems: state.foodCategory,
                  onChanged: (values) {
                    controller.resetErrorMessage();
                    // CRITICAL: Update the state with the new values
                    if (values is List<String>) {
                      controller.updateFoodCategories(values);
                    }
                  },
                  itemLabelBuilder: (val) => val,
                  showSearchBar: true,
                  showActionButtons: true,
                  isMultiSelect: true,
                  controller: controller.foodCategoryController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Food category required";
                    return null;
                  },
                ),


                SizedBox(height: 16.h),
                _buildSectionTitle("Years of Operation"),
                CustomTextFormField(
                  controller: controller.yearsOfOperationController,
                  hintText: "5",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  keyboardType: TextInputType.number, // Added for better UX
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Years of operation required";
                    }

                    final years = int.tryParse(value);
                    if (years == null) {
                      return "Invalid years of operation";
                    }

                    if (years <= 0) {
                      return "Years cannot be negative";
                    }

                    if (years > 100) {
                      return "Must be less than 100";
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Business Location"),
                FormField<String>(
                  initialValue: state.businessAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || value == "Select Location") {
                      return "Business location is required";
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> fieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.resetErrorMessage();
                            context.push('/businessLocation');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(12.r),
                              // Border turns red if there is a validation error
                              border: Border.all(
                                color: fieldState.hasError ? Colors.red : AppColor.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: state.businessAddress ?? "Select Location",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: state.businessAddress == null ? AppColor.grey400 : Colors.black,
                                  ),
                                ),
                                Icon(
                                    Icons.location_on_outlined,
                                    color: fieldState.hasError ? Colors.red : AppColor.primary,
                                    size: 20.sp
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (fieldState.hasError)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 4.w),
                            child: CustomText(
                              text: fieldState.errorText ?? "",
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Profile image"),
                FormField<String>(
                  validator: (value) => state.profileImage == null ? "Please upload a profile image" : null,
                  builder: (fieldState) {
                    return CustomImagePickerCard(
                      title: "Profile Image",
                      imagePath: state.profileImage,
                      errorText: fieldState.errorText,
                      onPickImage: () async {
                        await controller.pickProfileImage(ImageSource.gallery);
                        fieldState.didChange(state.profileImage);
                      },
                    );
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Upload business image"),
                FormField<String>(
                  validator: (value) => state.profileImage == null ? "Please upload a profile image" : null,
                  builder: (fieldState) {
                    return CustomImagePickerCard(
                      title: "business image",
                      imagePath: state.businessImage,
                      errorText: fieldState.errorText,
                      onPickImage: () async {
                        await controller.pickBusinessImage(ImageSource.gallery);
                        fieldState.didChange(state.businessImage);
                      },
                    );
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Password"),
                CustomTextFormField(

                  controller: controller.passwordController,
                  hintText: "Password",
                  hintTextColor: AppColor.grey400,
                  borderRadius: 12.r,
                  textColor: Colors.black,
                  obscureText: state.obscurePassword,
                  onChanged: (_) => controller.resetErrorMessage(),
                  suffixIcon: IconButton(
                    onPressed: () => controller.toggleVisibility(),
                    icon: Icon(
                      state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColor.grey300,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }

                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return "Password must contain at least one number";
                    }

                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return "Password must contain at least one special symbol";
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Confirm Password"),
                CustomTextFormField(
                  controller: controller.confirmPasswordController,
                  hintText: "Confirm Password",
                  hintTextColor: AppColor.grey400,
                  textColor: Colors.black,
                  borderRadius: 12.r,
                  obscureText: state.obscureConfirmPassword,
                  onChanged: (_) => controller.resetErrorMessage(),
                  suffixIcon: IconButton(
                    onPressed: () => controller.toggleConfirmPasswordVisibility(),
                    icon: Icon(
                      state.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColor.grey300,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm password required";
                    }
                    if (value != controller.passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  }
                ),

                // --- Error Message Display ---
                if (state.errorMessage != null) ...[
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CustomText(
                            text: state.errorMessage!,
                            fontSize: 13.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                // --- Submit Button ---
                CustomButton(
                  backgroundColor: AppColor.primary,
                  borderRadius: 16.r,
                  text: state.isLoading ? "Please Wait..." : "Sign Up",
                  textColor: Colors.black,
                  onPressed: state.isLoading
                      ? null
                      : () async {
                    // 1. Trigger the Form validation
                    if (_formKey.currentState!.validate()) {

                      // 2. Only if the form is valid, call the signup logic
                      final success = await controller.signup();

                      if (success && context.mounted) {
                        controller.resetErrorMessage();
                        context.push('/signupVerificationCodeScreen');
                      }
                    } else {
                      // Optional: Scroll to the first error or provide haptic feedback
                      debugPrint("Form is invalid");
                    }
                  },
                ),

                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: "Already have an account?",
                      fontSize: 14.sp,
                      color: AppColor.grey400,
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => context.push("/loginScreen"),
                      child: CustomText(
                          text: "Sign in", fontSize: 14.sp, color: AppColor.secondary),
                    )
                  ],
                ),
                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Titles ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomText(
        text: title,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  void _showImageSourceSheet(
      BuildContext context, Function(ImageSource) onSourceSelected) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Select Image Source",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  color: const Color(0xFF1E293B),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.red),
                  ),
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

  Widget _buildErrorDisplay(String error) {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r)),
      child: Row(children: [
        Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(child: CustomText(text: error, fontSize: 13.sp, color: Colors.red)),
      ]),
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
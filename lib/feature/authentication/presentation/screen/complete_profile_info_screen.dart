import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../../../core/gloabal/custom_image_picker_card.dart';
import '../../../../core/gloabal/custom_selector.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../navigation/presentation/screen.dart';
import '../../provider/complete_profile_provider.dart';
import '../../provider/state/complete_profile_state.dart';

class CompleteProfileInfoScreen extends ConsumerWidget {
  CompleteProfileInfoScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(completeProfileProvider);
    final controller = ref.read(completeProfileProvider.notifier);

    ref.listen<CompleteProfileState>(completeProfileProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        _showStatusSnackBar(context, next.errorMessage!, isError: true);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 32.h),

                // --- Business Details ---
                _buildSectionTitle("Legal Name"),
                CustomTextFormField(
                  controller: controller.legalNameController,
                  hintText: "Ex. 101010 Ontario inc",
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (v) => v?.isEmpty ?? true ? "Legal name required" : null,
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Business Name"),
                CustomTextFormField(
                  controller: controller.businessNameController,
                  hintText: "Ex. Subway",
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (v) => v?.isEmpty ?? true ? "Business name required" : null,
                ),

                // --- Read-Only User Info ---
                SizedBox(height: 16.h),
                _buildSectionTitle("Your Name"),
                _buildReadOnlyField(controller.nameController, "No name found"),

                SizedBox(height: 16.h),
                _buildSectionTitle("Email Address"),
                _buildReadOnlyField(controller.emailController, "No email found"),

                // --- Operational Details ---
                SizedBox(height: 16.h),
                _buildSectionTitle("Position"),
                CustomTextFormField(
                  controller: controller.positionController,
                  hintText: "Ex. Owner",
                  onChanged: (_) => controller.resetErrorMessage(),
                  validator: (v) => v?.isEmpty ?? true ? "Position required" : null,
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
                  initialSelectedItems: state.foodCategory,
                  onChanged: (values) {
                    controller.resetErrorMessage();
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
                  hintText: "Ex. 5",
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? "Required" : null,
                ),

                SizedBox(height: 16.h),
                _buildSectionTitle("Business Location"),
                _buildLocationPicker(context, state, controller),

                // --- Image Uploads ---
                SizedBox(height: 24.h),
                _buildImageSection(context, state, controller),

                SizedBox(height: 32.h),

                // --- Submission ---
                CustomButton(
                  backgroundColor: AppColor.primary,
                  text: state.isLoading ? "Please Wait..." : "Submit",
                  onPressed: state.isLoading ? null : () => _handleEntry(context, controller, ref),
                ),

                SizedBox(height: 16.h),
                _buildFooter(context),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
        ),
        SizedBox(height: 16.h),
        CustomText(text: "Complete profile info", fontSize: 24.sp, fontWeight: FontWeight.w600),
        SizedBox(height: 8.h),
        CustomText(text: "Connect. Trade. Grow. It starts here.", fontSize: 14.sp, color: AppColor.grey400),
      ],
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String placeholder) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: CustomText(
          text: value.text.isEmpty ? placeholder : value.text,
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context, CompleteProfileState state, var controller) {
    return FormField<String>(
      validator: (_) => (state.businessAddress?.isEmpty ?? true) ? "Location required" : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/businessLocation'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: field.hasError ? Colors.red : AppColor.primary),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(state.businessAddress ?? "Select Location",
                        style: TextStyle(color: state.businessAddress == null ? AppColor.grey400 : Colors.black)),
                  ),
                  Icon(Icons.location_on_outlined, color: field.hasError ? Colors.red : AppColor.primary),
                ],
              ),
            ),
          ),
          if (field.hasError) Padding(
            padding: EdgeInsets.only(top: 8.h, left: 4.w),
            child: Text(field.errorText!, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, CompleteProfileState state, var controller) {
    return Column(
      children: [
        CustomImagePickerCard(
          title: "Profile Image",
          imagePath: state.profileImage,
          onPickImage: () => _pickImageWrapper(context, (s) => controller.pickProfileImage(s)),
        ),
        SizedBox(height: 16.h),
        CustomImagePickerCard(
          title: "Business Image",
          imagePath: state.businessImage,
          onPickImage: () => _pickImageWrapper(context, (s) => controller.pickBusinessImage(s)),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(text: "Already have an account?", fontSize: 14.sp, color: AppColor.grey400),
        TextButton(
          onPressed: () => context.push("/loginScreen"),
          child: CustomText(text: "Sign in", fontSize: 14.sp, color: AppColor.secondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CustomText(text: title, fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  // --- Logic Wrappers ---

  void _pickImageWrapper(BuildContext context, Function(ImageSource) onSelect) {
    _showImageSourceSheet(context, onSelect);
  }

  Future<void> _handleEntry(BuildContext context, var controller, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.completeProfile();
      if (success && context.mounted) {
        ref.read(selectedIndexProvider.notifier).state = 0;
        context.pushReplacement('/nav');
      }
    } else {
      _showStatusSnackBar(context, "Please fix the errors in the form.", isError: true);
    }
  }

  void _showStatusSnackBar(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, Function(ImageSource) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(text: "Select Source", fontSize: 18.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 24.h),
            Row(
              children: [
                _sourceTile(context, Icons.camera, "Camera", () => onSelect(ImageSource.camera)),
                SizedBox(width: 16.w),
                _sourceTile(context, Icons.image, "Gallery", () => onSelect(ImageSource.gallery)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: () { Navigator.pop(context); onTap(); },
        child: Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: Column(children: [Icon(icon, color: AppColor.primary), Text(label)]),
        ),
      ),
    );
  }
}
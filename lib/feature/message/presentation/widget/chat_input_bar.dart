import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final File? selectedImage;
  final Function(File) onImagePicked;
  final VoidCallback onClearImage;

  ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePicked,
    required this.onClearImage,
    this.selectedImage,
  });

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(text: "Select Attachment", fontSize: 16.sp, fontWeight: FontWeight.w600),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(context, Icons.camera_alt_rounded, "Camera", ImageSource.camera),
                _buildPickerOption(context, Icons.photo_library_rounded, "Gallery", ImageSource.gallery),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(BuildContext context, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickImage(source);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: AppColor.secondary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColor.secondary, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          CustomText(text: label, fontSize: 14.sp, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedImage != null) _buildPreviewContainer(),
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
          ]),
          child: Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  borderRadius: 30.r,
                  controller: controller,
                  hintText: "Type a message...",
                  suffixIcon: IconButton(
                    onPressed: () => _showImagePickerSheet(context),
                    icon: Image.asset(IconPath.galleryAdd, width: 20.w, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onSend,
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColor.secondary,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(selectedImage!, height: 80.h, width: 80.w, fit: BoxFit.cover),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: onClearImage,
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
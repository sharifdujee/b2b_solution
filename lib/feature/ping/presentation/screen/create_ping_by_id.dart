import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/urgency_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/gloabal/custom_selector.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/gloabal/radius_selector.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../model/create_ping_model.dart';
import '../../provider/create_ping_provider.dart';

class CreatePingForUserScreen extends ConsumerStatefulWidget {
  final String targetPartnerId;

  const CreatePingForUserScreen({
    super.key,
    required this.targetPartnerId,
  });

  @override
  ConsumerState<CreatePingForUserScreen> createState() => _CreatePingForUserScreenState();
}

class _CreatePingForUserScreenState extends ConsumerState<CreatePingForUserScreen> {

  @override
  void initState() {
    super.initState();
    // Pre-populate the connectedIds list with the specific ID passed to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createPingProvider.notifier).updateSingleTargetId(widget.targetPartnerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPingProvider);
    final controller = ref.read(createPingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                      onTap: () => context.pop(),
                      child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w)),
                  SizedBox(width: 12.w),
                  CustomText(
                    text: "Send Direct Ping",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  )
                ],
              ),

              SizedBox(height: 8.h),
              Divider(color: AppColor.grey50),

              // --- Urgency ---
              SizedBox(height: 24.h),
              CustomText(
                text: "Urgency Level",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 12.h),
              UrgencySelector(
                selected: state.urgencyLevel,
                onSelected: (level) => controller.updateUrgency(level),
              ),

              // --- Item Name ---
              SizedBox(height: 16.h),
              CustomText(
                text: "Item Needed",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 12.h),
              CustomTextFormField(
                controller: controller.itemNameController,
                hintText: "Coffee Cups",
                borderRadius: 12.r,
              ),

              // --- Quantity ---
              SizedBox(height: 16.h),
              CustomText(
                text: "Quantity",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 12.h),
              CustomTextFormField(
                controller: controller.quantityController,
                hintText: "Quantity (e.g. 50)",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                borderRadius: 12.r,
              ),

              // --- Unit ---
              SizedBox(height: 16.h),
              CustomSelectField<Unit>(
                label: "Unit",
                hintText: "Select Unit",
                value: state.unit,
                items: Unit.values,
                itemLabelBuilder: (val) => val.name,
                showSearchBar: true,
                showActionButtons: false,
                controller: controller.unitController,
                onChanged: (val) => controller.updateUnit(val),
              ),

              // --- Categories ---
              SizedBox(height: 16.h),
              CustomSelectField<String>(
                label: "Food Category",
                hintText: "Select Categories",
                items: const [
                  "Snacks", "Soups", "Salads", "Drinks",
                  "Appetizers", "Main Course", "Desserts",
                  "Bakery", "Dairy", "Frozen Food", "Meat & Poultry"
                ],
                initialSelectedItems: state.categories,
                itemLabelBuilder: (val) => val,
                showSearchBar: true,
                showActionButtons: true,
                isMultiSelect: true,
                controller: controller.categoryController,
              ),

              // --- Note ---
              SizedBox(height: 16.h),
              CustomText(
                text: "Note",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 12.h),
              CustomTextFormField(
                onChanged: (value) => controller.notesController.text = value,
                hintText: "Write a note",
                borderRadius: 12.r,
              ),

              // --- Radius ---
              SizedBox(height: 16.h),
              CustomText(
                text: "Radius",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              SizedBox(height: 12.h),
              RadiusSelector(
                selectedRadius: state.radius ?? 5,
                controller: controller.radiusController,
              ),

              SizedBox(height: 32.h),

              // --- Submit Button ---
              CustomButton(
                backgroundColor: state.isLoading ? AppColor.grey300 : AppColor.primary,
                borderRadius: 16.r,
                textColor: AppColor.black,
                text: state.isLoading ? "" : "Send Ping",
                image: state.isLoading
                    ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(color: AppColor.black, strokeWidth: 2.5),
                )
                    : null,
                onPressed: state.isLoading
                    ? null
                    : () async {
                  if (controller.itemNameController.text.trim().isEmpty) {
                    _showSnackBar(context, "Please enter an item name", Colors.orange);
                    return;
                  }

                  final bool isSuccess = await controller.sendPing();

                  if (context.mounted) {
                    if (isSuccess) {
                      _showSnackBar(context, "Ping sent to user!", Colors.green);
                      context.pop();
                    } else {
                      _showSnackBar(context, state.errorMessage ?? "Failed to send Ping", Colors.red);
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
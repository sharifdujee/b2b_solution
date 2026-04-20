import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/urgency_selector.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/gloabal/custom_selector.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/gloabal/radius_selector.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../model/connection_model.dart';
import '../../model/create_ping_model.dart';
import '../../provider/connection_provider.dart';
import '../../provider/create_ping_provider.dart';

class CreatePingScreen extends ConsumerWidget{
  const CreatePingScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPingProvider);
    final controller = ref.read(createPingProvider.notifier);

    final connectionState = ref.watch(connectionProvider);



    return Scaffold(
      backgroundColor: AppColor.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: ()=>context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h,width: 24.w,)
                  ),
                  SizedBox(width: 12.w,),
                  CustomText(
                    text: "Create Ping",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  )
                ],
              ),


              SizedBox(height: 8.h,),
              Divider(color: AppColor.grey50,),


              SizedBox(height: 24.h,),
              CustomText(
                text: "Urgency Level",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 12.h),
              UrgencySelector(
                selected: state.urgencyLevel,
                onSelected: (level) {
                  ref.read(createPingProvider.notifier).updateUrgency(level);
                },
              ),


              SizedBox(height: 16.h,),
              CustomText(
                text: "Item Needed",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 12.h,),
              CustomTextFormField(
                controller: controller.itemNameController,
                hintText: "Coffee Cups",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
              ),


              SizedBox(height: 16.h,),
              CustomText(
                text: "Quantity",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 12.h,),
              CustomTextFormField(
                controller: controller.quantityController,
                hintText: "Quantity (e.g. 50)",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
              ),



              SizedBox(height: 16.h,),
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



              SizedBox(height: 16.h,),
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


              SizedBox(height: 16.h,),
              CustomText(
                text: "Note",
                fontSize: 16.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 12.h,),
              CustomTextFormField(
                onChanged: (value) {
                    controller.notesController.text = value;
                },
                hintText: "Write a note",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
              ),
              // CustomSelectField<String>(
              //   label: "Notes",
              //   hintText: "Select note",
              //   value: state.notes,
              //   items: const [
              //       "Urgent! Out of cups!",
              //       "Emergency! Delivery Needed!",
              //       "Urgent! Out of Oli",
              //
              //     ],
              //   itemLabelBuilder: (val) => val,
              //   showSearchBar: true,
              //   showActionButtons: false,
              //   onChanged: (val) => controller.updateNotes(val),
              // ),




              SizedBox(height: 16.h,),
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

              SizedBox(height: 16.h,),
              CustomSelectField<ConnectionModel>(
                label: "Choose Connection",
                hintText: "Search connections...",
                isMultiSelect: true,
                showSearchBar: true,
                items: connectionState.connections,
                initialSelectedItems: connectionState.connections
                    .where((conn) => state.connectedIds.contains(conn.id))
                    .toList(),
                itemLabelBuilder: (conn) {
                  final currentUserId = AuthService.id ?? "";
                  return conn.getDisplayUser(currentUserId)?.fullName ?? "Unknown User";
                },
                controller: controller.connectionDisplayController,
              ),

              SizedBox(height: 16.h,),
              GestureDetector(
                onTap: () => controller.toggleMyConnectionOnly(),
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        state.myConnectionOnly
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: state.myConnectionOnly ? AppColor.secondary : AppColor.grey400,
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: "Send To My Connection Only.",
                        fontSize: 14.sp,
                        color: AppColor.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ),


              SizedBox(height: 32.h,),
              CustomButton(
                backgroundColor: state.isLoading ? AppColor.grey300 : AppColor.primary,
                borderRadius: 16.r,
                textColor: AppColor.black,

                text: state.isLoading ? "" : "Send Ping",

                image: state.isLoading
                    ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    color: AppColor.black,
                    strokeWidth: 2.5,
                  ),
                )
                    : null,

                onPressed: state.isLoading
                    ? null
                    : () async {
                  if (state.itemName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter an item name")),
                    );
                    return;
                  }

                  if (state.connectedIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select at least one connection")),
                    );
                    return;
                  }
                  // 2. Trigger API
                  await controller.sendPing();
                  context.pop();

                },
              )

            ],
          ),
        ),
      ),
    );
  }


}

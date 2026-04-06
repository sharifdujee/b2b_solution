// import 'package:b2b_solution/core/design_system/app_color.dart';
// import 'package:b2b_solution/core/gloabal/custom_button.dart';
// import 'package:b2b_solution/core/gloabal/custom_text.dart';
// import 'package:b2b_solution/core/gloabal/urgency_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../core/gloabal/custom_selector.dart';
// import '../../../../core/gloabal/custom_text_form_field.dart';
// import '../../../../core/gloabal/radius_selector.dart';
// import '../../../../core/utils/local_assets/icon_path.dart';
// import '../../model/ping_model.dart';
// import '../../provider/ping_provider.dart';
//
// class CreatePingScreen extends ConsumerWidget{
//   const CreatePingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(createPingProvider);
//     final controller = ref.read(createPingProvider.notifier);
//
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: Container(
//         margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: ()=>context.pop(),
//                     child: Image.asset(IconPath.arrowLeft, height: 24.h,width: 24.w,)
//                   ),
//                   SizedBox(width: 12.w,),
//                   CustomText(
//                     text: "Create Ping",
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColor.black,
//                   )
//                 ],
//               ),
//
//
//               SizedBox(height: 8.h,),
//               Divider(color: AppColor.grey50,),
//
//
//               SizedBox(height: 24.h,),
//               CustomText(
//                 text: "Urgency Level",
//                 fontSize: 16.sp,
//                 color: AppColor.black,
//                 fontWeight: FontWeight.w600,
//               ),
//
//               SizedBox(height: 12.h),
//               UrgencySelector(
//                   selected: state.priority,
//                   onChanged: (newPriority) => controller.updatePriority(newPriority),
//               ),
//
//
//               SizedBox(height: 16.h,),
//               CustomText(
//                 text: "Item Needed",
//                 fontSize: 16.sp,
//                 color: AppColor.black,
//                 fontWeight: FontWeight.w600,
//               ),
//
//               SizedBox(height: 12.h,),
//               CustomTextFormField(
//                 onChanged: (value) => controller.updateItemName(value),
//                 hintText: "Coffee Cups",
//                 hintTextColor: AppColor.grey400,
//                 textColor: AppColor.black,
//                 borderRadius: 12.r,
//               ),
//
//
//               SizedBox(height: 16.h,),
//               CustomText(
//                 text: "Quantity",
//                 fontSize: 16.sp,
//                 color: AppColor.black,
//                 fontWeight: FontWeight.w600,
//               ),
//
//               SizedBox(height: 12.h,),
//               CustomTextFormField(
//                 onChanged: (value) {
//                   final int? parsedValue = int.tryParse(value);
//                   if (parsedValue != null) {
//                     controller.updateQuantity(parsedValue);
//                   }
//                 },
//                 hintText: "Quantity (e.g. 50)",
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 hintTextColor: AppColor.grey400,
//                 textColor: AppColor.black,
//                 borderRadius: 12.r,
//               ),
//
//
//
//               SizedBox(height: 16.h,),
//               CustomSelectField<String>(
//                 label: "Unit",
//                 hintText: "Select Category",
//                 value: state.unit,
//                 items: const ["Kg", "Liter", "Bag", "Pieces", "Meter"],
//                 itemLabelBuilder: (val) => val,
//                 showSearchBar: true,
//                 showActionButtons: false,
//                 onChanged: (val) => controller.updateUnit(val),
//               ),
//
//
//
//               SizedBox(height: 16.h,),
//               CustomSelectField<String>(
//                 label: "Category",
//                 hintText: "Select Category",
//                 value: state.productCategory,
//                 items: const ["Snacks", "Soups", "Salads", "Drinks"],
//                 itemLabelBuilder: (val) => val,
//                 showSearchBar: true,
//                 showActionButtons: false,
//                 onChanged: (val) => controller.updateProductCategory(val),
//               ),
//
//
//               SizedBox(height: 16.h,),
//               CustomText(
//                 text: "Note",
//                 fontSize: 16.sp,
//                 color: AppColor.black,
//                 fontWeight: FontWeight.w600,
//               ),
//               SizedBox(height: 12.h,),
//               CustomTextFormField(
//                 onChanged: (value) {
//                     controller.updateNotes(value);
//                 },
//                 hintText: "Write a note",
//                 hintTextColor: AppColor.grey400,
//                 textColor: AppColor.black,
//                 borderRadius: 12.r,
//               ),
//               // CustomSelectField<String>(
//               //   label: "Notes",
//               //   hintText: "Select note",
//               //   value: state.notes,
//               //   items: const [
//               //       "Urgent! Out of cups!",
//               //       "Emergency! Delivery Needed!",
//               //       "Urgent! Out of Oli",
//               //
//               //     ],
//               //   itemLabelBuilder: (val) => val,
//               //   showSearchBar: true,
//               //   showActionButtons: false,
//               //   onChanged: (val) => controller.updateNotes(val),
//               // ),
//
//
//
//
//               SizedBox(height: 16.h,),
//               CustomText(
//                 text: "Radius",
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: AppColor.black,
//               ),
//               SizedBox(height: 12.h),
//               RadiusSelector(
//                 selectedRadius: state.radius ?? 5,
//                 onChanged: (newRadius) => controller.updateRadius(newRadius),
//               ),
//
//               SizedBox(height: 16.h,),
//               CustomSelectField<String>(
//                 label: "Choose Connection",
//                 hintText: "Choose Connection",
//                 isMultiSelect: true,
//                 showSearchBar: true,
//                 initialSelectedItems: state.chooseConnection ?? [],
//                 items: const ["Friends", "B2B Gold","Abc Restaurant"],
//                 itemLabelBuilder: (val) => val,
//                 onChanged: (list) => controller.updateConnection(list),
//               ),
//
//
//               SizedBox(height: 16.h,),
//               GestureDetector(
//                 onTap: () => controller.toggleMyConnectionOnly(),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Icon(
//                       state.myConnectionOnly
//                           ? Icons.check_circle
//                           : Icons.check_circle_outline,
//                       color: state.myConnectionOnly ? AppColor.secondary : AppColor.grey400,
//                       size: 22.sp,
//                     ),
//                     SizedBox(width: 8.w),
//                     CustomText(
//                       text: "Send To My Connection Only.",
//                       fontSize: 14.sp,
//                       color: AppColor.black,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ],
//                 ),
//               ),
//
//
//               SizedBox(height: 32.h,),
//               CustomButton(
//                 backgroundColor: AppColor.primary,
//                   borderRadius: 16.r,
//                   text: "Send Ping",
//                   textColor: AppColor.black,
//                   onPressed: (){
//
//                   }
//               )
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
// }
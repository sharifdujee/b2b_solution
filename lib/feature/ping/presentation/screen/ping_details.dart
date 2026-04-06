// import 'package:b2b_solution/core/design_system/app_color.dart';
// import 'package:b2b_solution/core/gloabal/custom_button.dart';
// import 'package:b2b_solution/core/gloabal/custom_text.dart';
// import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../core/gloabal/priority_badge.dart';
// import '../../model/ping_model.dart';
//
// class PingDetails extends ConsumerWidget{
//   final PingModel ping;
//   const PingDetails({super.key, required this.ping});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//
//
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SingleChildScrollView(
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: ()=> context.pop(),
//                       child: Image.asset(IconPath.arrowLeft, height: 24.h,width: 24.w,)),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 20.sp,
//                     text: "Ping Details",
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 24.h,),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: Image.asset(ping.logoUrl, fit: BoxFit.cover,),
//               ),
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   CustomText(
//                     text: ping.shopName,
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColor.black,
//                   ),
//
//                   Spacer(),
//                   CustomText(text: "Member Since: ", fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColor.grey400),
//                   CustomText(text: ping.membershipYear.toString(), fontSize: 14.sp, fontWeight: FontWeight.w500,color: AppColor.black,)
//                 ],
//               ),
//
//               CustomText(text: ping.shopAddress.toString(), fontSize: 14.sp,fontWeight: FontWeight.w500,color: AppColor.grey400,),
//
//
//               SizedBox(height: 16.h,),
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   int dashCount = (constraints.maxWidth / 8).floor();
//
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(dashCount, (_) {
//                       return SizedBox(
//                         width: 4,
//                         height: 1,
//                         child: DecoratedBox(
//                           decoration: BoxDecoration(
//                             color: AppColor.grey100,
//                           ),
//                         ),
//                       );
//                     }),
//                   );
//                 },
//               ),
//
//
//               SizedBox(height: 16.h,),
//               Row(
//                 children: [
//                   SizedBox.shrink(),
//                   Spacer(),
//                   PriorityBadge(priority: ping.priority),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.vegetarianFood, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                       text: "Item Needed",
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.itemName.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.package, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Quantity",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.quantity.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.unit, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Unit",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.unit.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.timer02, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Needed within",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.neededWithin.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.locationUser, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Radius",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.radius.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.notebook, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Notes",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.notes.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 14.h,),
//               Row(
//                 children: [
//                   Image.asset(IconPath.agreement, height: 20.h, width: 20.w,),
//                   SizedBox(width: 8.w,),
//                   CustomText(
//                     text: "Choose Connection",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.grey400,
//                   ),
//                   Spacer(),
//                   CustomText(
//                     text: ping.chooseConnection.toString(),
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColor.black,
//                   ),
//                 ],
//               ),
//
//
//               SizedBox(height: 42.h,),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                         text: "Decline Ping",
//                         isOutlined: true,
//                         textColor: AppColor.emergencyBadgeText,
//                         backgroundColor: AppColor.white,
//                         borderGradient: LinearGradient(
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                           colors: [
//                             AppColor.emergencyBadgeText,
//                             AppColor.emergencyBadgeText,
//                           ]
//                         ),
//                         borderWidth: 1,
//                         borderRadius: 16.r,
//                         onPressed: (){
//
//                         }
//                     ),
//                   ),
//                   SizedBox(width: 16.w,),
//                   Expanded(
//                     child: CustomButton(
//                         text: "Accept Ping",
//                         textColor: AppColor.black,
//                         backgroundColor: AppColor.primary,
//                         borderRadius: 16.r,
//                         onPressed: (){
//
//                         }
//                     ),
//                   ),
//                 ],
//               ),
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
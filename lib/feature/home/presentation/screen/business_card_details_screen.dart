import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../model/my_connection_state_model.dart';

class BusinessCardScreen extends ConsumerWidget {
  final MyConnectionStateModel connection;
  const BusinessCardScreen({super.key, required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        // Use physics to ensure it feels smooth
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    text: "Business Card Details",
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // --- Brand Image Card ---
              Container(
                width: double.infinity,
                height: 300.h, // Fixed height prevents layout issues
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700), // Matching the yellow in your photo
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(connection.icon, fit: BoxFit.contain),
                ),
              ),

              SizedBox(height: 14.h),

              // --- Name and Membership ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( // Prevents name from pushing membership off screen
                    child: CustomText(
                      text: connection.name,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      maxLines: 1,
                    ),
                  ),
                  Row(
                    children: [
                      CustomText(text: "Member Since: ", fontSize: 12.sp, color: AppColor.grey400),
                      CustomText(text: connection.membershipYear.toString(), fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ],
                  )
                ],
              ),SizedBox(height: 8.h,),
              CustomText(text: connection.address, fontSize: 12.sp, color: AppColor.grey400),


              SizedBox(height: 16.h),

              // --- Dashed Divider ---
              _buildDashedLine(),

              SizedBox(height: 14.h),

              // --- Detail Rows (Location, Phone, Email) ---
              _buildDetailRow(IconPath.restaurantIcon, "Fast Food Restaurant", connection.address),
              SizedBox(height: 14.h),
              _buildDetailRow(IconPath.phoneCall, "Phone", connection.phoneNumber),
              SizedBox(height: 14.h),
              _buildDetailRow(IconPath.mail, "Email", connection.email),

              SizedBox(height: 42.h),

              // --- FIX: Action Buttons (Using Expanded) ---
              Row(
                children: [
                  if (connection.sendRequestStatus == true)
                    Expanded(
                      child: CustomButton(
                        text: "Connect",
                        textColor: AppColor.black,
                        backgroundColor: AppColor.primary,
                        borderRadius: 16.r,
                        onPressed: () {},
                      ),
                    )
                  else
                    Expanded(
                      child: CustomButton(
                        text: "Ping",
                        textColor: AppColor.black,
                        backgroundColor: AppColor.primary,
                        borderRadius: 16.r,
                        onPressed: () {

                        },
                      ),
                    ),

                  SizedBox(width: 16.w),

                  Expanded(
                    child: CustomButton(
                      text: "Share",
                      textColor: AppColor.white,
                      backgroundColor: AppColor.secondary,
                      borderRadius: 16.r,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(width: 1, color: AppColor.primary)
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(IconPath.chat,height: 24.h, width: 24.w,),
                      SizedBox(width: 8.w,),
                      CustomText(text: "Message", fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColor.primary,)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper to keep logic clean
  Widget _buildDetailRow(String icon, String label, String value) {
    return Row(
      children: [
        Image.asset(icon, height: 20.h, width: 20.w),
        SizedBox(width: 8.w),
        CustomText(text: label, fontSize: 14.sp, color: AppColor.grey400),
        const Spacer(),
        Expanded(
          flex: 2, // Gives the value more room than the label
          child: CustomText(
            text: value,
            fontSize: 14.sp,
            textAlign: TextAlign.right,
            fontWeight: FontWeight.w500,
            color: AppColor.black,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(width: 4.w, height: 1.h, child: DecoratedBox(decoration: BoxDecoration(color: AppColor.grey100)));
          }),
        );
      },
    );
  }
}
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/core/utils/local_assets/image_path.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: AppColor.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 48.h,),

              /// Top Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(

                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: AssetImage(ImagePath.coffeeLogo, ),

                    ),
                    SizedBox(width: 3.w,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Welcome,", fontWeight: FontWeight.w500,fontSize: 14.sp,color: AppColor.welcomeColor,),
                        SizedBox(height: 4.h,),
                        CustomText(text: "Shamim Islam!", color: AppColor.black,fontSize: 16.sp,fontWeight: FontWeight.w600,)
                      ],
                    ),
                    SizedBox(width: 107.w,),
                    GestureDetector(
                      onTap: ()=> context.push("/notificationScreen"),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.r),
                            border: Border.all(
                                width: 1.w,
                                color: AppColor.black.withValues(alpha: 0.16)
                            ),
                            color: AppColor.white
                        ),
                        child: SvgPicture.asset(IconPath.notification, fit: BoxFit.cover,height: 24.h,width: 24.w,),
                      ),
                    )
                  ],
                ),
              ),

              /// Map section
              /// Quick action section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomText(text: "Quick Actions", fontWeight: FontWeight.w700,fontSize: 18.sp,color: AppColor.black,),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(

                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                      decoration: BoxDecoration(
                          color: AppColor.quickActionColor,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Column(
                        children: [
                          Image.asset(IconPath.map, fit: BoxFit.cover),
                          CustomText(text: "Map View", fontSize: 12.sp,fontWeight: FontWeight.w500,color: AppColor.white,)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                      decoration: BoxDecoration(
                          color: AppColor.quickActionColor,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Column(
                        children: [
                          Image.asset(IconPath.map, fit: BoxFit.cover),
                          CustomText(text: "My Collections")
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                      decoration: BoxDecoration(
                          color: AppColor.quickActionColor,
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      child: Column(
                        children: [
                          Image.asset(IconPath.map, fit: BoxFit.cover),
                          CustomText(text: "Vendors")
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              ///
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Nearby Ping Requests", fontWeight: FontWeight.w600,fontSize: 18.sp,color: AppColor.black,),

                    GestureDetector(
                      onTap: (){

                      },
                      child: CustomText(text: "View All", fontSize: 12.sp,fontWeight: FontWeight.w400,color: AppColor.primary,),

                    )

                  ],
                ),

              ),


            ],
          ),
        )
    );
  }
}
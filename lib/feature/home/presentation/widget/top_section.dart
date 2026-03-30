import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../../core/utils/local_assets/image_path.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: AssetImage(ImagePath.coffeeLogo),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Welcome,",
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColor.welcomeColor,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text: "Shamim Islam!",
                color: AppColor.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: ()=>context.push('/createPingScreen')  ,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: AppColor.black.withValues(alpha: 0.16),
                  )
                ],
                border: Border.all(
                  width: 1.w,
                  color: AppColor.primary.withValues(alpha: 0.16),
                ),
                color: AppColor.primary,
              ),
              child: Icon(Icons.add, size: 24.h, color: AppColor.white)
            ),
          ),

          SizedBox(width: 8.w,),
          GestureDetector(
            onTap: ()=>context.push('/notificationScreen')  ,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: AppColor.black.withValues(alpha: 0.16),
                  )
                ],
                border: Border.all(
                  width: 1.w,
                  color: AppColor.black.withValues(alpha: 0.16),
                ),
                color: AppColor.white,
              ),
              child: SvgPicture.asset(
                IconPath.notification,
                fit: BoxFit.cover,
                height: 20.h,
                width: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
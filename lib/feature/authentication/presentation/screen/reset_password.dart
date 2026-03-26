import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';

import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/reset_password_provider.dart';


class ResetPassword extends ConsumerWidget {
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class ResetPassword extends ConsumerWidget{

  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h,),
              GestureDetector(
                  child: Image.asset(IconPath.arrowLeft, height:24.h, width: 24.h,),
                  onTap: ()=> context.pop()
              ),


              SizedBox(height: 16,),
              CustomText(
                text: "Reset Password",
                fontSize: 24.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 16.h,),
              CustomText(
                text: "Enter your email address to get a verification code.",
                fontSize: 14.sp,
                color: AppColor.grey400,
              ),

              SizedBox(height: 24.h,),
              CustomText(
                text: "Email Address",
                fontSize: 16.sp,
                color: AppColor.black,
              ),

              SizedBox(height: 12.h,),


            ],
          ),
        ),
      ),
    );
  }

}
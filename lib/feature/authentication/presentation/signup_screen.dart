 import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/design_system/app_color.dart';
import '../../../core/gloabal/custom_text.dart';
import '../../../core/gloabal/custom_text_form_field.dart';
import '../provider/signup_notifier.dart';

class SignupScreen extends ConsumerWidget{
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final controller = ref.read(signupProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 48.h,),
            Image.asset(IconPath.arrowLeft, height:24.h, width: 24.h,),

            SizedBox(height: 16.h,),
            CustomText(
              text: "Create an account",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),

            SizedBox(height: 16.h,),
            CustomText(
              text: "Connect. Trade. Grow. It starts here.",
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.grey400,
            ),

            SizedBox(height: 32.h,),
            CustomText(
              text: "Legal Name",
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),

            SizedBox(height: 12.h,),
            CustomTextFormField(
              onChanged: (value) => controller.updateLegalName(value),
              hintText: "Ex. 101010 Ontario inc",
              hintTextColor: AppColor.grey400,
            )
          ],
        )
      ),
    );
  }
}
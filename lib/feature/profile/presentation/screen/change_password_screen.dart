import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_dialog.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../provider/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerWidget{
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final state = ref.watch(changePasswordProvider);
    final controller = ref.read(changePasswordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w,vertical: 48.h),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: ()=> context.pop(),
                child: Image.asset(IconPath.arrowLeft,height: 24.h,width: 24.w)
            ),


            SizedBox(height: 16.h,),
            CustomText(
              text: "Change Password",
              fontSize: 24.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w600,
            ),


            SizedBox(height: 32.h,),
            CustomText(
              text: "Old Password",
              fontSize: 16.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w500,
            ),

            SizedBox(height: 12.h,),
            CustomTextFormField(
                onChanged: (value) => controller.updateOldPassword(value),
                hintText: "Old Password",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
                obscureText: state.obscureOldPassword,
                suffixIcon: IconButton(
                    onPressed: () => controller.toggleOldPasswordVisibility(),
                    icon: Icon(
                        state.obscureOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.grey400
                    )
                )
            ),



            SizedBox(height: 32.h,),
            CustomText(
              text: "New Password",
              fontSize: 16.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w500,
            ),

            SizedBox(height: 12.h,),
            CustomTextFormField(
                onChanged: (value) => controller.updateNewPassword(value),
                hintText: "New Password",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
                obscureText: state.obscureNewPassword,
                suffixIcon: IconButton(
                    onPressed: () => controller.toggleNewPasswordVisibility(),
                    icon: Icon(
                        state.obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.grey400
                    )
                )
            ),


            SizedBox(height: 32.h,),
            CustomText(
              text: "Confirm password",
              fontSize: 16.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w500,
            ),

            SizedBox(height: 12.h,),
            CustomTextFormField(
                onChanged: (value) => controller.updateNewPassword(value),
                hintText: "Confirm password",
                hintTextColor: AppColor.grey400,
                textColor: AppColor.black,
                borderRadius: 12.r,
                obscureText: state.obscureConfirmPassword,
                suffixIcon: IconButton(
                    onPressed: () => controller.toggleConfirmPasswordVisibility(),
                    icon: Icon(
                        state.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.grey400
                    )
                )
            ),

            Spacer(),
            CustomButton(
                backgroundColor: AppColor.primary,
                textColor: AppColor.black,
                borderRadius: 12.r,
                text: "Change Password",
                onPressed: (){
                  showCustomDialog(
                    context,
                    imagePath: IconPath.shield,
                    title: "Password Changed",
                    message: "Password changed successfully, you can login again with new password",
                    buttonText: "Log in",
                    onPressed: () {
                      context.push('/loginScreen');
                    },
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
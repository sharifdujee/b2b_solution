import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../models/signup_state_model.dart';
import '../../provider/signup_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final controller = ref.read(signupProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
        child: Column(

          children: [
            CustomText(
              text: "Select your role",
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.black
            ),
            SizedBox(height: 32.h),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            _buildRoleCard(
              title: "Vendor",
              subtitle: "Sign up as Vendor",
              isSelected: state.selectRole == Role.vendor,
              onTap: () => controller.changeRole(Role.vendor),
            ),

            SizedBox(height: 16.h),

            _buildRoleCard(
              title: "User",
              subtitle: "Sign up as User",
              isSelected: state.selectRole == Role.user,
              onTap: () => controller.changeRole(Role.user),
            ),
            SizedBox(height: MediaQuery.of(context).size.height *0.25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: "Already have an account?",
                  fontSize: 14.sp,
                  color: AppColor.grey500,
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () {
                    context.push('/loginScreen');
                  },
                  child: CustomText(
                    text: "Login",
                    fontSize: 14.sp,
                    color: AppColor.primary,
                  ),
                )
              ],
            ),
            Spacer(),
            CustomButton(
                text: "Continue",
                backgroundColor: AppColor.primary,
                textColor: AppColor.black,
                borderRadius: 16.r,
                onPressed: (){
                  context.push('/signupScreen');
                }
            )
          ],
        ),
      ),

    );


  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.grey400,
            width: 1,
          ),
        ),
        child: Row(
          children: [

            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColor.white : AppColor.black,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: subtitle,
                  fontSize: 14.sp,
                  color: isSelected ? AppColor.white : AppColor.grey500,
                ),
              ],
            ),
            Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColor.white : AppColor.primary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
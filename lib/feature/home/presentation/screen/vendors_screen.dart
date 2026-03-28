import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class VendorsScreen extends ConsumerWidget{
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Image.asset(
                    IconPath.arrowLeft,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
                SizedBox(width: 10.w,),
                CustomText(
                  text: "Vendors",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),

            SizedBox(height: 24.h,),
            CustomTextFormField(
              onChanged: (value) {
              },
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.r),
                child: SvgPicture.asset(IconPath.search, height: 20.h, width: 20.w),
              ),
              hintText: "Search",
              hintTextColor: AppColor.grey400,
              textColor: AppColor.black,
              borderRadius: 50.r,
            ),


            SizedBox(height: 24.h,),

          ],
        ),
      ),
    );
  }

}
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/gloabal/custom_text.dart';
import '../../../core/utils/local_assets/icon_path.dart';
class BusinessLocationMapView extends ConsumerWidget {
  const BusinessLocationMapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20.w
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 48.h,),
              Image.asset(IconPath.arrowLeft, height:24.h, width: 24.h,),

              SizedBox(height: 16.h,),
              CustomText(
                text: "Choose Business Location",
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// complete the design of the page, display the nearyby location in map, manage state use riverpod and location search functionality
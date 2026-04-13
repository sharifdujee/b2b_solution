import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/core/gloabal/custom_text_form_field.dart';
import 'package:b2b_solution/feature/home/provider/my_connection_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../widget/my_connection_card.dart';
import '../widget/my_connection_filter.dart';

class MyConnectionScreen extends ConsumerWidget{
  const MyConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final connectionState = ref.watch(myConnectionListProvider);
    final connectionItems = connectionState.items;
    final isLoading = connectionState.isLoading;


    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    text: "My Connections",
                    color: AppColor.black,
                  )
                ]
              ),

              SizedBox(height: 24.h),
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

              SizedBox(height: 24.h),
              const MyConnectionFilter(),

              SizedBox(height: 24.h),
              if(isLoading && connectionItems.isEmpty)
                _buildLoadingState()
              else if(connectionItems.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: connectionItems.length,
                      itemBuilder: (context, index) {
                        final connection = connectionItems[index];
                        return MyConnectionCard(connection: connection, currentUserId: connection.senderId,);
                      }
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: CustomText(
          text: "No connections found",
          color: AppColor.grey400,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: CircularProgressIndicator(
          color: AppColor.primary,
        ),
      ),
    );
  }

}
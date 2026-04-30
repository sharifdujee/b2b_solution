import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../profile/provider/profile_provider.dart';

class TopSection extends ConsumerStatefulWidget {
  const TopSection({super.key});

  @override
  ConsumerState<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends ConsumerState<TopSection> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider);
      if (!profile.hasUser) {
        profile.getMyProfile();
      }
    });
  }
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good morning, ";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon, ";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening, ";
    } else if (hour >= 21 || hour < 5) {
      return "Good night, ";
    } else {
      return "Hello, ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    final user =profileState.userModel;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: AppColor.secondary.withValues(alpha: 0.7),
                    )
                  ],
                ),
                child: CircleAvatar(
                    radius: 30.r,
                    backgroundImage: (user?.profileImage != null && user!.profileImage.isNotEmpty)
                        ? NetworkImage(user!.profileImage.toString())
                        : null,
                    child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                        ? Icon(Icons.person, size: 30.r, color: Colors.grey)
                        : null
                ),
              ),

              const Spacer(),



              GestureDetector(
                child: Icon(Icons.wallet,size: 32.r,color: AppColor.secondary,),
              ),
              SizedBox(width: 8.w,),

              GestureDetector(
                onTap: () => context.push('/notificationScreen'),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: AppColor.secondary.withValues(alpha: 0.16),
                      )
                    ],
                    border: Border.all(
                      width: 1.w,
                      color: AppColor.black.withValues(alpha: 0.16),
                    ),
                    color: AppColor.primary.withValues(alpha: 0.9),
                  ),
                  child: SvgPicture.asset(
                    IconPath.notification,
                    fit: BoxFit.cover,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 8.w),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: _getGreeting(),
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: AppColor.black,
              ),
              CustomText(
                text: user?.fullName ?? "Joe's Cafe",
                color: AppColor.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(width: 8.w),
              Image.asset(IconPath.shield, height: 16.h, width: 16.w)
            ],
          ),
        ],
      ),
    );
  }
}
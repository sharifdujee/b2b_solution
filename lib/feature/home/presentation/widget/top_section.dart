import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../../core/utils/local_assets/image_path.dart';
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    final user =profileState.userModel;
    final isLoading = profileState.isLoading;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: (user?.profileImage != null && user!.profileImage.isNotEmpty)
                ? NetworkImage(user!.profileImage)
                : null,
              child: (user?.profileImage == null || user!.profileImage.isEmpty)
                  ? Icon(Icons.person, size: 30.r, color: Colors.grey)
                  :null
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
                text: user?.fullName ?? "Joe's Cafe",
                color: AppColor.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/notificationScreen'),
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
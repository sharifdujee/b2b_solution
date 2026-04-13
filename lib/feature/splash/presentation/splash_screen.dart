import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/feature/splash/provider/splash_provider.dart'; // Ensure correct path
import 'package:b2b_solution/feature/splash/widgets/dotted_circle_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/local_assets/icon_path.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppStartupState>(splashProvider, (previous, next) {

      if (next == AppStartupState.authenticated) {
        context.go("/nav");
      } else if (next == AppStartupState.unauthenticated) {
        context.go("/onBoarding");
      }
    });

    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Image.asset(
                IconPath.b2bLogo,
                height: 224.h,
                width: 180.w,
              ),
              const DottedCircleLoader(),
            ],
          ),
        ),
      ),
    );
  }
}
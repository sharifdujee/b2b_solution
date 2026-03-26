




import 'package:b2b_solution/feature/ping/model/presentation/screen/ping_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/design_system/app_color.dart';
import '../../../core/utils/local_assets/icon_path.dart';
import '../../home/presentation/screen/home_screen.dart';
import '../../message/presentation/screen/message_screen.dart';
import '../../profile/presentation/screen/profile_screen.dart';






// State provider for selected index
final selectedIndexProvider = StateProvider<int>((ref) => 0);





class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // Different screens for each tab
    final screens = [
      const HomeScreen(),
      const PingScreen(),

      const MessageScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          // selectedItemColor: AppColor.primary, // Green color
          unselectedItemColor: const Color(0xFF9E9E9E), // Gray color
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items:  [
            BottomNavigationBarItem(
              icon: Container(
                  margin: EdgeInsets.only(bottom: 4.w),
                  child: SvgPicture.asset(IconPath.homeNav)
                ///Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                decoration: BoxDecoration(
                    color: Color(0xFFFFC220),
                    borderRadius: BorderRadius.circular(40.r)
                ),
                margin: EdgeInsets.only(bottom: 4.w),
                child: SvgPicture.asset(IconPath.homeNav,colorFilter: ColorFilter.linearToSrgbGamma(),),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  margin: EdgeInsets.only(bottom: 4.w),
                  child: SvgPicture.asset(IconPath.pingNav)
                ///Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Container(
                margin: EdgeInsets.only(bottom: 4.w),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFFC220),
                  borderRadius: BorderRadius.circular(40.r)
                ),
                child: SvgPicture.asset(IconPath.pingNav, colorFilter: ColorFilter.linearToSrgbGamma(),),
              ),
              label: 'Ping',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  margin: EdgeInsets.only(bottom: 4.w),
                  child: SvgPicture.asset(IconPath.messageNav)
                ///Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Container(
                margin: EdgeInsets.only(bottom: 4.w),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                decoration: BoxDecoration(
                    color: Color(0xFFFFC220),
                    borderRadius: BorderRadius.circular(40.r)
                ),
                child: SvgPicture.asset(IconPath.messageNav,colorFilter: ColorFilter.linearToSrgbGamma(),),
              ),
              label: 'Message        ',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  margin: EdgeInsets.only(bottom: 4.w),
                  child: SvgPicture.asset(IconPath.profileNav)
                ///Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Container(
                margin: EdgeInsets.only(bottom: 4.w),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(40.r)
                ),
                child: SvgPicture.asset(IconPath.pingNav,colorFilter: ColorFilter.linearToSrgbGamma(),),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../provider/map_filter_provider.dart';

class MapFilter extends ConsumerWidget {
  const MapFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(mapFilterProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _FilterButton(
              label: "Emergency\nPing",
              icon: IconPath.emergency,
              isActive: activeFilter == MapFilterType.EMERGENCY,
              activeColor: AppColor.secondary,
              onTap: () => ref.read(mapFilterProvider.notifier).state = MapFilterType.EMERGENCY,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _FilterButton(
              label: "Quick Vendor\nLookup",
              icon: IconPath.store,
              isActive: activeFilter == MapFilterType.VENDOR,
              activeColor: AppColor.secondary,
              onTap: () => ref.read(mapFilterProvider.notifier).state = MapFilterType.VENDOR,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Styling logic
    final bool isDarkBackground = isActive && activeColor != Colors.white;
    final Color contentColor = isDarkBackground ? Colors.white : Colors.black87;
    final Color iconTintColor = isDarkBackground ? Colors.yellow : const Color(0xFF1B5E20);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(iconTintColor),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to render either SVG or PNG
  Widget _buildIcon(Color tintColor) {
    final bool isSvg = icon.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        icon,
        height: 24.h,
        width: 24.w,
      );
    } else {
      return Image.asset(
        icon,
        height: 24.h,
        width: 24.w,
      );
    }
  }
}
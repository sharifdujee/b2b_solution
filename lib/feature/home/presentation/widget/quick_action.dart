import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/home/presentation/widget/quick_action_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuickActionItem(label: "Map View", icon: IconPath.map, onTap: (){
            context.push('/mapView');
          },),
          //QuickActionItem(label: "My Collections", icon: Icons.bookmark_rounded),
          //QuickActionItem(label: "Vendors", icon: Icons.store_rounded),
        ],
      ),
    );
  }
}
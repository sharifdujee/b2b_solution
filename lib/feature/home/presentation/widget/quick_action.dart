import 'package:b2b_solution/feature/home/presentation/widget/quick_action_item.dart';
import 'package:b2b_solution/feature/navigation/presentation/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/quick_action_provider.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current selection
    final selectedLabel = ref.watch(selectedQuickActionProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuickActionItem(
            label: "Map View",
            icon: IconPath.map,
            isSelected: selectedLabel == "Map View",
            onTap: () {
              ref.read(selectedQuickActionProvider.notifier).state = "Map View";
              context.push('/mapView');
            },
          ),
          QuickActionItem(
            label: "My Collections",
            icon: IconPath.userGroup,
            isSelected: selectedLabel == "My Collections",
            onTap: () {
              ref.read(selectedQuickActionProvider.notifier).state = "My Collections";
              context.push('/myConnectionScreen');
            },
          ),
          QuickActionItem(
            label: "Vendors",
            icon: IconPath.store,
            isSelected: selectedLabel == "Vendors",
            onTap: () {
              ref.read(selectedQuickActionProvider.notifier).state = "Vendors";
              context.push('/vendorsScreen');
            },
          ),

          //Comment this in meeting if needed
          QuickActionItem(
            label: "Profile",
            icon: IconPath.colorProfile,
            isSelected: selectedLabel == "Vendors",
            onTap: () {
              ref.read(selectedQuickActionProvider.notifier).state = "Profile";
              ref.read(selectedIndexProvider.notifier).state = 3;
            },
          ),
        ],
      ),
    );
  }
}
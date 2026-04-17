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
import '../../model/my_connection_state_model.dart';
import '../widget/my_connection_card.dart';
import '../widget/my_connection_filter.dart';

class MyConnectionScreen extends ConsumerWidget {
  const MyConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(myConnectionListProvider);
    final currentFilter = ref.watch(connectionFilterProvider);

    // 1. Determine which list to show based on the active tab
    final List<dynamic> displayItems = (currentFilter == ConnectionFilterOption.Find)
        ? connectionState.discoverItems
        : connectionState.items;

    // 2. Initial fetch logic: if the current list is empty, fetch data
    if (displayItems.isEmpty && !connectionState.isLoading && connectionState.hasMore) {
      Future.microtask(() {
        ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header & Search (Fixed Section)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  Row(children: [
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
                  ]),
                  SizedBox(height: 24.h),
                  CustomTextFormField(
                    onChanged: (value) {},
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
                ],
              ),
            ),

            /// Scrollable List Area (Dynamic Section)
            Expanded(
              child: _buildListContent(
                ref,
                connectionState.isLoading,
                displayItems,
                connectionState.hasMore,
                currentFilter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Consolidated List Content Logic
  Widget _buildListContent(
      WidgetRef ref,
      bool isLoading,
      List<dynamic> items,
      bool hasMore,
      ConnectionFilterOption currentFilter) {

    // Show full screen loader only on the first load
    if (isLoading && items.isEmpty) {
      return _buildLoadingState();
    }

    // Show empty state if no data returned
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Trigger pagination when reaching the bottom (200px threshold)
        if (!isLoading &&
            hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: false);
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true);
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          // Add +1 to itemCount to show the loading indicator at the bottom
          itemCount: items.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < items.length) {
              final item = items[index];

              return MyConnectionCard(
                connectionData: item,
                // Replace this String with your actual Auth Provider's User ID
                currentUserId: "677d2427a925f9df9468e27c",
              );
            } else {
              // Bottom Loading Indicator for Pagination
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48.sp, color: AppColor.grey400),
          SizedBox(height: 12.h),
          CustomText(
            text: "No connections found",
            color: AppColor.grey400,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColor.primary,
      ),
    );
  }
}
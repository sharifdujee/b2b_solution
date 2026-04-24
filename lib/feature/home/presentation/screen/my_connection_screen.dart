import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/gloabal/custom_text_form_field.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../../ping/provider/connection_provider.dart'; // Search results provider
import '../../model/my_connection_state_model.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/my_connection_card.dart';
import '../widget/my_connection_filter.dart';

class MyConnectionScreen extends ConsumerStatefulWidget {
  const MyConnectionScreen({super.key});

  @override
  ConsumerState<MyConnectionScreen> createState() => _MyConnectionScreenState();
}

class _MyConnectionScreenState extends ConsumerState<MyConnectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(myConnectionListProvider);
    final searchState = ref.watch(connectionProvider); // Watch the search provider
    final currentFilter = ref.watch(connectionFilterProvider);

    ref.listen(connectionFilterProvider, (previous, next) {
      if (previous != next) {
        // Clear search UI when switching tabs
        ref.read(myConnectionListProvider.notifier).searchQueryController.clear();
        // Optionally reset search provider state here if needed

        ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true);
      }
    });

    // Determine which items to show: search results or tab items
    final String searchQuery = ref.read(myConnectionListProvider.notifier).searchQueryController.text;
    final bool isSearching = searchQuery.isNotEmpty;

    final List<dynamic> displayItems = isSearching
        ? searchState.connections
        : _getDisplayItems(connectionState, currentFilter);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFixedHeader(context, currentFilter),
            Expanded(
              child: _buildListContent(
                isSearching ? searchState.isLoading : connectionState.isLoading,
                displayItems,
                isSearching ? false : connectionState.hasMore, // Disable pagination during search
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getDisplayItems(dynamic state, ConnectionFilterOption filter) {
    switch (filter) {
      case ConnectionFilterOption.Find:
        return state.discoverItems;
      case ConnectionFilterOption.Requests:
        return state.sendRequestsList;
      case ConnectionFilterOption.Pending:
        return state.pendingItems ?? [];
      case ConnectionFilterOption.Connected:
        return state.items;
      default:
        return state.items;
    }
  }

  Widget _buildFixedHeader(BuildContext context, ConnectionFilterOption currentFilter) {
    final bool isSearchVisible = currentFilter == ConnectionFilterOption.Connected ||
        currentFilter == ConnectionFilterOption.Find;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          Row(children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 8.w),
            CustomText(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              text: "My Connections",
              color: AppColor.black,
            )
          ]),

          if (isSearchVisible) ...[
            SizedBox(height: 24.h),
            CustomTextFormField(
              onChanged: (value) {
                setState(() {});
                ref.read(connectionProvider.notifier).onSearch(value);
              },
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.r),
                child: SvgPicture.asset(IconPath.search, height: 20.h, width: 20.w),
              ),
              controller: ref.read(myConnectionListProvider.notifier).searchQueryController,
              hintText: "Search connections...",
              hintTextColor: AppColor.grey400,
              textColor: AppColor.black,
              borderRadius: 50.r,
            ),
          ],

          SizedBox(height: 24.h),
          const MyConnectionFilter(),
        ],
      ),
    );
  }

  Widget _buildListContent(bool isLoading, List<dynamic> items, bool hasMore) {
    if (isLoading && items.isEmpty) return _buildLoadingState();

    final bool isSearching = ref.read(myConnectionListProvider.notifier).searchQueryController.text.isNotEmpty;

    final currentFilter = ref.watch(connectionFilterProvider);
    final bool effectiveHasMore = (currentFilter == ConnectionFilterOption.Requests || isSearching)
        ? false
        : hasMore;

    if (items.isEmpty) return _buildEmptyState(isSearching: isSearching);

    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isLoading &&
              effectiveHasMore &&
              notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300) {
            ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: false);
          }
          return false;
        },
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: items.length + (effectiveHasMore ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            if (index < items.length) {
              return MyConnectionCard(
                connectionData: items[index],
                currentUserId: AuthService.id.toString(),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isSearching = false}) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isSearching ? Icons.search_off : Icons.people_outline,
                size: 64.sp,
                color: AppColor.grey300
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: isSearching ? "No search results found" : "No connections found",
              color: AppColor.grey400,
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: AppColor.primary));
  }
}
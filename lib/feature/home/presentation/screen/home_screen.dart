import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/feature/navigation/presentation/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../ping/model/ping_pagination_state_model.dart';
import '../../../ping/presentation/widgets/ping_card.dart';
import '../../../ping/provider/ping_provider.dart';
import '../../../profile/provider/profile_provider.dart';
import '../../provider/nearby_ping_provider.dart';
import '../widget/map_section.dart';
import '../widget/top_section.dart';
import '../widget/quick_action.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileWatcher = ref.watch(profileProvider);
    final pingState = ref.watch(nearbyPingProvider);

    // FIX: Watch the paginated list provider instead of the filter enum
    final pingListAsync = ref.watch(pingListProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!profileWatcher.isLoading && profileWatcher.userModel != null) {
        final user = profileWatcher.userModel!;

        // Logic to fetch pings if the nearby list is currently empty
        if (pingState.pings.isEmpty && !pingState.isLoading && pingState.errorMessage == null) {
          ref.read(nearbyPingProvider.notifier).fetchPings(
            user.latitude,
            user.longitude,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final user = ref.read(profileProvider).userModel;
          if (user != null) {
            await ref.read(nearbyPingProvider.notifier).fetchPings(
              user.latitude,
              user.longitude,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              const TopSection(),
              SizedBox(height: 16.h),

              const MapSection(),
              SizedBox(height: 24.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomText(
                  text: "Quick Actions",
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 12.h),
              const QuickActions(),
              SizedBox(height: 24.h),

              _buildHeader(ref),
              SizedBox(height: 12.h),

              /// FIX: Use the AsyncValue from pingListProvider
              _buildPingListContent(pingListAsync),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles Loading, Error, and Data states for the paginated ping list
  Widget _buildPingListContent(AsyncValue<PingPaginationState> pingsAsync) {
    return pingsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => _buildErrorState(err.toString()),
      data: (paginationState) {
        final pings = paginationState.pings;

        if (pings.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Limit to 3 items for the Home preview
          itemCount: pings.length > 3 ? 3 : pings.length,
          itemBuilder: (context, index) {
            final ping = pings[index];
            return PingCard(
              key: ValueKey(ping.id),
              ping: ping,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            SizedBox(height: 8.h),
            CustomText(
              text: "Failed to load pings",
              color: Colors.red,
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: "Nearby Ping Requests",
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: AppColor.black,
          ),
          GestureDetector(
            onTap: () => ref.read(selectedIndexProvider.notifier).state = 1,
            child: Row(
              children: [
                CustomText(
                  text: "View All",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.secondary,
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward, size: 18.sp, color: AppColor.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Icon(Icons.notifications_off_outlined, size: 48.sp, color: AppColor.grey400),
          SizedBox(height: 12.h),
          CustomText(
            text: "No pings found in your area",
            fontSize: 14.sp,
            color: AppColor.grey500,
          ),
        ],
      ),
    );
  }
}
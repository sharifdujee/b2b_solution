import 'dart:async';
import 'dart:developer';

import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/home/presentation/widget/selected_ping_card.dart';
import 'package:b2b_solution/feature/home/provider/current_position_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../authentication/provider/location_provider.dart';
import '../../../profile/provider/profile_provider.dart';
import '../../provider/map_filter_provider.dart';
import '../../provider/nearby_ping_provider.dart';
import '../../provider/png_provider.dart' hide mapControllerProvider;
import 'map_badge.dart';
import 'map_icon_button.dart';

class MapSection extends ConsumerStatefulWidget {
  const MapSection({super.key});

  @override
  ConsumerState<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<MapSection> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(pingMapProvider);
    final pingDataState = ref.watch(nearbyPingProvider);

    final activeFilter = ref.watch(mapFilterProvider);

    final deviceLocationAsync = ref.watch(currentPositionProvider);

    final pingsWithinRadius = pingDataState.pings.where((p) {
      final bool isWithinRange = p.distanceKm <= 20;

      if (activeFilter == MapFilterType.EMERGENCY) {
        return isWithinRange && p.urgencyLevel.toUpperCase() == "EMERGENCY";
      } else {
        return isWithinRange && p.urgencyLevel.toUpperCase() != "EMERGENCY";
      }
    }).toList();

    final pingMarkers = ref.watch(pingMarkersProvider);

    final Set<Marker> markers = {
      ...pingMarkers, // Spread existing markers

      if (deviceLocationAsync.hasValue)
        Marker(
          markerId: const MarkerId('my_current_location'),
          position: deviceLocationAsync.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "You are here"),
          zIndex: 5.0,
        ),
    };
    final selectedPing = mapState.selectedPingId == null
        ? null
        : pingsWithinRadius.firstWhere(
          (p) => p.id == mapState.selectedPingId,
      orElse: () => pingsWithinRadius.isNotEmpty ? pingsWithinRadius.first : pingDataState.pings.first,
    );

    final profile = ref.watch(profileProvider);
    final double userLat = profile.latitude ?? 0.0;
    final double userLng = profile.longitude ?? 0.0;

    // ── Logic: Auto-move camera to pings when they load ──────────────────
    ref.listen(nearbyPingProvider, (previous, next) async {
      if (next.pings.isNotEmpty) {
        final firstPing = next.pings.first;
        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(firstPing.user!.businessLatitude, firstPing.user!.businessLongitude),
          ),
        );
      }
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),child: deviceLocationAsync.when(
      error: (err, stack) => const Center(child: Text("Location Error")),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (deviceLatLng) =>
      Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                // Use ping location if available, else user location
                target: pingsWithinRadius.isNotEmpty
                    ? LatLng(pingsWithinRadius.first.user!.businessLatitude, pingsWithinRadius.first.user!.businessLongitude)
                    : deviceLatLng,
                zoom: 13,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,

              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              fortyFiveDegreeImageryEnabled: true,

              onMapCreated: (controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
                ref.read(mapControllerProvider.notifier).state = controller;
              },
              onTap: (_) => ref.read(pingMapProvider.notifier).clearSelection(),
            ),
          ),

          // ── Ping Count Badge ────────────────────────────────────────────
          Positioned(
            top: 12.h,
            left: 12.w,
            child: MapBadge(
              label: "${pingsWithinRadius.length} Pings within 20km",
              icon: Icons.location_on_rounded,
            ),
          ),

          // ── SOS Button (Restored) ───────────────────────────────────────
          Positioned(
            top: 100.h,
            left: 80.w,
            child: GestureDetector(
              onTap: () => context.push('/createPingScreen'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: AppColor.primary.withValues(alpha: 0.16),
                    )
                  ],
                  border: Border(
                    bottom: BorderSide(
                      width: 4.w,
                      color: const Color(0xFFC07702),
                    ),
                  ),
                  color: AppColor.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(IconPath.emergency,height: 32.h,),
                    SizedBox(width: 8.w),
                    CustomText(
                      text: "PING (SOS)",
                      color: AppColor.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── My Location Button ──────────────────────────────────────────
          Positioned(
            bottom: selectedPing != null ? 130.h : 12.h,
            right: 12.w,
            child: MapIconButton(
              icon: Icons.my_location_rounded,
              onTap: () async {
                final ctrl = await _controller.future;
                ctrl.animateCamera(CameraUpdate.newLatLng(LatLng(userLat, userLng)));
              },
            ),
          ),

          // ── Selected Ping Card ──
          if (selectedPing != null)
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: SelectedPingCard(ping: selectedPing),
            ),

          // ── Zoom Controls ───────────────────────────────────────────────
          Positioned(
            right: 12.w,
            bottom: selectedPing != null ? 210.h : 80.h,
            child: Column(
              children: [
                MapIconButton(
                  icon: Icons.add,
                  onTap: () async {
                    final ctrl = await _controller.future;
                    ctrl.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                SizedBox(height: 10.h),
                MapIconButton(
                  icon: Icons.remove,
                  onTap: () async {
                    final ctrl = await _controller.future;
                    ctrl.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),
        ],
      ),

    ),
    );
  }
}
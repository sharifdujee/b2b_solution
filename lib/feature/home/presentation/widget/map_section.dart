import 'dart:async';

import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/feature/home/presentation/widget/selected_ping_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../provider/png_provider.dart';
import 'map_badge.dart';
import 'map_icon_button.dart';


class MapSection extends ConsumerStatefulWidget {
  const MapSection({super.key});

  @override
  ConsumerState<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<MapSection> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initial = CameraPosition(
    target: LatLng(22.3752, 91.8349),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(pingMarkersProvider);
    final pingState = ref.watch(pingProvider);
    final selectedPing = pingState.selectedPing;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: GoogleMap(
              initialCameraPosition: _initial,
              markers: markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _controller.complete(controller);
                ref.read(mapControllerProvider.notifier).state = controller;
              },
              onTap: (_) => ref.read(pingProvider.notifier).clearSelection(),
            ),
          ),

          // ── Ping Count Badge ────────────────────────────────────────────
          Positioned(
            top: 12.h,
            left: 12.w,
            child: MapBadge(
              label: "${pingState.pings.length} Pings Nearby",
              icon: Icons.location_on_rounded,
            ),
          ),

          Positioned(
            top: 110.h,
            left: 90.w,
            child: GestureDetector(
              onTap: ()=>context.push('/createPingScreen')  ,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: AppColor.black.withValues(alpha: 0.16),
                      )
                    ],
                    border: Border(
                      bottom: BorderSide(
                        width: 4.w,
                        color: Color(0xFFC07702),
                      )
                    ),
                    color: AppColor.primary,
                  ),
                  child: Row(
                    children: [
                      Image.asset(IconPath.sosIcon, height: 40.h,),
                      SizedBox(width: 8.w,),
                      CustomText(text: "PING (SOS)",
                        color: AppColor.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,),
                    ],
                  )
              ),
            ),
          ),

          // ── My Location Button ──────────────────────────────────────────
          Positioned(
            bottom: selectedPing != null ? 120.h : 12.h,
            right: 12.w,
            child: MapIconButton(
              icon: Icons.my_location_rounded,
              onTap: () async {
                final ctrl = await _controller.future;
                ctrl.animateCamera(CameraUpdate.newLatLng(_initial.target));
              },
            ),
          ),

          // ── Selected Ping Mini Card ─────────────────────────────────────
          if (selectedPing != null)
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: SelectedPingCard(ping: selectedPing),
            ),

          // ── Zoom Controls ──────────────────────────────────────────
          Positioned(
            right: 12.w,
            bottom: selectedPing != null ? 200.h : 80.h,
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
    );
  }
}

import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_button.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider/location_provider.dart';

class LocationAccessScreen extends ConsumerWidget {
  const LocationAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    // Animate map when GPS position first loads
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.isLoaded && previous?.isLoaded != true) {
        ref
            .read(mapControllerProvider.notifier)
            .animateTo(next.position);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(),

          // Circular Google Map with moveable marker
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple rings
                _buildRipple(
                  size: 280.w,
                  color: AppColor.primary.withValues(alpha: 0.25),
                ),
                _buildRipple(
                  size: 220.w,
                  color: AppColor.primary.withValues(alpha: 0.45),
                ),

                // Circular Google Map
                ClipOval(
                  child: SizedBox(
                    height: 180.w,
                    width: 180.w,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: locationState.position,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        ref
                            .read(mapControllerProvider.notifier)
                            .setController(controller);
                        ref
                            .read(locationProvider.notifier)
                            .fetchLocation();
                      },

                      // Tap on map to move marker
                      onTap: (LatLng tappedPoint) {
                        ref
                            .read(locationProvider.notifier)
                            .updateSelectedPosition(tappedPoint);
                      },

                      // Update selected position when camera stops moving
                      onCameraIdle: () async {
                        final controller = ref.read(mapControllerProvider);
                        if (controller == null) return;
                        final visibleRegion =
                        await controller.getVisibleRegion();
                        final center = LatLng(
                          (visibleRegion.northeast.latitude +
                              visibleRegion.southwest.latitude) /
                              2,
                          (visibleRegion.northeast.longitude +
                              visibleRegion.southwest.longitude) /
                              2,
                        );
                        ref
                            .read(locationProvider.notifier)
                            .updateSelectedPosition(center);
                      },

                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: locationState.selectedPosition,
                          draggable: true,
                          onDragEnd: (LatLng newPosition) {
                            ref
                                .read(locationProvider.notifier)
                                .updateSelectedPosition(newPosition);
                          },
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        ),
                      },

                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      zoomGesturesEnabled: true,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: locationState.isLoaded,
                    ),
                  ),
                ),

                // Loading spinner
                if (locationState.isLoading)
                  CircularProgressIndicator(
                    color: AppColor.primary,
                    strokeWidth: 2,
                  ),

                // White border ring
                IgnorePointer(
                  child: Container(
                    height: 180.w,
                    width: 180.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(40.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "Allow Access",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(height: 12.h),

                if (locationState.isLoaded)
                  CustomText(
                    text:
                    "📍 ${locationState.selectedPosition.latitude.toStringAsFixed(5)}, "
                        "${locationState.selectedPosition.longitude.toStringAsFixed(5)}",
                    textAlign: TextAlign.center,
                    fontSize: 12.sp,
                    color: AppColor.primary,
                  ),

                SizedBox(height: 8.h),

                if (locationState.error != null)
                  CustomText(
                    text: locationState.error!,
                    textAlign: TextAlign.center,
                    fontSize: 13.sp,
                    color: Colors.redAccent,
                  )
                else
                  CustomText(
                    text:
                    "Service unavailable at your location. We'll notify you when access is enabled.",
                    textAlign: TextAlign.center,
                    fontSize: 14.sp,
                    color: AppColor.grey500,
                  ),

                SizedBox(height: 32.h),

                // GPS re-center button
                if (locationState.isLoaded)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(locationProvider.notifier)
                            .updateSelectedPosition(locationState.position);
                        ref
                            .read(mapControllerProvider.notifier)
                            .animateTo(locationState.position);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location,
                              color: AppColor.primary, size: 16.sp),
                          SizedBox(width: 6.w),
                          CustomText(
                            text: "Use my current location",
                            fontSize: 13.sp,
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                CustomButton(
                  text: "Done",
                  backgroundColor: AppColor.primary,
                  textColor: Colors.black,
                  borderRadius: 16.r,
                  onPressed: () {
                    context.pushReplacement('/roleSelectionScreen');
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/business_location_provider.dart';
import '../../provider/signup_provider.dart';
import '../widgets/location_search_bar.dart';
import '../widgets/suggestion_list.dart';

class BusinessLocationMapView extends ConsumerStatefulWidget {
  const BusinessLocationMapView({super.key});

  @override
  ConsumerState<BusinessLocationMapView> createState() =>
      _BusinessLocationMapViewState();
}

class _BusinessLocationMapViewState
    extends ConsumerState<BusinessLocationMapView> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _animateCameraTo(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(businessLocationProvider);
    final notifier = ref.read(businessLocationProvider.notifier);

    // Sync search text field when state.searchQuery changes externally
    if (_searchController.text != locationState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: locationState.searchQuery,
        selection: TextSelection.collapsed(
          offset: locationState.searchQuery.length,
        ),
      );
    }

    // Animate map when selectedLocation changes
    ref.listen(businessLocationProvider, (prev, next) {
      if (next.selectedLocation != null &&
          next.selectedLocation != prev?.selectedLocation) {
        _animateCameraTo(next.cameraPosition);
      }
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: locationState.cameraPosition,
                zoom: 13,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: notifier.onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: locationState.cameraPosition != const LatLng(0, 0)
                  ? {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: locationState.cameraPosition,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    }
                  : {},
            ),
          ),

          // ── Top overlay (back arrow + title + search) ────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),

                      // Back arrow
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Image.asset(
                          IconPath.arrowLeft,
                          height: 24.h,
                          width: 24.w,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Title
                      CustomText(
                        text: 'Choose Business Location',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                      ),

                      SizedBox(height: 16.h),

                      // Search bar
                      LocationSearchBar(
                        controller: _searchController,
                        focusNode: _focusNode,
                        isSearching: locationState.isSearching,
                        onChanged: notifier.onSearchChanged,
                        onClear: () {
                          notifier.clearSearch();
                          _focusNode.unfocus();
                        },
                      ),

                      // Suggestion list (inline, below search bar)
                      if (locationState.suggestions.isNotEmpty)
                        SuggestionList(
                          suggestions: locationState.suggestions,
                          onSelect: (s) {
                            notifier.selectSuggestion(s);
                            _focusNode.unfocus();
                          },
                        ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom confirm button ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected address preview
                  if (locationState.selectedLocation != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColor.primary, // adjust to your color
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: locationState.selectedLocation!.mainText,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              CustomText(
                                text: locationState
                                    .selectedLocation!
                                    .secondaryText,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: locationState.selectedLocation == null
                          ? null
                          : () {
                        // Capture the coordinates from the map's current state
                        final lat = locationState.cameraPosition.latitude;
                        final lng = locationState.cameraPosition.longitude;
                        final address = locationState.selectedLocation!.mainText;

                        // Update your Signup Notifier
                        ref.read(signupProvider.notifier).updateLocation(
                            lat: lat,
                            lng: lng,
                            address: address
                        );

                        context.push('/signupVerificationCodeScreen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        disabledBackgroundColor: AppColor.primary.withValues(alpha:
                          0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: CustomText(
                        text: 'Confirm Location',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}





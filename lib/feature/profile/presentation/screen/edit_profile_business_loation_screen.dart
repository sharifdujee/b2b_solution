import 'package:b2b_solution/feature/profile/provider/edit_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart'; // Add this
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_button.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../authentication/presentation/widgets/location_search_bar.dart';
import '../../../authentication/presentation/widgets/suggestion_list.dart';


class EditProfileBusinessLocationScreen extends ConsumerStatefulWidget {
  const EditProfileBusinessLocationScreen({super.key});

  @override
  ConsumerState<EditProfileBusinessLocationScreen> createState() => _BusinessLocationMapViewState();
}

class _BusinessLocationMapViewState extends ConsumerState<EditProfileBusinessLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(editProfileProvider);

      // FIX: Only jump to current GPS location if there is no previous selection
      // We check if latitude is null or 0.0 (default)
      if (currentState.latitude == null || currentState.latitude == 0.0) {
        _getCurrentLocation();
      } else {
        // Center camera on the existing business location
        _animateCameraTo(LatLng(currentState.latitude!, currentState.longitude!));
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);

    _animateCameraTo(latLng);
    ref.read(editProfileProvider.notifier).onMapTap(latLng);
  }

  void _animateCameraTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 16),
    ));
  }

  void _zoomIn() => _mapController?.animateCamera(CameraUpdate.zoomIn());
  void _zoomOut() => _mapController?.animateCamera(CameraUpdate.zoomOut());

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(editProfileProvider);
    final notifier = ref.read(editProfileProvider.notifier);

    if (_searchController.text != locationState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: locationState.searchQuery,
        selection: TextSelection.collapsed(offset: locationState.searchQuery.length),
      );
    }

    ref.listen(editProfileProvider, (prev, next) {
      if (next.cameraPosition != prev?.cameraPosition) {
        _animateCameraTo(next.cameraPosition);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    locationState.latitude ?? 0.0,
                      locationState.longitude ?? 0.0
                  ),
                  zoom: 15
              ),
              onMapCreated: (c) => _mapController = c,
              onTap: (latLng) {
                notifier.onMapTap(latLng);
                _focusNode.unfocus();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('pin'),
                  position: locationState.cameraPosition,
                  draggable: true,
                  onDragEnd: notifier.onMapTap,
                ),
              },
            ),
          ),

          // 2. Search Overlay
          _buildSearchOverlay(locationState, notifier),

          // 3. BACK BUTTON (Top Left - Floating Style)
          Positioned(
            top: 60.h,
            left: 16.w,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: Colors.black),
                ),
              ),
            ),
          ),

          // 4. Map Action Buttons
          Positioned(
            right: 16.w,
            bottom: locationState.selectedLocation != null ? 220.h : 140.h,
            child: Column(
              children: [
                _buildMapActionBtn(icon: Icons.add, onTap: _zoomIn),
                SizedBox(height: 8.h),
                _buildMapActionBtn(icon: Icons.remove, onTap: _zoomOut),
                SizedBox(height: 16.h),
                _buildMapActionBtn(
                  icon: Icons.my_location,
                  onTap: _getCurrentLocation,
                  color: AppColor.primary,
                ),
              ],
            ),
          ),

          // 5. Bottom Sheet Confirmation
          _buildBottomConfirmation(locationState),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSearchOverlay(locationState, notifier) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(left: 65.w, right: 20.w, bottom: 10.h), // Left padding avoids back button
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              LocationSearchBar(
                controller: _searchController,
                focusNode: _focusNode,
                isSearching: locationState.isSearching,
                onChanged: notifier.onSearchChanged,
                onClear: notifier.clearSearch,
              ),
              if (locationState.suggestions.isNotEmpty)
                SuggestionList(
                  suggestions: locationState.suggestions,
                  onSelect: (s) {
                    notifier.selectSuggestion(s);
                    _focusNode.unfocus();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapActionBtn({required IconData icon, required VoidCallback onTap, Color? color}) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onTap,
      backgroundColor: Colors.white,
      elevation: 4,
      child: Icon(icon, color: color ?? Colors.black87),
    );
  }

  Widget _buildBottomConfirmation(locationState) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColor.primary, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: locationState.selectedLocation?.mainText ?? "Pin Dropped",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        text: locationState.selectedLocation?.secondaryText ?? "Drag pin to adjust location",
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: "Confirm Location",
              backgroundColor: AppColor.primary,
              onPressed: () {
                // Determine the best address string to pass back
                final String finalAddress = (locationState.selectedLocation != null)
                    ? "${locationState.selectedLocation!.mainText}, ${locationState.selectedLocation!.secondaryText}"
                    : "Pinned Location (${locationState.cameraPosition.latitude.toStringAsFixed(4)})";

                ref.read(editProfileProvider.notifier).updateLocation(
                  lat: locationState.cameraPosition.latitude,
                  lng: locationState.cameraPosition.longitude,
                  address: finalAddress,
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
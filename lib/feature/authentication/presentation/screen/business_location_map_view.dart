import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart'; // Add this
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../provider/business_location_provider.dart';
import '../../provider/complete_profile_provider.dart';
import '../../provider/signup_provider.dart';
import '../widgets/location_search_bar.dart';
import '../widgets/suggestion_list.dart';

class BusinessLocationMapView extends ConsumerStatefulWidget {
  const BusinessLocationMapView({super.key});

  @override
  ConsumerState<BusinessLocationMapView> createState() => _BusinessLocationMapViewState();
}

class _BusinessLocationMapViewState extends ConsumerState<BusinessLocationMapView> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Move to current location automatically on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  // --- Logic for Current Location ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);

    _animateCameraTo(latLng);
    // Update the notifier state so it knows where we are
    ref.read(businessLocationProvider.notifier).onMapTap(latLng);
  }

  void _animateCameraTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 16), // Closer zoom for better accuracy
    ));
  }

  // --- Zoom Controls ---
  void _zoomIn() => _mapController?.animateCamera(CameraUpdate.zoomIn());
  void _zoomOut() => _mapController?.animateCamera(CameraUpdate.zoomOut());

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(businessLocationProvider);
    final notifier = ref.read(businessLocationProvider.notifier);

    // Sync search controller text
    if (_searchController.text != locationState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: locationState.searchQuery,
        selection: TextSelection.collapsed(offset: locationState.searchQuery.length),
      );
    }

    // Listen for state changes to animate camera (from search suggestions)
    ref.listen(businessLocationProvider, (prev, next) {
      if (next.cameraPosition != prev?.cameraPosition) {
        _animateCameraTo(next.cameraPosition);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: locationState.cameraPosition, zoom: 13),
              onMapCreated: (c) => _mapController = c,
              onTap: (latLng) {
                notifier.onMapTap(latLng); // User can select ANY location
                _focusNode.unfocus();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Custom button used below
              zoomControlsEnabled: false,    // Custom buttons used below
              markers: {
                Marker(
                  markerId: const MarkerId('pin'),
                  position: locationState.cameraPosition,
                  draggable: true,
                  onDragEnd: notifier.onMapTap, // Update state when dragged
                ),
              },
            ),
          ),

          // 2. Search Area (Top)
          _buildSearchOverlay(locationState, notifier),

          // 3. Zoom & My Location Buttons (Right Side)
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

          // 4. Confirmation Bottom Sheet
          _buildBottomConfirmation(locationState),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(locationState, notifier) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapActionBtn({required IconData icon, required VoidCallback onTap, Color? color}) {
    return FloatingActionButton.small(
      heroTag: null, // Avoid hero animation conflicts
      onPressed: onTap,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color ?? Colors.black87),
    );
  }

  Widget _buildBottomConfirmation(locationState) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColor.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: locationState.selectedLocation?.mainText ?? "Custom Location",
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        text: locationState.selectedLocation?.secondaryText ?? "Selected on map",
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity, height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final String finalAddress = locationState.selectedLocation != null
                      ? "${locationState.selectedLocation!.mainText}, ${locationState.selectedLocation!.secondaryText}"
                      : "Selected Location (${locationState.cameraPosition.latitude.toStringAsFixed(4)})";

                  ref.read(signupProvider.notifier).updateLocation(
                    lat: locationState.cameraPosition.latitude,
                    lng: locationState.cameraPosition.longitude,
                    address: finalAddress,
                  );
                  final double lat = locationState.cameraPosition.latitude;
                  final double lng = locationState.cameraPosition.longitude;
                  ref.read(completeProfileProvider.notifier).updateLocation(
                    lat: lat,
                    lng: lng,
                    address: finalAddress,
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
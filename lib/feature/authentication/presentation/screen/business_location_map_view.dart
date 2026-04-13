import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../provider/business_location_provider.dart';
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



  void _animateCameraTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(businessLocationProvider);
    final notifier = ref.read(businessLocationProvider.notifier);

    if (_searchController.text != locationState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: locationState.searchQuery,
        selection: TextSelection.collapsed(offset: locationState.searchQuery.length),
      );
    }

    ref.listen(businessLocationProvider, (prev, next) {
      if (next.cameraPosition != prev?.cameraPosition) {
        _animateCameraTo(next.cameraPosition);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: locationState.cameraPosition, zoom: 13),
              onMapCreated: (c) => _mapController = c,
              onTap: notifier.onMapTap,
              markers: {
                Marker(markerId: const MarkerId('pin'), position: locationState.cameraPosition),
              },
            ),
          ),

          Positioned(
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
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locationState.selectedLocation != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColor.primary),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text: locationState.selectedLocation!.mainText, fontWeight: FontWeight.bold),
                              CustomText(text: locationState.selectedLocation!.secondaryText, fontSize: 12.sp, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                  SizedBox(
                    width: double.infinity, height: 50.h,
                    child: ElevatedButton(
                      onPressed: locationState.selectedLocation == null ? null : () {
                        ref.read(signupProvider.notifier).updateLocation(
                          lat: locationState.cameraPosition.latitude,
                          lng: locationState.cameraPosition.longitude,
                          address: "${locationState.selectedLocation!.mainText}, ${locationState.selectedLocation!.secondaryText}",
                        );
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                      child: const Text("Confirm Location", style: TextStyle(color: Colors.white)),
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
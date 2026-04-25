import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/service/map_service.dart';
import '../../../authentication/models/location_suggestion_data_model.dart';
import '../../provider/current_position_provider.dart';
import '../../provider/filter_provider.dart';
import '../../provider/my_connection_filter_provider.dart';
import '../widget/filter_bottom_sheet.dart';
import '../widget/map_search_section.dart';
import '../../../../feature/home/presentation/widget/top_section.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});
  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSuggestions = false;

  void _onSearchChanged(String value) {
    // Logic to toggle suggestions visibility
    if (value.length >= 2 && !_showSuggestions) {
      setState(() => _showSuggestions = true);
    } else if (value.length < 2 && _showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  Future<void> _selectSuggestion(LocationSuggestion s) async {
    _searchController.text = s.mainText;
    _searchFocus.unfocus();
    setState(() => _showSuggestions = false);

    // Use MapService to get coordinates from placeId
    final mapService = ref.read(mapServiceProvider);
    final LatLng? destination = await mapService.getLatLngFromPlaceId(s.placeId);

    if (destination != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: destination, zoom: 15, tilt: 45),
        ),
      );
      // Update global filter location
      ref.read(filterProvider.notifier).setSearchLocation(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceLocationAsync = ref.watch(currentPositionProvider);
    final connectionState = ref.watch(myConnectionListProvider);
    final mapService = ref.read(mapServiceProvider);

    // 1. Generate Business Markers from Discover Items
    final Set<Marker> businessMarkers = connectionState.discoverItems.map((user) {
      return Marker(
        markerId: MarkerId(user.id),
        position: LatLng(user.businessLatitude, user.businessLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: user.businessName,
          snippet: "Tap to see address",
          onTap: () async {
            final address = await mapService.getAddressFromLatLng(
              LatLng(user.businessLatitude, user.businessLongitude),
            );
            if (context.mounted && address != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${user.businessName}: ${address.secondaryText}"),
                  backgroundColor: AppColor.primary,
                ),
              );
            }
          },
        ),
      );
    }).toSet();

    // 2. Combine with Device Location Marker
    final Set<Marker> allMarkers = {
      ...businessMarkers,
      if (deviceLocationAsync.hasValue)
        Marker(
          markerId: const MarkerId('device_location_marker'),
          position: deviceLocationAsync.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "You are here"),
          zIndex: 10,
        ),
    };

    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // MAP LAYER
          deviceLocationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => const Center(child: Text("Location Error")),
            data: (deviceLatLng) => GoogleMap(
              initialCameraPosition: CameraPosition(target: deviceLatLng, zoom: 12),
              markers: allMarkers,
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              padding: EdgeInsets.only(top: 250.h),
            ),
          ),

          // HEADER & SEARCH LAYER
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 48.h, bottom: 16.h),
              decoration: _headerDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const TopSection(),
                  SizedBox(height: 12.h),
                  MapSearchSection(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    onFilterTap: _openFilterSheet,
                    onClear: () {
                      _searchController.clear();
                      setState(() => _showSuggestions = false);
                    },
                  ),
                ],
              ),
            ),
          ),

          // SUGGESTIONS OVERLAY
          if (_showSuggestions)
            Positioned(
              top: 210.h, left: 16.w, right: 16.w,
              child: SuggestionList(onSelect: _selectSuggestion),
            ),
        ],
      ),
    );
  }

  BoxDecoration _headerDecoration() {
    return BoxDecoration(
      color: AppColor.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      boxShadow: [
        BoxShadow(color: AppColor.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColor.black),
          ),
          CustomText(text: "Nearby Pings", fontSize: 18.sp, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}

class SuggestionList extends ConsumerWidget {
  // Ensure this uses the correct model from your MapService
  final ValueChanged<LocationSuggestion> onSelect;
  const SuggestionList({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider must return List<LocationSuggestion>
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);

    return suggestionsAsync.when(
      loading: () => _buildContainer(
        child: const Center(
          child: LinearProgressIndicator(minHeight: 2, color: AppColor.primary),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return _buildContainer(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 50.w,
            ),
            itemBuilder: (_, i) {
              // Now 's' is guaranteed to be a LocationSuggestion
              final s = suggestions[i];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                leading: CircleAvatar(
                  backgroundColor: AppColor.primary.withOpacity(0.1),
                  child: Icon(Icons.location_on, color: AppColor.primary, size: 18.sp),
                ),
                title: Text(
                  s.mainText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  s.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                onTap: () => onSelect(s),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      constraints: BoxConstraints(maxHeight: 300.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16.r), child: child),
    );
  }
}
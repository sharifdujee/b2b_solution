import 'package:b2b_solution/feature/home/presentation/widget/top_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../profile/provider/profile_provider.dart';
import '../../data/place_location.dart';
import '../../provider/current_position_provider.dart';
import '../../provider/filter_provider.dart';
import '../widget/filter_bottom_sheet.dart';
import '../widget/map_search_section.dart';

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
    ref.read(searchQueryProvider.notifier).state = value;
    if (value.length >= 2 && !_showSuggestions) {
      setState(() => _showSuggestions = true);
    } else if (value.length < 2 && _showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  void _openFilterSheet() {
    final current = ref.read(filterProvider);
    ref.read(pendingFilterProvider.notifier).state = FilterState(
      selectedCategory: current.selectedCategory,
      selectedRadius: current.selectedRadius,
      searchLocation: current.searchLocation,
    );

    // 3. Show the sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const FilterBottomSheet(),
    );
  }

  Future<void> _selectSuggestion(SearchSuggestion s) async {
    _searchController.text = s.mainText;
    _searchFocus.unfocus();
    setState(() => _showSuggestions = false);

    const apiKey = "AIzaSyDCp_EGIWaoVYOeML3Kl8YiPN1az3hV9WA";
    final url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=${s.placeId}&fields=geometry&key=$apiKey";

    final response = await ref.read(networkCallerProvider).getRequest(url);
    if (response.isSuccess && response.responseData != null) {
      final loc = response.responseData['result']['geometry']['location'];
      final destination = LatLng(loc['lat'], loc['lng']);

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: destination, zoom: 15, tilt: 45),
        ),
      );

      ref.read(filterProvider.notifier).setSearchLocation(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(filteredPlacesProvider);
    final profile = ref.watch(profileProvider);

    final markersFromProvider = ref.watch(mapMarkersProvider);
    final deviceLocationAsync = ref.watch(currentPositionProvider);

    final Set<Marker> allMarkers = {
      ...markersFromProvider,
      if (deviceLocationAsync.hasValue)
        Marker(
          markerId: const MarkerId('device_location_marker'),
          position: deviceLocationAsync.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "My Current Location"),
          zIndex: 10, // Keep user marker on top
        ),
    };

    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FULL SCREEN MAP
          deviceLocationAsync.when(
            error: (err, stack) => const Center(child: Text("Location Error")),
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (deviceLatLng) => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: deviceLatLng,
                zoom: 12,
              ),
              markers: allMarkers,
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              padding: EdgeInsets.only(top: 250.h),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 48.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
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
                      ref.read(searchQueryProvider.notifier).state = '';
                      setState(() => _showSuggestions = false);
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 210.h,
            left: 16.w,
            right: 16.w,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _showSuggestions
                  ? SuggestionList(key: const ValueKey('suggestions'), onSelect: _selectSuggestion)
                  : const SizedBox.shrink(),
            ),
          ),

          if (placesAsync.isLoading)
            const Positioned(
              top: 230,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  shape: CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
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
  final ValueChanged<SearchSuggestion> onSelect;
  const SuggestionList({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);

    return suggestionsAsync.when(
      loading: () => _buildContainer(
        child: const Center(child: LinearProgressIndicator(minHeight: 2)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return _buildContainer(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100, indent: 50.w),
            itemBuilder: (_, i) {
              final s = suggestions[i];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                leading: CircleAvatar(
                  backgroundColor: AppColor.primary.withOpacity(0.1),
                  child: Icon(Icons.location_on, color: AppColor.primary, size: 18.sp),
                ),
                title: Text(s.mainText, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                subtitle: Text(s.secondaryText, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16.r), child: child),
    );
  }
}
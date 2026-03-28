import 'package:b2b_solution/feature/home/presentation/widget/top_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/design_system/app_color.dart';
import '../../../../core/gloabal/custom_text.dart';
import '../../../../core/utils/local_assets/icon_path.dart';
import '../../data/place_location.dart';
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

  static const LatLng _dhaka = LatLng(23.7808, 90.4093);

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(
        () => _showSuggestions =
            _searchFocus.hasFocus && _searchController.text.length >= 2,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    setState(() => _showSuggestions = value.length >= 2);
  }

  void _selectSuggestion(SearchSuggestion s) {
    _searchController.text = s.mainText;
    ref.read(searchQueryProvider.notifier).state = s.mainText;
    _searchFocus.unfocus();
    setState(() => _showSuggestions = false);
    // In production: geocode placeId and animate camera
  }

  void _openFilterSheet() {
    // Seed pending filter with current applied filter
    final current = ref.read(filterProvider);
    ref.read(pendingFilterProvider.notifier).state = FilterState(
      selectedCategory: current.selectedCategory,
      selectedRadius: current.selectedRadius,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(mapMarkersProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w,)),
                  ),
                  SizedBox(width: 10.w),
                  CustomText(
                    text: "Map View",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  )
                ],
              ),
              SizedBox(height: 12.h),

              TopSection(),
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

          if (_showSuggestions)
            SuggestionList(onSelect: _selectSuggestion),

          SizedBox(height: 8.h),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _dhaka,
                zoom: 13,
              ),
              markers: markers,
              onMapCreated: (c) => _mapController = c,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
              },
            ),
          ),
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
    final suggestions = ref.watch(searchSuggestionsProvider);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColor.grey300, indent: 48.w),
        itemBuilder: (_, i) {
          final s = suggestions[i];
          return ListTile(
            dense: true,
            leading: Container(
              width: 32.w,
              height: 32.h,
              decoration: const BoxDecoration(
                color: AppColor.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: AppColor.grey500,
              ),
            ),
            title: Text(
              s.mainText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),
            subtitle: Text(
              s.secondaryText,
              style: TextStyle(fontSize: 11.sp, color: AppColor.grey500),
            ),
            onTap: () => onSelect(s),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/place_location.dart';
import '../../provider/filter_provider.dart';




class AppColor {
  static const white       = Color(0xFFFFFFFF);
  static const black       = Color(0xFF1A1A1A);
  static const primary     = Color(0xFF8BC34A); // green (from screenshots)
  static const accent      = Color(0xFFF5C518); // yellow apply button
  static const grey100     = Color(0xFFF5F5F5);
  static const grey300     = Color(0xFFE0E0E0);
  static const grey500     = Color(0xFF9E9E9E);
  static const chipBorder  = Color(0xFFD0D0D0);
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

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
      setState(() => _showSuggestions = _searchFocus.hasFocus &&
          _searchController.text.length >= 2);
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
    ref.read(pendingFilterProvider.notifier).state =
        FilterState(
          selectedCategory: current.selectedCategory,
          selectedRadius:   current.selectedRadius,
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(mapMarkersProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          // ── MAP ──────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition:
              const CameraPosition(target: _dhaka, zoom: 13),
              markers: markers,
              onMapCreated: (c) => _mapController = c,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // ── TOP SECTION ──────────────────────────────
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12.h),
                _SearchBar(
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
                if (_showSuggestions) _SuggestionList(onSelect: _selectSuggestion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH BAR WIDGET
// ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: TextStyle(fontSize: 14.sp, color: AppColor.black),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                  TextStyle(color: AppColor.grey500, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.grey500, size: 20.sp),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close,
                        color: AppColor.grey500, size: 18.sp),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColor.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(Icons.tune_rounded,
                  color: AppColor.black, size: 22.sp),
            ),
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUGGESTION LIST
// ─────────────────────────────────────────────

class _SuggestionList extends ConsumerWidget {
  final ValueChanged<SearchSuggestion> onSelect;

  const _SuggestionList({required this.onSelect});

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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
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
                  color: AppColor.grey100, shape: BoxShape.circle),
              child: Icon(Icons.location_on_outlined,
                  size: 16.sp, color: AppColor.grey500),
            ),
            title: Text(s.mainText,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black)),
            subtitle: Text(s.secondaryText,
                style:
                TextStyle(fontSize: 11.sp, color: AppColor.grey500)),
            onTap: () => onSelect(s),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER BOTTOM SHEET
// ─────────────────────────────────────────────

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingFilterProvider);
    final notifier = ref.read(pendingFilterProvider.notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Center(
            child: Text('Filter By',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.black)),
          ),
          SizedBox(height: 24.h),

          // ── Category ─────────────────────────────
          Text('Category',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: FoodCategory.values.map((cat) {
              final selected = pending.selectedCategory == cat;
              return _FilterChip(
                label: cat.label,
                selected: selected,
                onTap: () => notifier.setCategory(cat),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // ── Radius ───────────────────────────────
          Text('Radius',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: RadiusOption.values.map((r) {
              final selected = pending.selectedRadius == r;
              return _FilterChip(
                label: r.label,
                selected: selected,
                onTap: () => notifier.setRadius(r),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),

          // ── Apply Button ─────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                // Apply pending filter → live filter
                ref.read(filterProvider.notifier).state = FilterState(
                  selectedCategory: pending.selectedCategory,
                  selectedRadius:   pending.selectedRadius,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.accent,
                foregroundColor: AppColor.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text('Apply',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE FILTER CHIP
// ─────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.chipBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColor.white : AppColor.black,
          ),
        ),
      ),
    );
  }
}
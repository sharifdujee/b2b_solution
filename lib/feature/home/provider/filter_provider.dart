import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../../../core/service/map_service.dart'; // Import MapService
import '../../profile/provider/profile_provider.dart';
import '../data/place_location.dart';
import '../../authentication/models/location_suggestion_data_model.dart';

// --- State Model ---
class FilterState {
  final FoodCategory? selectedCategory;
  final RadiusOption? selectedRadius;
  final LatLng? searchLocation;

  const FilterState({this.selectedCategory, this.selectedRadius, this.searchLocation});

  FilterState copyWith({
    FoodCategory? selectedCategory,
    RadiusOption? selectedRadius,
    LatLng? searchLocation,
    bool clearCategory = false,
    bool clearRadius = false,
  }) => FilterState(
    selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    selectedRadius: clearRadius ? null : (selectedRadius ?? this.selectedRadius),
    searchLocation: searchLocation ?? this.searchLocation,
  );
}

// --- Notifier ---
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setCategory(FoodCategory cat) {
    state = state.selectedCategory == cat
        ? state.copyWith(clearCategory: true)
        : state.copyWith(selectedCategory: cat);
  }

  void setRadius(RadiusOption rad) {
    state = state.selectedRadius == rad
        ? state.copyWith(clearRadius: true)
        : state.copyWith(selectedRadius: rad);
  }

  void setSearchLocation(LatLng loc) => state = state.copyWith(searchLocation: loc);
  void clearFilters() => state = const FilterState();
}

// --- Providers ---
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) => FilterNotifier());
final pendingFilterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) => FilterNotifier());
final searchQueryProvider = StateProvider<String>((ref) => '');
final networkCallerProvider = Provider((ref) => NetworkCaller());

// 2. GOOGLE SEARCH SUGGESTIONS (Updated to use MapService)
final searchSuggestionsProvider = FutureProvider<List<LocationSuggestion>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) return [];

  // Use the map service instead of manual HTTP requests
  final mapService = ref.read(mapServiceProvider);
  return await mapService.fetchSuggestions(query);
});

// 3. FETCH PINGS (YOUR BACKEND)
final filteredPlacesProvider = FutureProvider<List<PlaceLocation>>((ref) async {
  final filter = ref.watch(filterProvider);
  final profile = ref.watch(profileProvider);

  final double lat = filter.searchLocation?.latitude ?? profile.latitude ?? 0.0;
  final double lng = filter.searchLocation?.longitude ?? profile.longitude ?? 0.0;

  String url;
  if (filter.selectedRadius != null && filter.selectedCategory != null) {
    url = AppUrl.pingFilterByRadiusAndCategory(filter.selectedRadius!.value, filter.selectedCategory!.name);
  } else if (filter.selectedRadius != null) {
    url = AppUrl.pingFilterByRadius(filter.selectedRadius!.value);
  } else if (filter.selectedCategory != null) {
    url = AppUrl.pingFilterByCategory(filter.selectedCategory!.name);
  } else {
    url = AppUrl.nearbyPings(lat, lng);
  }

  final response = await ref.read(networkCallerProvider).getRequest(url, token: AuthService.token);
  if (response.isSuccess && response.responseData != null) {
    final result = response.responseData['result'];
    if (result != null && result['data'] is List) {
      return (result['data'] as List).map((j) {
        try {
          return PlaceLocation.fromJson(j);
        } catch (e) {
          log("Error parsing individual item: $e");
          return null;
        }
      }).whereType<PlaceLocation>().toList();
    }
  }
  return [];
});

// 4. MAP MARKERS
final mapMarkersProvider = Provider<Set<Marker>>((ref) {
  final places = ref.watch(filteredPlacesProvider).value ?? [];
  return places.map((p) => Marker(
    markerId: MarkerId(p.id),
    position: p.position,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    infoWindow: InfoWindow(title: p.name, snippet: p.address),
  )).toSet();
});
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_suggestion_data_model.dart';
import 'state/business_location_state.dart';

class BusinessLocationNotifier extends StateNotifier<BusinessLocationState> {
  BusinessLocationNotifier() : super(const BusinessLocationState());

  Timer? _debounce;

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query, clearSelected: true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query.trim());
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    // API Implementation Tip: Use Google Places Autocomplete API here
    await Future.delayed(const Duration(milliseconds: 300));

    final mock = [
      LocationSuggestion(
        placeId: '1',
        mainText: '$query Street',
        secondaryText: 'London, UK',
        latLng: const LatLng(51.5074, -0.1278),
      ),
      // ... add more mock or real data
    ];

    if (mounted) {
      state = state.copyWith(suggestions: mock, isSearching: false);
    }
  }

  void selectSuggestion(LocationSuggestion suggestion) {
    // If suggestion doesn't have LatLng, you'd call Place Details API here
    final latLng = suggestion.latLng ?? state.cameraPosition;

    state = state.copyWith(
      selectedLocation: suggestion,
      suggestions: [],
      cameraPosition: latLng,
      searchQuery: '${suggestion.mainText}, ${suggestion.secondaryText}',
      isSearching: false,
    );
  }

  /// When user taps the map, we update the position and "Reverse Geocode"
  Future<void> onMapTap(LatLng position) async {
    state = state.copyWith(
      cameraPosition: position,
      isSearching: true,
    );

    // Mock Reverse Geocoding (Getting address from Lat/Lng)
    // Real implementation: Use geocoding package or Google Geocoding API
    await Future.delayed(const Duration(milliseconds: 500));

    final tappedLocation = LocationSuggestion(
      placeId: 'manual',
      mainText: 'Pinned Location',
      secondaryText: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      latLng: position,
    );

    state = state.copyWith(
      selectedLocation: tappedLocation,
      isSearching: false,
      suggestions: [],
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      suggestions: [],
      searchQuery: '',
      isSearching: false,
    );
  }
}

final businessLocationProvider =
StateNotifierProvider.autoDispose<BusinessLocationNotifier, BusinessLocationState>(
      (ref) => BusinessLocationNotifier(),
);
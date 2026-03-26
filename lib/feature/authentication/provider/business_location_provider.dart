

import 'dart:async';

import 'package:b2b_solution/feature/authentication/provider/state/business_location_state.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_suggestion_data_model.dart';

class BusinessLocationNotifier extends StateNotifier<BusinessLocationState> {
  BusinessLocationNotifier() : super(const BusinessLocationState());

  Timer? _debounce;

  /// Call this when the search field changes.
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

  /// Replace with your actual Places Autocomplete API call.
  Future<void> _fetchSuggestions(String query) async {
    // TODO: integrate google_places_flutter / dio + Places API
    // Example mock — remove when wiring real API:
    await Future.delayed(const Duration(milliseconds: 300));

    final mock = [
      LocationSuggestion(
        placeId: '1',
        mainText: '$query Street',
        secondaryText: 'San Francisco, CA, USA',
        latLng: const LatLng(37.7749, -122.4194),
      ),
      LocationSuggestion(
        placeId: '2',
        mainText: '$query Avenue',
        secondaryText: 'Oakland, CA, USA',
        latLng: const LatLng(37.8044, -122.2712),
      ),
      LocationSuggestion(
        placeId: '3',
        mainText: '$query Boulevard',
        secondaryText: 'San Jose, CA, USA',
        latLng: const LatLng(37.3382, -121.8863),
      ),
    ];

    if (mounted) {
      state = state.copyWith(suggestions: mock, isSearching: false);
    }
  }

  /// Called when the user taps a suggestion.
  void selectSuggestion(LocationSuggestion suggestion) {
    // TODO: fetch precise LatLng via Places Details API if suggestion.latLng == null
    final latLng = suggestion.latLng ?? state.cameraPosition;

    state = state.copyWith(
      selectedLocation: suggestion,
      suggestions: [],
      cameraPosition: latLng,
      searchQuery: '${suggestion.mainText}, ${suggestion.secondaryText}',
      isSearching: false,
    );
  }

  /// Called when the user drags the map pin manually.
  void onMapTap(LatLng position) {
    state = state.copyWith(
      cameraPosition: position,
      clearSelected: true,
      suggestions: [],
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      suggestions: [],
      searchQuery: '',
      clearSelected: true,
      isSearching: false,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// PROVIDERS
// ---------------------------------------------------------------------------

final businessLocationProvider =
StateNotifierProvider.autoDispose<BusinessLocationNotifier, BusinessLocationState>(
      (ref) => BusinessLocationNotifier(),
);
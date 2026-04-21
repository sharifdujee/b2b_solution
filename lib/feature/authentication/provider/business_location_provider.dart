import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/service/map_service.dart';
import '../models/location_suggestion_data_model.dart';
import 'state/business_location_state.dart';

class BusinessLocationNotifier extends StateNotifier<BusinessLocationState> {
  final MapService _mapService;
  Timer? _debounce;

  BusinessLocationNotifier(this._mapService) : super(const BusinessLocationState());

  /// Logic to handle typing in the search bar
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await _mapService.fetchSuggestions(query.trim());
      state = state.copyWith(suggestions: results, isSearching: false);
    });
  }

  /// Logic when a user clicks an item from the search results
  Future<void> selectSuggestion(LocationSuggestion suggestion) async {
    state = state.copyWith(isSearching: true, suggestions: []);

    final latLng = await _mapService.getPlaceDetails(suggestion.placeId);

    if (latLng != null) {
      state = state.copyWith(
        selectedLocation: suggestion.copyWith(latLng: latLng),
        cameraPosition: latLng,
        searchQuery: '${suggestion.mainText}, ${suggestion.secondaryText}',
        isSearching: false,
      );
    } else {
      state = state.copyWith(isSearching: false);
    }
  }

  /// Logic when the user taps directly on the map
  Future<void> onMapTap(LatLng position) async {
    state = state.copyWith(cameraPosition: position, isSearching: true);

    final suggestion = await _mapService.getAddressFromLatLng(position);

    if (suggestion != null) {
      state = state.copyWith(
        selectedLocation: suggestion,
        isSearching: false,
      );
    } else {
      state = state.copyWith(isSearching: false);
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(suggestions: [], searchQuery: '', isSearching: false);
  }
}

/// Updated Provider to inject MapService
final businessLocationProvider =
StateNotifierProvider.autoDispose<BusinessLocationNotifier, BusinessLocationState>(
      (ref) {
    final mapService = ref.watch(mapServiceProvider);
    return BusinessLocationNotifier(mapService);
  },
);
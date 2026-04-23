import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/location_suggestion_data_model.dart';

class BusinessLocationState {
  final List<LocationSuggestion> suggestions;
  final LocationSuggestion? selectedLocation;
  final bool isSearching;
  final LatLng cameraPosition;
  final String searchQuery;

  const BusinessLocationState({
    this.suggestions = const [],
    this.selectedLocation,
    this.isSearching = false,
    this.cameraPosition = const LatLng(37.7749, -122.4194),
    this.searchQuery = '',
  });

  BusinessLocationState copyWith({
    List<LocationSuggestion>? suggestions,
    LocationSuggestion? selectedLocation,
    bool? isSearching,
    LatLng? cameraPosition,
    String? searchQuery,
    bool clearSuggestions = false,
    bool clearSelectedLocation = false, // Added for flexibility
  }) {
    return BusinessLocationState(
      suggestions: clearSuggestions ? const [] : (suggestions ?? this.suggestions),
      selectedLocation: clearSelectedLocation ? null : (selectedLocation ?? this.selectedLocation),
      isSearching: isSearching ?? this.isSearching,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
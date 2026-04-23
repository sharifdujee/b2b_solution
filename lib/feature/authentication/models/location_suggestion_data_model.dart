import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final LatLng? latLng;

  const LocationSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.latLng,
  });

  LocationSuggestion copyWith({
    String? placeId,
    String? mainText,
    String? secondaryText,
    LatLng? latLng,
  }) {
    return LocationSuggestion(
      placeId: placeId ?? this.placeId,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      latLng: latLng ?? this.latLng,
    );
  }
}
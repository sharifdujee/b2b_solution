

import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final LatLng? latLng; // populated after place-detail fetch

  const LocationSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.latLng,
  });
}
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../feature/authentication/models/location_suggestion_data_model.dart';

class MapService {
  // Note: For security, consider moving this to an .env file or build-time variable
  final String _apiKey = "AIzaSyAjgv_3-qgSx_5NZxGY1m_ohyag3SKU0TM";

  /// Fetches a list of address suggestions based on user input.
  /// Used by the search bar to show the dropdown list.
  Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': query,
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List predictions = data['predictions'] ?? [];
          return predictions.map((p) {
            final format = p['structured_formatting'];
            return LocationSuggestion(
              placeId: p['place_id'],
              mainText: format?['main_text'] ?? '',
              secondaryText: format?['secondary_text'] ?? '',
            );
          }).toList();
        } else {
          log("MapService Error Status: ${data['status']} - ${data['error_message']}");
        }
      }
    } catch (e) {
      log("MapService [fetchSuggestions] Exception: $e");
    }
    return [];
  }

  /// Alias for fetchSuggestions to maintain compatibility with EditProfileNotifier
  Future<List<LocationSuggestion>> getPlaceSuggestions(String query) async {
    return await fetchSuggestions(query);
  }

  /// Converts a Google Place ID into actual LatLng coordinates.
  /// Necessary for moving the map camera when a suggestion is selected.
  Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'geometry',
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final loc = data['result']?['geometry']?['location'];
          if (loc != null) return LatLng(loc['lat'], loc['lng']);
        }
      }
    } catch (e) {
      log("MapService [getLatLngFromPlaceId] Error: $e");
    }
    return null;
  }

  /// Alias for getLatLngFromPlaceId
  Future<LatLng?> getPlaceDetails(String placeId) async {
    return await getLatLngFromPlaceId(placeId);
  }

  /// Specialized method to get a "normal" address for a Discovered User
  Future<String> getBusinessAddress(double lat, double lng) async {
    final location = await getAddressFromLatLng(LatLng(lat, lng));
    // Returns the clean "Secondary Text" which we filtered to avoid Plus Codes
    return location?.secondaryText ?? "Address not found";
  }

  /// Performs Reverse Geocoding: takes coordinates and returns a readable address.
  /// Used when the user manually taps or drags a pin on the map.
  Future<LocationSuggestion?> getAddressFromLatLng(LatLng position) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${position.latitude},${position.longitude}',
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {

          final results = data['results'] as List;

          var bestResult = results.firstWhere(
                (res) => !(res['types'] as List).contains('plus_code'),
            orElse: () => results[0],
          );

          return LocationSuggestion(
            placeId: bestResult['place_id'],
            mainText: "Pinned Location",
            secondaryText: bestResult['formatted_address'],
            latLng: position,
          );
        }
      }
    } catch (e) {
      log("MapService [getAddressFromLatLng] Error: $e");
    }
    return null;
  }
}

final mapServiceProvider = Provider<MapService>((ref) => MapService());

void log(String message) {
  print("[MapService] $message");
}
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../feature/authentication/models/location_suggestion_data_model.dart';

class MapService {
  final String _apiKey = "AIzaSyAjgv_3-qgSx_5NZxGY1m_ohyag3SKU0TM";

  Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    // Safe way to build URIs with query parameters
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
          print("MapService Error Status: ${data['status']} - ${data['error_message']}");
        }
      }
    } catch (e) {
      print("MapService [fetchSuggestions] Exception: $e");
    }
    return [];
  }

  Future<LatLng?> getPlaceDetails(String placeId) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'geometry',
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final loc = data['result']?['geometry']?['location'];
        if (loc != null) return LatLng(loc['lat'], loc['lng']);
      }
    } catch (e) {
      print("MapService [getPlaceDetails] Error: $e");
    }
    return null;
  }

  Future<LocationSuggestion?> getAddressFromLatLng(LatLng position) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${position.latitude},${position.longitude}',
      'key': _apiKey,
    });

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
        final result = data['results'][0];
        return LocationSuggestion(
          placeId: result['place_id'],
          mainText: "Pinned Location",
          secondaryText: result['formatted_address'],
          latLng: position,
        );
      }
    } catch (e) {
      print("MapService [getAddressFromLatLng] Error: $e");
    }
    return null;
  }
}

final mapServiceProvider = Provider<MapService>((ref) => MapService());


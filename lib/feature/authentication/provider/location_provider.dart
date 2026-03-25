// lib/features/location_access/providers/location_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {
  final LatLng position;
  final LatLng selectedPosition; // user-picked location
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  const LocationState({
    this.position = const LatLng(23.8103, 90.4125),
    this.selectedPosition = const LatLng(23.8103, 90.4125),
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
  });

  LocationState copyWith({
    LatLng? position,
    LatLng? selectedPosition,
    bool? isLoading,
    bool? isLoaded,
    String? error,
  }) {
    return LocationState(
      position: position ?? this.position,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  Future<void> fetchLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permission denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission permanently denied.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      state = state.copyWith(
        position: latLng,
        selectedPosition: latLng, // sync selected to GPS on first load
        isLoading: false,
        isLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Called when user drags marker or taps map
  void updateSelectedPosition(LatLng newPosition) {
    state = state.copyWith(selectedPosition: newPosition);
  }
}


class MapControllerNotifier extends StateNotifier<GoogleMapController?> {
  MapControllerNotifier() : super(null);

  void setController(GoogleMapController controller) {
    state = controller;
  }

  void animateTo(LatLng position, {double zoom = 15}) {
    state?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final mapControllerProvider =
StateNotifierProvider<MapControllerNotifier, GoogleMapController?>(
      (ref) => MapControllerNotifier(),
);

final locationProvider =
StateNotifierProvider<LocationNotifier, LocationState>(
      (ref) => LocationNotifier(),
);
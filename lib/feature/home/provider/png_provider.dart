import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../provider/nearby_ping_provider.dart';
import 'map_filter_provider.dart'; // Ensure this is imported

class PingMapState {
  final String? selectedPingId;
  const PingMapState({this.selectedPingId});

  PingMapState copyWith({String? selectedPingId, bool clearSelected = false}) =>
      PingMapState(
        selectedPingId: clearSelected ? null : (selectedPingId ?? this.selectedPingId),
      );
}

class PingMapNotifier extends StateNotifier<PingMapState> {
  PingMapNotifier() : super(const PingMapState());

  void selectPing(String id) {
    state = state.copyWith(selectedPingId: id);
  }

  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final pingMapProvider = StateNotifierProvider<PingMapNotifier, PingMapState>(
      (ref) => PingMapNotifier(),
);

final pingMarkersProvider = Provider<Set<Marker>>((ref) {
  final pingState = ref.watch(nearbyPingProvider);
  final selectedId = ref.watch(pingMapProvider).selectedPingId;

  final activeFilter = ref.watch(mapFilterProvider);

  final filteredPings = pingState.pings.where((p) {
    final bool isWithinRadius = p.distanceKm <= 20;
    final bool isEmergency = p.urgencyLevel.toUpperCase() == 'EMERGENCY';

    if (activeFilter == MapFilterType.EMERGENCY) {
      return isWithinRadius && isEmergency;
    } else {
      return isWithinRadius && !isEmergency;
    }
  }).toList();

  final Set<Marker> markers = {};

  for (int i = 0; i < filteredPings.length; i++) {
    final ping = filteredPings[i];
    double lat = ping.user?.businessLatitude ?? 0.0;
    double lng = ping.user?.businessLongitude ?? 0.0;
    final bool isSelected = ping.id == selectedId;

    // Slight offset for overlapping markers
    if (i > 0) {
      lat += (i * 0.00008);
      lng += (i * 0.00008);
    }

    markers.add(
      Marker(
        markerId: MarkerId(ping.id),
        position: LatLng(lat, lng),
        zIndex: isSelected ? 10.0 : 1.0,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected
              ? BitmapDescriptor.hueAzure
              : (ping.urgencyLevel.toUpperCase() == 'EMERGENCY'
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueGreen),
        ),
        onTap: () {
          ref.read(pingMapProvider.notifier).selectPing(ping.id);
        },
      ),
    );
  }

  return markers;
});

final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);
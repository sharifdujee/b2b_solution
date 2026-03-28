

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/ping_request.dart';

// ─── Models ───────────────────────────────────────────────────────────────────


// ─── State ────────────────────────────────────────────────────────────────────

class PingState {
  final List<PingRequest> pings;
  final String? selectedPingId;
  final bool isLoading;

  const PingState({
    this.pings = const [],
    this.selectedPingId,
    this.isLoading = false,
  });

  PingRequest? get selectedPing =>
      selectedPingId == null ? null : pings.firstWhere((p) => p.id == selectedPingId, orElse: () => pings.first);

  PingState copyWith({
    List<PingRequest>? pings,
    String? selectedPingId,
    bool clearSelected = false,
    bool? isLoading,
  }) =>
      PingState(
        pings: pings ?? this.pings,
        selectedPingId: clearSelected ? null : (selectedPingId ?? this.selectedPingId),
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PingNotifier extends StateNotifier<PingState> {
  PingNotifier() : super(const PingState()) {
    _loadMockPings();
  }

  void _loadMockPings() {
    final now = DateTime.now();
    state = state.copyWith(
      pings: [
        PingRequest(
          id: '1',
          title: 'Coffee Supply Needed',
          description: 'Looking for premium Arabica coffee beans, bulk order preferred.',
          vendorName: 'Blue Bottle Co.',
          vendorAvatar: 'assets/images/coffee_logo.png',
          location: const LatLng(22.3752, 91.8349),
          distanceKm: 0.4,
          postedAt: now.subtract(const Duration(minutes: 12)),
          status: PingStatus.pending,
          category: 'Coffee',
        ),
        PingRequest(
          id: '2',
          title: 'Packaging Materials',
          description: 'Urgently need eco-friendly packaging boxes for seasonal product line.',
          vendorName: 'Green Pack Ltd.',
          vendorAvatar: 'assets/images/coffee_logo.png',
          location: const LatLng(22.3758, 91.8353),
          distanceKm: 0.9,
          postedAt: now.subtract(const Duration(minutes: 35)),
          status: PingStatus.pending,
          category: 'Retail',
        ),
        PingRequest(
          id: '3',
          title: 'Fresh Produce Order',
          description: 'Daily fresh vegetables and herbs for our restaurant chain.',
          vendorName: 'Farm Fresh',
          vendorAvatar: 'assets/images/coffee_logo.png',
          location: const LatLng(18.2400, 86.1300),
          distanceKm: 1.2,
          postedAt: now.subtract(const Duration(hours: 1)),
          status: PingStatus.pending,
          category: 'Food',
        ),
        PingRequest(
          id: '4',
          title: 'Office Supplies Bulk',
          description: 'Monthly office supplies including stationery and printer consumables.',
          vendorName: 'OfficeHub',
          vendorAvatar: 'assets/images/coffee_logo.png',
          location: const LatLng(15.2220, 50.1100),
          distanceKm: 1.8,
          postedAt: now.subtract(const Duration(hours: 2)),
          status: PingStatus.accepted,
          category: 'Office',
        ),
      ],
    );
  }

  void selectPing(String id) {
    state = state.copyWith(selectedPingId: id);
  }

  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }

  void updatePingStatus(String id, PingStatus status) {
    final updated = state.pings.map((p) => p.id == id ? p.copyWith(status: status) : p).toList();
    state = state.copyWith(pings: updated, clearSelected: true);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final pingProvider = StateNotifierProvider<PingNotifier, PingState>(
      (ref) => PingNotifier(),
);

/// Derived: only pending pings
final pendingPingsProvider = Provider<List<PingRequest>>(
      (ref) => ref.watch(pingProvider).pings.where((p) => p.status == PingStatus.pending).toList(),
);

/// Derived: map markers from pings
final pingMarkersProvider = Provider<Set<Marker>>((ref) {
  final state = ref.watch(pingProvider);
  return state.pings.map((ping) {
    return Marker(
      markerId: MarkerId(ping.id),
      position: ping.location,
      onTap: () {
        ref.read(pingProvider.notifier).selectPing(ping.id);
      },
    );
  }).toSet();
});

/// Map controller provider
final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);
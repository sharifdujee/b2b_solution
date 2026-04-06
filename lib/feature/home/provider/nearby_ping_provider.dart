import 'dart:convert';
import 'dart:developer';

import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/legacy.dart';


import '../../../core/service/app_url.dart';
import '../../ping/model/ping_model.dart';
import '../../ping/provider/ping_provider.dart';
import '../model/nearby_ping_state_model.dart';

class NearbyPingNotifier extends StateNotifier<NearbyPingState> {
  final Ref ref; // Add Ref to access other providers

  NearbyPingNotifier(this.ref) : super(NearbyPingState());

  final NetworkCaller networkCaller = NetworkCaller();

  Future<void> fetchPings(double lat, double lng) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final url = AppUrl.nearbyPings(lat, lng);
      final response = await networkCaller.getRequest(url, token: AuthService.token);

      if (response.isSuccess) {
        final apiResponse = PingModel.fromJson(response.responseData);
        final List<Datum> fetchedPings = apiResponse.result?.data ?? [];

        // 🟢 CRITICAL FIX: Update the shared ping list provider
        ref.read(pingListProvider.notifier).setPings(fetchedPings);

        state = state.copyWith(
          isLoading: false,
          pings: fetchedPings,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Failed to fetch: ${response.statusCode}",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An unexpected error occurred");
    }
  }
}

// Update the provider definition to pass 'ref'
final nearbyPingProvider = StateNotifierProvider.autoDispose<NearbyPingNotifier, NearbyPingState>((ref) {
  return NearbyPingNotifier(ref);
});

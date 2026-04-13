import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../model/ping_model.dart';
import '../model/ping_pagination_state_model.dart';

enum PingFilter { active, accepted, myPings }

/// Provider to manage the selected filter state
final pingFilterProvider = StateNotifierProvider<PingFilterNotifier, PingFilter>((ref) {
  return PingFilterNotifier(ref);
});

class PingFilterNotifier extends StateNotifier<PingFilter> {
  final Ref ref;
  PingFilterNotifier(this.ref) : super(PingFilter.active);

  void updateFilter(PingFilter newFilter) {
    if (state == newFilter) return;
    state = newFilter;
    ref.read(pingListProvider.notifier).fetchPingsByFilter(newFilter);
  }
}

final pingListProvider = StateNotifierProvider<PingListNotifier, AsyncValue<PingPaginationState>>((ref) {
  return PingListNotifier(ref);
});

class PingListNotifier extends StateNotifier<AsyncValue<PingPaginationState>> {
  final Ref ref;

  PingListNotifier(this.ref) : super(AsyncValue.data(PingPaginationState()));

  final NetworkCaller networkCaller = NetworkCaller();
  final int _limit = 20;

  void setPings(List<Datum> pings) {
    state = AsyncValue.data(PingPaginationState(pings: pings, hasMore: false));
  }


  Future<void> acceptPing(String pingId) async {
    state = const AsyncValue.loading();

    try {
      final response = await networkCaller.patchRequest(
        AppUrl.acceptPing(pingId),
        body: {},
        token: AuthService.token
      );

      if (response.isSuccess) {
        state = AsyncValue.data(PingPaginationState());
        log('Ping accepted successfully');
        final currentFilter = ref.read(pingFilterProvider);
        await fetchPingsByFilter(currentFilter);
      }


    }catch(e){
      state = AsyncValue.error(e, StackTrace.current);
    }

  }
  Future<void> rejectPing(String pingId) async {
    state = const AsyncValue.loading();

    try {
      final response = await networkCaller.patchRequest(
          AppUrl.rejectPing(pingId),
          body: {},
          token: AuthService.token
      );

      if (response.isSuccess) {
        state = AsyncValue.data(PingPaginationState());
        log('Ping rejected successfully');
        final currentFilter = ref.read(pingFilterProvider);
        await fetchPingsByFilter(currentFilter);
      }

    }catch(e){
      state = AsyncValue.error(e, StackTrace.current);
    }

  }


  Future<void> deletePing(String pingId) async {
    state = const AsyncValue.loading();

    try {
      final response = await networkCaller.deleteRequest(
        AppUrl.deletePing(pingId),
        body: {},
        AuthService.token,
      );

      if (response.isSuccess) {
        state = AsyncValue.data(PingPaginationState());
        log('Ping deleted successfully');
        final currentFilter = ref.read(pingFilterProvider);

        await fetchPingsByFilter(currentFilter);

      } else {
        state = AsyncValue.error(response.errorMessage, StackTrace.current);
      }
    }catch(e){
      state = AsyncValue.error(e, StackTrace.current);
    }
  }


  /// Entry point for filter changes (Resets to page 1)
  Future<void> fetchPingsByFilter(PingFilter filter) async {
    state = const AsyncValue.loading();
    await _fetchDispatcher(filter, page: 1, isLoadMore: false);
  }

  /// Entry point for infinite scroll (Appends to existing list)
  Future<void> loadMore(PingFilter filter) async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    await _fetchDispatcher(filter, page: currentState.currentPage + 1, isLoadMore: true);
  }

  /// Internal Dispatcher to route to the correct API function
  Future<void> _fetchDispatcher(PingFilter filter, {required int page, required bool isLoadMore}) async {
    if (filter == PingFilter.active) {
      await _fetchActivePings(page, isLoadMore);
    } else if (filter == PingFilter.accepted) {
      await _fetchAcceptedPings(page, isLoadMore);
    } else if (filter == PingFilter.myPings) {
      await _fetchMyPings(page, isLoadMore);
    }
  }

  Future<void> _fetchActivePings(int page, bool isLoadMore) async {
    final url = AppUrl.getPing(500);
    await _executeApiRequest(url, page, isLoadMore, supportsPagination: false);
  }

  Future<void> _fetchAcceptedPings(int page, bool isLoadMore) async {
    final url = AppUrl.acceptedPings(page, _limit);
    await _executeApiRequest(url, page, isLoadMore);
  }

  Future<void> _fetchMyPings(int page, bool isLoadMore) async {
    final url = AppUrl.myPings(page, _limit);
    await _executeApiRequest(url, page, isLoadMore);
  }

  /// Core Execution Method: Handles the network call and Riverpod state management
  Future<void> _executeApiRequest(
      String url,
      int page,
      bool isLoadMore,
      {bool supportsPagination = true}
      ) async {
    try {
      log('Fetching API: $url');
      final response = await networkCaller.getRequest(url, token: AuthService.token);

      if (response.isSuccess) {
        final apiResponse = PingModel.fromJson(response.responseData);
        final List<Datum> newPings = apiResponse.result?.data ?? [];
        final previousState = state.value ?? PingPaginationState();

        state = AsyncValue.data(PingPaginationState(
          pings: isLoadMore ? [...previousState.pings, ...newPings] : newPings,
          currentPage: page,
          hasMore: supportsPagination ? (newPings.length >= _limit) : false,
          isLoadingMore: false,
        ));
      } else {
        state = AsyncValue.error("Server error: ${response.statusCode}", StackTrace.current);
      }
    } catch (e, stack) {
      log('Execution error: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}
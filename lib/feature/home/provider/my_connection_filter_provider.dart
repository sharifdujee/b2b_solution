import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/auth_service.dart';
import '../model/connection_state_model.dart';
import '../model/my_connection_api_response.dart';
import '../model/my_connection_state_model.dart';

class ConnectionNotifier extends StateNotifier<ConnectionFilterOption> {
  final Ref ref;
  ConnectionNotifier(this.ref) : super(ConnectionFilterOption.Connected);

  void updateFilter(ConnectionFilterOption newFilter) {
    if (state == newFilter) return;
    state = newFilter;
    ref.read(myConnectionListProvider.notifier).fetchBasedOnFilter(isRefresh: true);
  }
}

final connectionFilterProvider = StateNotifierProvider<ConnectionNotifier, ConnectionFilterOption>((ref) {
  return ConnectionNotifier(ref);
});

final myConnectionListProvider = StateNotifierProvider<MyConnectionListNotifier, ConnectionStateData>((ref) {
  return MyConnectionListNotifier(ref);
});

class MyConnectionListNotifier extends StateNotifier<ConnectionStateData> {
  final Ref ref;
  MyConnectionListNotifier(this.ref) : super(ConnectionStateData(items: []));

  final NetworkCaller networkCaller = NetworkCaller();
  static const int _limit = 20;



  Future <void> acceptConnection(String connectionId) async {

  }

  Future <void> rejectConnection(String connectionId) async {

  }



  /// Entry point for refreshing or changing filters
  Future<void> fetchBasedOnFilter({bool isRefresh = false}) async {
    final filter = ref.read(connectionFilterProvider);

    log('Auth Token : ${AuthService.token}');

    if (isRefresh) {
      state = state.copyWith(items: [], currentPage: 1, hasMore: true, isLoading: true);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    await _fetchDispatcher(filter, page: state.currentPage, isRefresh: isRefresh);
  }

  /// Internal Dispatcher: Routes the filter to the correct URL
  Future<void> _fetchDispatcher(ConnectionFilterOption filter, {required int page, required bool isRefresh}) async {
    String url;
    switch (filter) {
      case ConnectionFilterOption.Connected:
        url = AppUrl.getMyAllConnection(page, _limit);
        break;
      case ConnectionFilterOption.Pending:
        url = AppUrl.pendingConnections(page, _limit);
        break;
      case ConnectionFilterOption.Find:
        url = AppUrl.findUsers(page, _limit);
        break;
    }

    await _executeApiRequest(url, page, isRefresh);
  }

  /// Core Execution Method: Handles network call and state updates
  Future<void> _executeApiRequest(String url, int page, bool isRefresh) async {
    try {
      log('Fetching Connections API: $url');
      final response = await networkCaller.getRequest(url, token: AuthService.token);

      if (response.isSuccess && response.responseData != null) {
        final apiResponse = MyConnectionApiResponse.fromJson(response.responseData);
        final List<MyConnectionStateModel> newItems = apiResponse.result?.data ?? [];

        state = state.copyWith(
          items: isRefresh ? newItems : [...state.items, ...newItems],
          currentPage: page + 1,
          isLoading: false,
          hasMore: newItems.length >= _limit,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      log("Connection Fetch Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }
}


final filteredConnectionsProvider = Provider<List<MyConnectionStateModel>>((ref) {
  return ref.watch(myConnectionListProvider).items;
});

final connectionCountsProvider = Provider<Map<ConnectionFilterOption, int>>((ref) {
  final connectionState = ref.watch(myConnectionListProvider);
  return {
    ConnectionFilterOption.Connected: connectionState.items.length,
    ConnectionFilterOption.Pending: connectionState.items.length,
    ConnectionFilterOption.Find: connectionState.items.length,
  };
});
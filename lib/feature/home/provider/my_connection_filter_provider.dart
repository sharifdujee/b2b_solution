import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/auth_service.dart';
import '../model/connection_state_model.dart';
import '../model/find_connecion_state_model.dart';
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
  MyConnectionListNotifier(this.ref) : super(ConnectionStateData(items: [], discoverItems: []));

  final NetworkCaller networkCaller = NetworkCaller();
  static const int _limit = 20;

  // --- Connection Actions ---



  Future<void> sendConnectionRequest(String connectionId, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await networkCaller.postRequest(
          AppUrl.sendConnectionRequest(connectionId),
          token: AuthService.token,
          body: {});

      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        // Refresh list to show updated status
        fetchBasedOnFilter(isRefresh: true);
        _showSnackBar(context, 'Connection Request Sent Successfully!', Colors.green);
      } else {
        _showSnackBar(context, response.errorMessage ?? 'Failed to send request', Colors.red);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _showSnackBar(context, 'An unexpected error occurred', Colors.black);
    }
  }

  Future<void> acceptConnection(String connectionId, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await networkCaller.patchRequest(
        AppUrl.acceptConnection(connectionId),
        token: AuthService.token,
        body: {
          "status": "CONNECTED",
        },
      );
      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        fetchBasedOnFilter(isRefresh: true);
        _showSnackBar(context, 'Connection Accepted', Colors.green);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectConnection(String connectionId, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await networkCaller.patchRequest(
        AppUrl.rejectConnection(connectionId),
        token: AuthService.token,
        body: {
          "status": "REJECTED",
        },
      );
      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        fetchBasedOnFilter(isRefresh: true);
        _showSnackBar(context, 'Connection Declined', Colors.orange);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }


  var status = '';

  Future<void> fetchBasedOnFilter({bool isRefresh = false}) async {
    final filter = ref.read(connectionFilterProvider);
    final page = isRefresh ? 1 : state.currentPage;

    if (isRefresh) {
      state = state.copyWith(items: [], currentPage: 1, hasMore: true, isLoading: true);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    // Direct function calls instead of switch-case
    if (filter == ConnectionFilterOption.Connected) {
      await _fetchConnected(page, isRefresh);
    } else if (filter == ConnectionFilterOption.Pending) {
      await _fetchPending(page, isRefresh);
    } else if (filter == ConnectionFilterOption.Find) {
      await _fetchDiscover(page, isRefresh);
    }
  }

  Future<void> _fetchConnected(int page, bool isRefresh) async {
    status = 'CONNECTED';
    final url = AppUrl.getMyAllConnection(page, _limit);
    await _executeApiRequest(url, page, isRefresh);
  }

  Future<void> _fetchPending(int page, bool isRefresh) async {
    status = 'PENDING';
    final url = AppUrl.pendingConnections(page, _limit);
    await _executeApiRequest(url, page, isRefresh);
  }

  Future<void> _fetchDiscover(int page, bool isRefresh) async {
    status = 'FIND';
    try {
      final response = await networkCaller.getRequest(
        AppUrl.findUsers(page, _limit),
        token: AuthService.token,
      );

      if (response.isSuccess && response.responseData != null) {
        final findResponse = FindConnectionStateModel.fromJson(response.responseData);
        final List<FindDatum> newItems = findResponse.findResult.data;

        state = state.copyWith(
          discoverItems: isRefresh
              ? newItems
              : <FindDatum>[...state.discoverItems, ...newItems],
          currentPage: page + 1,
          isLoading: false,
          hasMore: newItems.length >= _limit,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      log("Discovery Fetch Error: $e");
    }
  }

  // --- Helper Methods ---

  Future<void> _executeApiRequest(String url, int page, bool isRefresh) async {
    try {
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
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMyConnectionCount() async {
    try {
      final response = await networkCaller.getRequest(
          AppUrl.myConnectionCount,
          token: AuthService.token
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['result'];

        state = state.copyWith(
          connectedCount: data['connectionCount'] ?? 0,
        );
      }
    } catch (e) {
      log("Error fetching counts: $e");
    }
  }
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

final filteredConnectionsProvider = Provider<List<dynamic>>((ref) {
  final filter = ref.watch(connectionFilterProvider);
  final connectionState = ref.watch(myConnectionListProvider);

  if (filter == ConnectionFilterOption.Find) {
    return connectionState.discoverItems;
  } else {
    return connectionState.items;
  }
});

final connectionCountsProvider = Provider<Map<ConnectionFilterOption, int>>((ref) {
  final connectionState = ref.watch(myConnectionListProvider);
  return {

    ConnectionFilterOption.Connected: connectionState.items.length,
    ConnectionFilterOption.Pending: connectionState.items.length,
    ConnectionFilterOption.Find: connectionState.items.length,
  };
});
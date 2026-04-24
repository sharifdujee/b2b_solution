import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/auth_service.dart';
import '../model/connected_state_model.dart';
import '../model/connection_state_model.dart';
import '../model/find_connecion_state_model.dart';
import '../model/my_connection_api_response.dart';
import '../model/my_connection_state_model.dart';
import '../model/pending_connection_state_model.dart';
import '../model/send_request_state_model.dart';

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

  Future<void> sendRequests() async {
    // 1. Set loading state
    state = state.copyWith(isLoading: true);

    try {
      final response = await networkCaller.getRequest(
        AppUrl.sendRequests,
        token: AuthService.token,
      );

      if (response.isSuccess && response.responseData != null) {
        // 2. Parse the JSON using your generated factory
        final sendRequestModel = SendRequestStateModel.fromJson(response.responseData);

        // 3. Update state with the parsed data
        // Assuming your State class has fields for 'requests' and 'totalCount'
        state = state.copyWith(
          isLoading: false,
          sendRequestsList: sendRequestModel.result.data,
          totalRequests: sendRequestModel.result.meta.total,
        );

        log("sendRequests list fetched successfully. Count: ${sendRequestModel.result.meta.total}");
      } else {
        state = state.copyWith(isLoading: false);
        log("sendRequests list fetch failed: ${response.errorMessage}");
      }

    } catch (e) {
      state = state.copyWith(isLoading: false);
      log('An unexpected error occurred: $e');
    }
  }

  Future<void> removeConnection(String connectionId, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await networkCaller.deleteRequest(
        AppUrl.removeConnection(connectionId),
        AuthService.token,
        body: {},
      );
      state = state.copyWith(isLoading: false);
      if (response.isSuccess) {
        fetchBasedOnFilter(isRefresh: true);
        _showSnackBar(context, 'Connection Removed', Colors.orange);
      }
    }catch(e){
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> cancelRequest(String connectionId, BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      log("Cancel Request:");
      log("id: $connectionId");
      log("AuthService.token: ${AuthService.token}");
      log("My ID: ${AuthService.id}");
      final response = await networkCaller.deleteRequest(
        AppUrl.cancelRequest(connectionId),
        AuthService.token,
        body: {},
      );
      state = state.copyWith(isLoading: false);
      if (response.isSuccess) {
        fetchBasedOnFilter(isRefresh: true);
        _showSnackBar(context, 'Request Cancelled', Colors.orange);
      }
    }catch(e){
      state = state.copyWith(isLoading: false);
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
      debugPrint("🔵 Rejecting connection ID: $connectionId");

      final response = await networkCaller.patchRequest(
        AppUrl.rejectConnection(connectionId),
        token: AuthService.token,
        body: {
          "status": "REJECTED",
        },
      );

      debugPrint("🟢 Response: ${response.responseData}");

      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        fetchBasedOnFilter(isRefresh: true);

        if (context.mounted) {
          _showSnackBar(context, 'Connection declined', Colors.orange);
        }
      } else {
        if (context.mounted) {
          _showSnackBar(
            context,
            response.errorMessage ?? 'Failed to decline connection',
            Colors.red,
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint("🔴 Error: $e");
      debugPrint("📌 StackTrace: $stackTrace");

      state = state.copyWith(isLoading: false);

      if (context.mounted) {
        _showSnackBar(
          context,
          'Something went wrong. Please try again.',
          Colors.red,
        );
      }
    }
  }


  var status = '';
  TextEditingController searchQueryController = TextEditingController();

  Future<void> fetchBasedOnFilter({bool isRefresh = false}) async {
    final filter = ref.read(connectionFilterProvider);
    final page = isRefresh ? 1 : state.currentPage;

    final currentQuery = state.searchQuery;
    log("search : $currentQuery");

    if (isRefresh) {
      state = state.copyWith(items: [], currentPage: 1, hasMore: true, isLoading: true);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    if (filter == ConnectionFilterOption.Connected) {
      await _fetchConnected(page, currentQuery, isRefresh);
    } else if (filter == ConnectionFilterOption.Pending) {
      await _fetchPending(page, currentQuery, isRefresh);
    } else if (filter == ConnectionFilterOption.Find) {
      await _fetchDiscover(page, currentQuery, isRefresh);
    } else if (filter == ConnectionFilterOption.Requests) {
      await sendRequests();
    }
  }


  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> _fetchConnected(int page, String searchQuery,bool isRefresh) async {
    status = 'CONNECTED';
    final url = AppUrl.getMyAllConnection(page, _limit);
    await _executeApiRequest(url, page, isRefresh);
  }

  // In MyConnectionListNotifier class:

  Future<void> _fetchPending(int page, String searchQuery,bool isRefresh) async {
    try {
      final response = await networkCaller.getRequest(
          AppUrl.pendingConnections(page, _limit),
          token: AuthService.token
      );

      if (response.isSuccess && response.responseData != null) {
        final pendingResponse = PendingConnectionModel.fromJson(response.responseData);
        final List<PendingConnection> newItems = pendingResponse.result?.data ?? [];
        state = state.copyWith(
          pendingItems: isRefresh
              ? newItems
              : [...(state.pendingItems ?? []), ...newItems],
          currentPage: page + 1,
          isLoading: false,
          hasMore: newItems.length >= _limit,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      log("Pending Fetch Error: $e");
    }
  }

  Future<void> _fetchDiscover(int page, String searchQuery,bool isRefresh) async {
    status = 'FIND';
    try {
      final response = await networkCaller.getRequest(
        AppUrl.findUsers(page, searchQuery,_limit),
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

// ... inside MyConnectionListNotifier class

  // Updated Helper Method to use the new Connected model
  Future<void> _executeApiRequest(String url, int page, bool isRefresh) async {
    try {
      final response = await networkCaller.getRequest(url, token: AuthService.token);

      if (response.isSuccess && response.responseData != null) {
        // Use the new ConnectedConnectionModel instead of MyConnectionApiResponse
        final apiResponse = ConnectedConnectionModel.fromJson(response.responseData);

        // Extract data from the new model structure
        final List<ConnectedConnection> newItems = apiResponse.result?.data ?? [];

        state = state.copyWith(
          // Ensure your ConnectionStateData 'items' field is List<ConnectedConnection>
          items: isRefresh ? newItems : [...state.items, ...newItems],
          currentPage: page + 1,
          isLoading: false,
          hasMore: newItems.length >= _limit,
        );
      } else {
        state = state.copyWith(isLoading: false);
        log("Connected Fetch Error: ${response.errorMessage}");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      log("Connected Fetch Exception: $e");
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
  final query = connectionState.searchQuery.toLowerCase();

  List<dynamic> baseList;
  switch (filter) {
    case ConnectionFilterOption.Find:
      baseList = connectionState.discoverItems;
      break;
    case ConnectionFilterOption.Pending:
      baseList = connectionState.pendingItems ?? [];
      break;
    case ConnectionFilterOption.Requests:
      baseList = connectionState.sendRequestsList ?? [];
      break;
    default:
      baseList = connectionState.items;
  }

  if (query.isEmpty) return baseList;

  return baseList.where((item) {
    final String name = (item.name ?? item.fullName ?? item.userName ?? "").toString().toLowerCase();
    final String company = (item.companyName ?? item.company ?? "").toString().toLowerCase();

    return name.contains(query) || company.contains(query);
  }).toList();
});

final connectionCountsProvider = Provider<Map<ConnectionFilterOption, int>>((ref) {
  final connectionState = ref.watch(myConnectionListProvider);
  return {

    ConnectionFilterOption.Connected: connectionState.items.length,
    ConnectionFilterOption.Pending: connectionState.items.length,
    ConnectionFilterOption.Find: connectionState.items.length,
  };
});
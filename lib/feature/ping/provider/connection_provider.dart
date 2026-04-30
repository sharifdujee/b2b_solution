import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../../home/model/my_connection_state_model.dart';
import '../../home/provider/my_connection_filter_provider.dart';
import '../model/connection_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MyConnectionState {
  final List<ConnectionModel> connections;
  final bool isLoading;
  final String? errorMessage;

  MyConnectionState({
    this.connections = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MyConnectionState copyWith({
    List<ConnectionModel>? connections,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyConnectionState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ConnectionNotifier extends StateNotifier<MyConnectionState> {
  final Ref ref;
  ConnectionNotifier(this.ref) : super(MyConnectionState()) {
    // 1. Fetch immediately when the provider is initialized
    fetchConnections();
  }

  Timer? _debounce;

  void onSearch(String query) {
    // Allow empty string to reset the list to "all connections"
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchConnections(searchTerm: query);
    });
  }

  Future<void> fetchConnections({String searchTerm = ""}) async {


    state = state.copyWith(isLoading: true);
    final currentFilter = ref.read(connectionFilterProvider);

    try {
      final String url = (currentFilter == ConnectionFilterOption.Find)
          ? AppUrl.findUsers(1, searchTerm, 50)
          : AppUrl.getMyConnectionBySearch(1, 50, searchTerm);

      final response = await NetworkCaller().getRequest(url, token: AuthService.token);

      if (response.isSuccess && response.responseData != null) {
        final resultData = response.responseData['result'];
        List<dynamic> rawList = [];

        if (resultData != null) {
          if (resultData is Map && resultData.containsKey('data')) {
            rawList = resultData['data'];
          } else if (resultData is List) {
            rawList = resultData;
          }
        }

        final list = rawList.map((e) => ConnectionModel.fromJson(e)).toList();

        state = state.copyWith(
            connections: list,
            isLoading: false,
            errorMessage: null
        );
      } else {
        state = state.copyWith(isLoading: false, connections: []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, connections: []);
    }
  }
}
final connectionProvider = StateNotifierProvider<ConnectionNotifier, MyConnectionState>((ref) {
  return ConnectionNotifier(ref);
});
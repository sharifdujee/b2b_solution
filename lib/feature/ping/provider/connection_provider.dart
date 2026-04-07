import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../model/connection_model.dart';

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
  ConnectionNotifier() : super(MyConnectionState()) {
    fetchConnections();
  }

  Future<void> fetchConnections({String searchTerm = ""}) async {
    if (state.connections.isEmpty) state = state.copyWith(isLoading: true);

    NetworkCaller networkCaller = NetworkCaller();
    try {
      final url = searchTerm.isEmpty
          ? AppUrl.getMyAllConnection(1, 50)
          : AppUrl.getMyConnectionBySearch(1, 50, searchTerm);

      log('AppUrl: $AppUrl');
      final response = await networkCaller.getRequest(url, token: AuthService.token);

      if (response.isSuccess) {
        final List data = response.responseData['result']['data'] ?? [];
        log('data: $data');
        final list = data.map((e) => ConnectionModel.fromJson(e)).toList();
        state = state.copyWith(connections: list, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: response.errorMessage);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final connectionProvider = StateNotifierProvider<ConnectionNotifier, MyConnectionState>((ref) {
  return ConnectionNotifier();
});
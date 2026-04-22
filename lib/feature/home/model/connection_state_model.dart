import 'package:b2b_solution/feature/home/model/pending_connection_state_model.dart';
import 'package:b2b_solution/feature/home/model/send_request_state_model.dart';

import 'connected_state_model.dart';
import 'find_connecion_state_model.dart';

class ConnectionStateData {
  final List<ConnectedConnection> items;
  final List<FindDatum> discoverItems;
  final List<SendRequestResultDatum> sendRequestsList;
  final List<PendingConnection> pendingItems;

  final String searchQuery;

  final int totalRequests;
  final int connectedCount;
  final bool isLoading;
  final int currentPage;
  final bool hasMore;

  ConnectionStateData({
    required this.items,
    required this.discoverItems,
    this.sendRequestsList = const [],
    this.pendingItems = const [],
    this.searchQuery = "",
    this.totalRequests = 0,
    this.connectedCount = 0,
    this.isLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ConnectionStateData copyWith({
    List<ConnectedConnection>? items,
    List<FindDatum>? discoverItems,
    List<SendRequestResultDatum>? sendRequestsList,
    List<PendingConnection>? pendingItems,
    String? searchQuery,
    int? totalRequests,
    int? connectedCount,
    bool? isLoading,
    int? currentPage,
    bool? hasMore,
  }) {
    return ConnectionStateData(
      items: items ?? this.items,
      discoverItems: discoverItems ?? this.discoverItems,
      sendRequestsList:
      sendRequestsList ?? this.sendRequestsList,
      pendingItems:
      pendingItems ?? this.pendingItems,
      searchQuery:
      searchQuery ?? this.searchQuery,
      totalRequests:
      totalRequests ?? this.totalRequests,
      connectedCount:
      connectedCount ?? this.connectedCount,
      isLoading: isLoading ?? this.isLoading,
      currentPage:
      currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
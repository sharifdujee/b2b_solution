import 'connected_state_model.dart';
import 'find_connecion_state_model.dart';
import 'send_request_state_model.dart';
import 'pending_connection_state_model.dart';

class ConnectionStateData {
  // 1. Updated 'items' to use the new ConnectedConnection model
  final List<ConnectedConnection> items;
  final List<FindDatum> discoverItems;
  final List<SendRequestResultDatum> sendRequestsList;
  final List<PendingConnection> pendingItems;

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
    this.totalRequests = 0,
    this.connectedCount = 0,
    this.isLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ConnectionStateData copyWith({
    List<ConnectedConnection>? items, // Updated type here
    List<FindDatum>? discoverItems,
    List<SendRequestResultDatum>? sendRequestsList,
    List<PendingConnection>? pendingItems,
    int? totalRequests,
    int? connectedCount,
    bool? isLoading,
    int? currentPage,
    bool? hasMore,
  }) {
    return ConnectionStateData(
      items: items ?? this.items,
      discoverItems: discoverItems ?? this.discoverItems,
      sendRequestsList: sendRequestsList ?? this.sendRequestsList,
      pendingItems: pendingItems ?? this.pendingItems,
      totalRequests: totalRequests ?? this.totalRequests,
      connectedCount: connectedCount ?? this.connectedCount,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
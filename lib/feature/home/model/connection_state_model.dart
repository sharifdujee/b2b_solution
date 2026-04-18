import 'find_connecion_state_model.dart';
import 'my_connection_state_model.dart';
import 'send_request_state_model.dart'; // Import the new model

class ConnectionStateData {
  final List<MyConnectionStateModel> items;
  final List<FindDatum> discoverItems;
  final List<SendRequestResultDatum> sendRequestsList; // New field
  final int totalRequests; // New count field
  final int connectedCount;
  final bool isLoading;
  final int currentPage;
  final bool hasMore;

  ConnectionStateData({
    required this.items,
    required this.discoverItems,
    this.sendRequestsList = const [], // Initialized as empty list
    this.totalRequests = 0,           // Initialized as zero
    this.connectedCount = 0,
    this.isLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ConnectionStateData copyWith({
    List<MyConnectionStateModel>? items,
    List<FindDatum>? discoverItems,
    List<SendRequestResultDatum>? sendRequestsList,
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
      totalRequests: totalRequests ?? this.totalRequests,
      connectedCount: connectedCount ?? this.connectedCount,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
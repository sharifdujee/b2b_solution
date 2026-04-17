import 'find_connecion_state_model.dart';
import 'my_connection_state_model.dart';

class ConnectionStateData {
  final List<MyConnectionStateModel> items;
  final List<FindDatum> discoverItems;
  final int connectedCount;
  final bool isLoading;
  final int currentPage;
  final bool hasMore;

  ConnectionStateData({
    required this.items,
    required this.discoverItems,
    this.connectedCount = 0,
    this.isLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ConnectionStateData copyWith({
    List<MyConnectionStateModel>? items,
    List<FindDatum>? discoverItems,
    int? connectedCount,
    bool? isLoading,
    int? currentPage,
    bool? hasMore,
  }) {
    return ConnectionStateData(
      items: items ?? this.items,
      discoverItems: discoverItems ?? this.discoverItems,
      connectedCount: connectedCount ?? this.connectedCount,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
import 'my_connection_state_model.dart';

class ConnectionStateData {
  final List<MyConnectionStateModel> items;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;

  ConnectionStateData({
    required this.items,
    this.currentPage = 1,
    this.isLoading = false,
    this.hasMore = true,
  });

  ConnectionStateData copyWith({
    List<MyConnectionStateModel>? items,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
  }) {
    return ConnectionStateData(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
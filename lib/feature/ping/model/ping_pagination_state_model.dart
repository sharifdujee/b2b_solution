import 'package:b2b_solution/feature/ping/model/ping_model.dart';

class PingPaginationState {
  final List<Datum> pings;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  PingPaginationState({
    this.pings = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PingPaginationState copyWith({
    List<Datum>? pings,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PingPaginationState(
      pings: pings ?? this.pings,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
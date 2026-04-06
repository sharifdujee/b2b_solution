import '../../ping/model/ping_model.dart';

class NearbyPingState {
  final bool isLoading;
  final List<PingModel> pings;
  final String? errorMessage;

  NearbyPingState({
    this.isLoading = false,
    this.pings = const [],
    this.errorMessage,
  });

  NearbyPingState copyWith({
    bool? isLoading,
    List<PingModel>? pings,
    String? errorMessage,
  }) {
    return NearbyPingState(
      isLoading: isLoading ?? this.isLoading,
      pings: pings ?? this.pings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
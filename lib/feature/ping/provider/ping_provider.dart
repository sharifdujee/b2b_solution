import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/ping_model.dart';
enum PingFilter { active, accepted, myPings }

class PingFilterNotifier extends StateNotifier<PingFilter> {
  PingFilterNotifier() : super(PingFilter.active);

  void updateFilter(PingFilter newFilter) => state = newFilter;
}

final pingFilterProvider = StateNotifierProvider<PingFilterNotifier, PingFilter>((ref) {
  return PingFilterNotifier();
});


class PingListNotifier extends StateNotifier<List<Datum>> {
  PingListNotifier() : super([]);

  // Use this when the API returns the list of pings
  void setPings(List<Datum> pings) {
    state = pings;
  }

  void addPing(Datum newPing) {
    state = [newPing, ...state];
  }
}

final pingListProvider = StateNotifierProvider<PingListNotifier, List<Datum>>((ref) {
  return PingListNotifier();
});


final filteredPingsProvider = Provider<List<Datum>>((ref) {
  final filter = ref.watch(pingFilterProvider);
  final pings = ref.watch(pingListProvider);


  return pings;
});
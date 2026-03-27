import 'package:b2b_solution/core/utils/local_assets/image_path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/ping_model.dart';

enum PingFilter { active, accepted, myPings }

class PingFilterNotifier extends Notifier<PingFilter> {
  @override
  PingFilter build() => PingFilter.active;
  void updateFilter(PingFilter newFilter) => state = newFilter;
}

final pingFilterProvider = NotifierProvider<PingFilterNotifier, PingFilter>(PingFilterNotifier.new);

// 2. Data Notifier (With Demo Data)
class PingListNotifier extends Notifier<List<PingModel>> {
  @override
  List<PingModel> build() {
    return [
      PingModel(
        shopName: "Tehari Shop",
        needs: "Rice supply needed",
        distance: "0.5 km away",
        logoUrl: ImagePath.burgersLogo,
        priority: PingPriority.emergency,
        category: PingFilter.active,
        membershipYear: 2021,
        shopAddress: "Manager, Subway",
        itemName: "Coffee Cups",
        quanity: 50,
        unit: "Pieces",
        neededWithin: "Within 2 Hours",
        radius: 5,
        notes: "Urgent! Out of cups!",
        chooseConnection: "My Connection Only",
      ),
      PingModel(
        shopName: "Coffee Shop",
        needs: "20L Fry Oil",
        distance: "0.5 km away",
        logoUrl: ImagePath.coffeeLogo,
        priority: PingPriority.moderate,
        category: PingFilter.active,
        membershipYear: 2020,

      ),
      PingModel(
        shopName: "Coffee Shop",
        needs: "20L Fry Oil",
        distance: "0.5 km away",
        logoUrl: ImagePath.coffeeLogo,
        priority: PingPriority.general,
        category: PingFilter.active,
        membershipYear: 2023,

      ),
      // Demo data for other tabs
      PingModel(
        shopName: "Burger King",
        needs: "Bun supply",
        distance: "1.2 km away",
        logoUrl: ImagePath.coffeeLogo,
        priority: PingPriority.moderate,
        category: PingFilter.accepted,
        membershipYear: 2025,

      ),
    ];
  }
}

final pingListProvider = NotifierProvider<PingListNotifier, List<PingModel>>(PingListNotifier.new);

// 3. Computed Provider for filtered results
final filteredPingsProvider = Provider<List<PingModel>>((ref) {
  final filter = ref.watch(pingFilterProvider);
  final pings = ref.watch(pingListProvider);
  return pings.where((p) => p.category == filter).toList();
});
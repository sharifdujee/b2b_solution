import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:b2b_solution/core/utils/local_assets/image_path.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/ping_model.dart';

/// 1. Filter State (Tabs)
enum PingFilter { active, accepted, myPings }

class PingFilterNotifier extends StateNotifier<PingFilter> {
  PingFilterNotifier() : super(PingFilter.active);

  void updateFilter(PingFilter newFilter) => state = newFilter;
}

final pingFilterProvider = StateNotifierProvider<PingFilterNotifier, PingFilter>((ref) {
  return PingFilterNotifier();
});

/// 2. Form State Notifier (For CreatePingScreen)
/// Manages the temporary state of a new ping using StateNotifier.
class CreatePingNotifier extends StateNotifier<PingModel> {
  CreatePingNotifier()
      : super(
    PingModel(
      shopName: "My Shop",
      needs: "",
      distance: "0.0 km",
      logoUrl: ImagePath.burgersLogo,
      priority: PingPriority.general,
      category: PingFilter.active,
      membershipYear: 2024,
      myConnectionOnly: false,
    ),
  );

  // Update Methods
  void updatePriority(PingPriority priority) => state = state.copyWith(priority: priority);
  void updateItemName(String itemName) => state = state.copyWith(itemName: itemName, needs: itemName);
  void updateQuantity(double quantity) => state = state.copyWith(quanity: quantity);
  void updateUnit(String unit) => state = state.copyWith(unit: unit);
  void updateNeededWithin(String time) => state = state.copyWith(neededWithin: time);
  void updateRadius(int radius) => state = state.copyWith(radius: radius);
  void updateCategory(PingFilter category) => state = state.copyWith(category: category);  void updateNotes(String notes) => state = state.copyWith(notes: notes);
  void updateProductCategory(String category) => state = state.copyWith(productCategory: category);

  void toggleMyConnectionOnly() {
    state = state.copyWith(myConnectionOnly: !state.myConnectionOnly);
  }

  void updateConnection(List<String> connections) {
    state = state.copyWith(chooseConnection: connections);
  }  void updateDistance(String distance) => state = state.copyWith(distance: distance);
  void updateAddress(String address) => state = state.copyWith(shopAddress: address);

  // Method to reset the form manually since we aren't using autoDispose
  void resetForm() {
    state = PingModel(
      shopName: "My Shop",
      needs: "",
      distance: "0.0 km",
      logoUrl: ImagePath.burgersLogo,
      priority: PingPriority.general,
      category: PingFilter.active,
      membershipYear: 2024,
      myConnectionOnly: false
    );
  }
}

final createPingProvider = StateNotifierProvider<CreatePingNotifier, PingModel>((ref) {
  return CreatePingNotifier();
});

/// 3. Data Notifier (Main List)
class PingListNotifier extends StateNotifier<List<PingModel>> {
  PingListNotifier()
      : super([
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
      chooseConnection: ["My Connection Only"],
      myConnectionOnly: false
    ),
    PingModel(
      shopName: "Coffee Shop",
      needs: "20L Fry Oil",
      distance: "0.5 km away",
      logoUrl: ImagePath.coffeeLogo,
      priority: PingPriority.moderate,
      category: PingFilter.active,
      membershipYear: 2020,
      myConnectionOnly: false
    ),
    PingModel(
      shopName: "Coffee Shop",
      needs: "20L Fry Oil",
      distance: "0.5 km away",
      logoUrl: ImagePath.coffeeLogo,
      priority: PingPriority.general,
      category: PingFilter.myPings,
      membershipYear: 2023,
        myConnectionOnly: false

    ),
    PingModel(
      shopName: "Burger King",
      needs: "Bun supply",
      distance: "1.2 km away",
      logoUrl: ImagePath.coffeeLogo,
      priority: PingPriority.moderate,
      category: PingFilter.accepted,
      membershipYear: 2025,
        myConnectionOnly: false

    ),
  ]);

  void addPing(PingModel newPing) {
    state = [newPing, ...state];
  }

  void acceptPing(PingModel ping) {
    state = [
      for (final p in state)
        if (p == ping) p.copyWith(category: PingFilter.accepted) else p,
    ];
  }
}

final pingListProvider = StateNotifierProvider<PingListNotifier, List<PingModel>>((ref) {
  return PingListNotifier();
});

/// 4. Filtered Provider
final filteredPingsProvider = Provider<List<PingModel>>((ref) {
  final filter = ref.watch(pingFilterProvider);
  final pings = ref.watch(pingListProvider);
  return pings.where((p) => p.category == filter).toList();
});
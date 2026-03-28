import 'package:b2b_solution/core/utils/local_assets/icon_path.dart';
import 'package:b2b_solution/core/utils/local_assets/image_path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/my_connection_state_model.dart';
class ConnectionNotifier extends StateNotifier<ConnectionFilterOption> {
  ConnectionNotifier() : super(ConnectionFilterOption.Connected);

  void updateFilter(ConnectionFilterOption newFilter) => state = newFilter;
}

final connectionFilterProvider = StateNotifierProvider<ConnectionNotifier, ConnectionFilterOption>((ref) {
  return ConnectionNotifier();
});

class MyConnectionListNotifier extends StateNotifier<List<MyConnectionStateModel>> {
  MyConnectionListNotifier() : super([
    MyConnectionStateModel(
      name: "Acme Corp",
      address: "123 Business Way, NY",
      note: "Top supplier",
      icon: ImagePath.burgersLogo,
      membershipYear: 2024,
      phoneNumber: "123456",
      email: "acme@biz.com",
      status: ConnectionFilterOption.Connected,
      sendRequestStatus: false
    ),
    MyConnectionStateModel(
      name: "Global Tech",
      address: "456 Innovation Blvd, CA",
      note: "Partnership pending",
      icon: ImagePath.burgersLogo,
      membershipYear: 2025,
      phoneNumber: "987654",
      email: "tech@global.com",
      status: ConnectionFilterOption.Pending,
      sendRequestStatus: true
    ),
    MyConnectionStateModel(
      name: "Dhaka Traders",
      address: "Gulshan, Dhaka",
      note: "New Request",
      icon: ImagePath.coffeeLogo,
      membershipYear: 2026,
      phoneNumber: "555666",
      email: "info@dhaka.com",
      status: ConnectionFilterOption.Pending,
      sendRequestStatus: true
    ),
  ]);
}

final myConnectionListProvider = StateNotifierProvider<MyConnectionListNotifier, List<MyConnectionStateModel>>((ref) {
  return MyConnectionListNotifier();
});

// --- 3. THE FILTER LOGIC (Computed Provider) ---
final filteredConnectionsProvider = Provider<List<MyConnectionStateModel>>((ref) {
  final activeFilter = ref.watch(connectionFilterProvider);
  final allConnections = ref.watch(myConnectionListProvider);

  if (activeFilter == ConnectionFilterOption.Find) {
    return allConnections; // Show everything for 'Find'
  }

  // Filter the list based on the status property
  return allConnections.where((item) => item.status == activeFilter).toList();
});
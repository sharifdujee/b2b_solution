import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/notification_state_model.dart';
// Import your model file here

class NotificationNotifier extends StateNotifier<List<NotificationStateModel>> {
  // Initialize with dummy data
  NotificationNotifier() : super([
    NotificationStateModel(
      title: "Order Shipped",
      subTitle: "Your package is on its way!",
      createAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: true,
    ),
    NotificationStateModel(
      title: "Received An order",
      subTitle: "Get an Order from ...",
      createAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationStateModel(
      title: "New Ping Request",
      subTitle: "New Ping Request from ...",
      createAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationStateModel(
      title: "New Ping Request",
      subTitle: "New Ping Request from ...",
      createAt: DateTime.now().subtract(const Duration(days: 9)),
      isRead: false,
    ),
  ]);

  // Method to add a notification
  void addNotification(NotificationStateModel notification) {
    // We spread the existing list and add the new one to ensure a new reference
    state = [...state, notification];
  }

  // Method to remove a notification by index
  void removeNotification(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationStateModel>>((ref) {
  return NotificationNotifier();
});
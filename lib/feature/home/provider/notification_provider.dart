import 'dart:developer';

import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../model/notification_model.dart';
import '../model/notification_state_model.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());

  final NetworkCaller networkCaller = NetworkCaller();

  /// Fetch Notifications with filter
  /// [filter] can be "all", "true", or "false"
  Future<void> fetchNotifications({String filter = "all", int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final String isReadParam = filter == "all" ? "" : filter;

      // Constructing the URL with params
      final String url = AppUrl.notifications(page, limit, isReadParam);

      var response = await networkCaller.getRequest(
        url,
        token: AuthService.token,
      );

      if (response.isSuccess && response.responseData != null) {
        final result = response.responseData['result'];

        if (result != null) {
          // Properly parse the list using your model's fromJson
          final List<NotificationData> fetchedList = (result['data'] as List)
              .map((e) => NotificationData.fromJson(e))
              .toList();

          final Meta meta = Meta.fromJson(result['meta']);

          state = state.copyWith(
            notifications: fetchedList,
            pagination: meta,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            notifications: [],
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Failed to fetch notifications",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred: $e",
      );
    }
  }

// --- Toggle All Notifications ---
  Future<void> toggleAllReadStatus(bool status) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      var response = await networkCaller.patchRequest(
        AppUrl.markAllAsReadNotification,
        token: AuthService.token,
        body: {'isRead': status},
      );

      if (response.isSuccess && response.responseData != null) {
        // Instead of manual mapping, we use the model's fromJson on the response result
        final result = response.responseData['result'];
        if (result != null) {
          final List<NotificationData> fetchedList = (result['data'] as List)
              .map((e) => NotificationData.fromJson(e))
              .toList();
          final Meta meta = Meta.fromJson(result['meta']);

          state = state.copyWith(
            notifications: fetchedList,
            pagination: meta,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Failed to update",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await networkCaller.getRequest(
        AppUrl.singleNotificationRead(id),
        token: AuthService.token,
      );

      if (response.isSuccess) {
        fetchNotifications();
      }
    } catch (e) {
      log("Error marking as read: $e");
    }
  }

  void removeNotification(String id) {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final notificationProvider = StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
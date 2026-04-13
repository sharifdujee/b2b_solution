import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Changed to standard riverpod
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

  Future<void> markAllAsRead() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      var response = await networkCaller.patchRequest(
        AppUrl.markAllAsReadNotification,
        token: AuthService.token,
        body: {
          'isRead': true,
        },
      );

      if (response.isSuccess && response.responseData != null) {
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
        } else {
          state = state.copyWith(
            notifications: [],
            isLoading: false,
          );
        }

      }else{
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Failed to fetch notifications",
        );
      }

    }catch(e){
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred: $e",
      );
    }
  }

  // --- Mark a specific notification as read in the UI ---
  void markAsReadLocally(String id) {
    state = state.copyWith(isLoading: true);

    try {
      final response = networkCaller.getRequest(
        AppUrl.singleNotificationRead(id),
        token: AuthService.token,
      );
      state = state.copyWith(isLoading: false);



    }catch(e){

      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred: $e",
      );
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
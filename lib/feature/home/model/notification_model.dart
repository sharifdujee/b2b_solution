import 'notification_state_model.dart';

class NotificationState {
  final bool isLoading;
  final String? errorMessage;
  final List<NotificationData> notifications;
  final Meta? pagination;

  NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.notifications = const [],
    this.pagination,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<NotificationData>? notifications,
    Meta? pagination,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
    );
  }
}
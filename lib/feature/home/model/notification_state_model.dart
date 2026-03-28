class NotificationStateModel {
  final String title;
  final String subTitle;
  final DateTime createAt;
  final bool isRead;

  NotificationStateModel({
    required this.title,
    required this.subTitle,
    required this.createAt,
    this.isRead = false,
  });

  String get formattedTime {
    final now = DateTime.now();
    final duration = now.difference(createAt);

    if (duration.inSeconds < 60) {
      return 'Now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} h ago';
    } else if (duration.inDays == 1) {
      return 'Yesterday';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} days ago';
    } else {
      return "${createAt.day}/${createAt.month}/${createAt.year}";
    }
  }

  NotificationStateModel copyWith({
    String? title,
    String? subTitle,
    DateTime? createAt,
    bool? isRead,
  }) {
    return NotificationStateModel(
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      createAt: createAt ?? this.createAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
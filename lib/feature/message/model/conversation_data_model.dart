


import 'chat_message.dart';

class Conversation {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.messages = const [],
  });

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastTime,
    int? unreadCount,
    List<ChatMessage>? messages,
  }) =>
      Conversation(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        lastMessage: lastMessage ?? this.lastMessage,
        lastTime: lastTime ?? this.lastTime,
        unreadCount: unreadCount ?? this.unreadCount,
        messages: messages ?? this.messages,
      );
}
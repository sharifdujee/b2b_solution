

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
    id: id,
    text: text,
    isMe: isMe,
    timestamp: timestamp,
    status: status ?? this.status,
  );
}
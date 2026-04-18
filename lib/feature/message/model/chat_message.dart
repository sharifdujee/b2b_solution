

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String id;
  final String text;
  final String? imageUrl; // Add this field
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.isMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
    id: id,
    text: text,
    imageUrl: imageUrl,
    isMe: isMe,
    timestamp: timestamp,
    status: status ?? this.status,
  );
}
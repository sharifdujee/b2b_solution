import '../../model/conversation_data_model.dart';
import '../../model/chat_message.dart';

class MessagesState {
  final List<ConversationResult> conversations;
  final Map<String, List<ChatMessage>> roomMessages;
  final String searchQuery;
  final bool isLoading;

  const MessagesState({
    required this.conversations,
    this.roomMessages = const {},
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<ConversationResult> get filtered {
    if (searchQuery.trim().isEmpty) return conversations;

    final q = searchQuery.toLowerCase();

    return conversations.where((c) {
      final nameMatch = c.partner.fullName.toLowerCase().contains(q);

      // ← null-safe: skip message match if lastMessage is null
      final messageMatch = c.lastMessage?.content.toLowerCase().contains(q) ?? false;

      final businessMatch =
          c.partner.businessName?.toString().toLowerCase().contains(q) ?? false;

      return nameMatch || messageMatch || businessMatch;
    }).toList();
  }

  /// Returns messages for a specific room, sorted oldest → newest
  List<ChatMessage> messagesForRoom(String roomId) {
    final msgs = roomMessages[roomId] ?? [];
    return List<ChatMessage>.from(msgs)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  MessagesState copyWith({
    List<ConversationResult>? conversations,
    Map<String, List<ChatMessage>>? roomMessages,
    String? searchQuery,
    bool? isLoading,
  }) =>
      MessagesState(
        conversations: conversations ?? this.conversations,
        roomMessages: roomMessages ?? this.roomMessages,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );
}
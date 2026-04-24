import '../../model/conversation_data_model.dart';
import '../../model/chat_message.dart';
import '../../model/room_message_data_model.dart'; // ← import Meta

class MessagesState {
  final List<ConversationResult> conversations;
  final Map<String, List<ChatMessage>> roomMessages;
  final Map<String, MessageMeta> roomMeta;         // ← pagination meta per room
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMessages;             // ← for pagination loader

  const MessagesState({
    required this.conversations,
    this.roomMessages = const {},
    this.roomMeta = const {},               // ← default empty
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMessages = false,         // ← default false
  });

  List<ConversationResult> get filtered {
    if (searchQuery.trim().isEmpty) return conversations;

    final q = searchQuery.toLowerCase();

    return conversations.where((c) {
      final nameMatch = c.partner.fullName.toLowerCase().contains(q);
      final messageMatch =
          c.lastMessage?.content.toLowerCase().contains(q) ?? false;
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

  /// Returns true if there are more pages to load for a room
  bool hasMorePages(String roomId) {
    final meta = roomMeta[roomId];
    if (meta == null) return false;
    return meta.page < meta.totalPages;
  }

  /// Returns the current loaded page for a room
  int currentPage(String roomId) {
    return roomMeta[roomId]?.page ?? 0;
  }

  MessagesState copyWith({
    List<ConversationResult>? conversations,
    Map<String, List<ChatMessage>>? roomMessages,
    Map<String, MessageMeta>? roomMeta,            // ← added
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMessages,                // ← added
  }) =>
      MessagesState(
        conversations: conversations ?? this.conversations,
        roomMessages: roomMessages ?? this.roomMessages,
        roomMeta: roomMeta ?? this.roomMeta,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      );
}
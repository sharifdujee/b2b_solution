import '../../model/conversation_data_model.dart';
import '../../model/chat_message.dart'; // Ensure this is imported

class MessagesState {
  final List<ConversationResult> conversations;
  final Map<String, List<ChatMessage>> roomMessages; // New: Keyed by roomId
  final String searchQuery;
  final bool isLoading;

  const MessagesState({
    required this.conversations,
    this.roomMessages = const {}, // Initialize as empty map
    this.searchQuery = '',
    this.isLoading = false,
  });

  /// Local search logic remains the same, operating on the conversation list
  List<ConversationResult> get filtered {
    if (searchQuery.trim().isEmpty) return conversations;

    final q = searchQuery.toLowerCase();

    return conversations.where((c) {
      final nameMatch = c.partner.fullName.toLowerCase().contains(q);
      final messageMatch = c.lastMessage.content.toLowerCase().contains(q);
      final businessMatch =
          c.partner.businessName?.toString().toLowerCase().contains(q) ?? false;

      return nameMatch || messageMatch || businessMatch;
    }).toList();
  }

  MessagesState copyWith({
    List<ConversationResult>? conversations,
    Map<String, List<ChatMessage>>? roomMessages, // Add to copyWith
    String? searchQuery,
    bool? isLoading,
  }) =>
      MessagesState(
        conversations: conversations ?? this.conversations,
        roomMessages: roomMessages ?? this.roomMessages, // Handle map update
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );
}
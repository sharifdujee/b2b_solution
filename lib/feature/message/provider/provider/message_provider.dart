import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../model/chat_message.dart';
import '../../model/conversation_data_model.dart';
import '../state/message_state.dart';

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier() : super(MessagesState(conversations: []));

  /// Filters the conversation list based on a search query
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Sends a plain text message
  void sendMessage(String conversationId, String text) {
    if (text.trim().isEmpty) return;

    final msg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    _updateConversation(conversationId, msg, text.trim());
  }

  void sendImageMessage(String conversationId, File imageFile, String caption) {
    final msg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: caption.trim(),
      imageUrl: imageFile.path, // Store local path for immediate display
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final previewText = caption.isNotEmpty ? caption : "Sent an image";
    _updateConversation(conversationId, msg, previewText);
  }

  void _updateConversation(String conversationId, ChatMessage msg, String lastMsg) {
    final updatedConversations = state.conversations.map((c) {
      if (c.id != conversationId) return c;

      return c.copyWith(
        messages: [...c.messages, msg],
        lastMessage: lastMsg,
        lastTime: DateTime.now(),
        unreadCount: 0,
      );
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  void markAsRead(String conversationId) {
    final updatedConversations = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(unreadCount: 0);
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>(
      (ref) => MessagesNotifier(),
);

final conversationProvider = Provider.family<Conversation?, String>((ref, id) {
  final conversations = ref.watch(messagesProvider).conversations;

  return conversations.cast<Conversation?>().firstWhere(
        (c) => c?.id == id,
    orElse: () => null,
  );
});
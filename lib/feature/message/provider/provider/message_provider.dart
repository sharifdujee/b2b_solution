import 'dart:convert';
import 'dart:io';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/service/socket_service.dart';
import '../../model/conversation_data_model.dart';
import '../../model/chat_message.dart';
import '../state/message_state.dart';

class MessagesNotifier extends StateNotifier<MessagesState> {
  // Use your custom SocketService instead of the raw dart:io WebSocket
  final SocketService _socketService = SocketService();

  MessagesNotifier() : super(const MessagesState(conversations: [])) {
    _connectAndLoad();
  }

  // --- Socket Connection Logic ---

  Future<void> _connectAndLoad() async {
    state = state.copyWith(isLoading: true);

    final token = AuthService.token ?? '';
    final currentUserId = AuthService.id ?? '';

    // 1. Initialize Connection
    await _socketService.connect(AppUrl.socketUrl, token);

    // 2. Setup Listener
    _socketService.setOnMessageReceived((String rawJson) {
      try {
        final Map<String, dynamic> data = jsonDecode(rawJson);

        // We only process if it's an actual message update
        // You may need to check data['type'] based on your server's logic
        final incomingMsg = ChatMessage.fromJson(data, currentUserId: currentUserId);
        _handleIncomingMessage(incomingMsg);
      } catch (e) {
        // Log errors or ignore system messages (like 'connected' types)
      }
    });

    state = state.copyWith(isLoading: false);
  }

  /// Handles messages pushed from the server
  void _handleIncomingMessage(ChatMessage msg) {
    final newLastMsg = LastMessage(
      content: msg.content,
      createdAt: msg.createdAt,
      type: msg.messageType,
      senderId: msg.senderId,
    );

    final updatedConversations = state.conversations.map((c) {
      if (c.roomId != msg.roomId) return c;

      return ConversationResult(
        roomId: c.roomId,
        roomType: c.roomType,
        partner: c.partner,
        lastMessage: newLastMsg,
        unreadCount: !msg.isMe ? c.unreadCount + 1 : 0,
        updatedAt: msg.createdAt,
      );
    }).toList();

    // Re-sort so the active chat jumps to the top
    updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(conversations: updatedConversations);
  }

  // --- Message Actions ---

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void sendMessage(String roomId, String text, String currentUserId) {
    if (text.trim().isEmpty) return;

    final newLastMessage = LastMessage(
      content: text.trim(),
      createdAt: DateTime.now(),
      type: "TEXT",
      senderId: currentUserId,
    );

    // 1. Optimistic UI Update
    _updateConversationLocally(roomId, newLastMessage);

    // 2. Send via SocketService
    _socketService.sendMessage({
      'type': 'sendMessage', // Check if your backend expects this 'type' key
      'roomId': roomId,
      'content': text.trim(),
      'messageType': 'TEXT',
    });
  }

  void sendImageMessage(String roomId, File imageFile, String caption, String currentUserId) {
    final previewText = caption.isNotEmpty ? caption : "Sent an image";

    final newLastMessage = LastMessage(
      content: previewText,
      createdAt: DateTime.now(),
      type: "IMAGE",
      senderId: currentUserId,
    );

    _updateConversationLocally(roomId, newLastMessage);

    // Note: Image upload logic usually happens via HTTP MultiPart
    // before sending the URL via the socket.
  }

  void _updateConversationLocally(String roomId, LastMessage lastMsg) {
    final updatedConversations = state.conversations.map((c) {
      if (c.roomId != roomId) return c;

      return ConversationResult(
        roomId: c.roomId,
        roomType: c.roomType,
        partner: c.partner,
        lastMessage: lastMsg,
        unreadCount: 0,
        updatedAt: DateTime.now(),
      );
    }).toList();

    updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(conversations: updatedConversations);
  }

  void markAsRead(String roomId) {
    final currentUserId = AuthService.id ?? '';

    // 1. Notify backend using your service's specific method
    _socketService.viewMessage(roomId, currentUserId);

    // 2. Update local state
    final updatedConversations = state.conversations.map((c) {
      if (c.roomId != roomId) return c;
      return ConversationResult(
        roomId: c.roomId,
        roomType: c.roomType,
        partner: c.partner,
        lastMessage: c.lastMessage,
        unreadCount: 0,
        updatedAt: c.updatedAt,
      );
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  void setConversations(List<ConversationResult> conversations) {
    final sorted = List<ConversationResult>.from(conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(conversations: sorted, isLoading: false);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});

final conversationProvider = Provider.family<ConversationResult?, String>((ref, roomId) {
  final conversations = ref.watch(messagesProvider).conversations;

  try {
    return conversations.firstWhere((c) => c.roomId == roomId);
  } catch (_) {
    return null;
  }
});
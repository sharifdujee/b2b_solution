


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../model/chat_message.dart';
import '../../model/conversation_data_model.dart';
import '../state/message_state.dart';


final _now = DateTime.now();

final _seedConversations = [
  Conversation(
    id: '1',
    name: 'Sylvan Strosin',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    lastMessage: 'It is a long established fact that...',
    lastTime: _now.subtract(const Duration(hours: 1, minutes: 30)),
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm1',
        text: 'Hi Joe! Just wanted to check — how were the onions today?',
        isMe: false,
        timestamp: _now.subtract(const Duration(days: 1, hours: 3)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        text: 'Super fresh! Customers loved the burger special.',
        isMe: true,
        timestamp: _now.subtract(const Duration(days: 1, hours: 2, minutes: 50)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        text: 'Thanks again!',
        isMe: true,
        timestamp: _now.subtract(const Duration(days: 1, hours: 2, minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm4',
        text: 'So glad to hear!',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm5',
        text: 'Next week we\'re getting heirloom tomatoes — want first dibs?',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
    ],
  ),
  Conversation(
    id: '2',
    name: 'Luca Romano',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    lastMessage: 'It is a long established fact',
    lastTime: _now.subtract(const Duration(hours: 9)),
    unreadCount: 3,
    messages: [
      ChatMessage(
        id: 'm6',
        text: 'Hey Luca, are the weekly orders confirmed?',
        isMe: true,
        timestamp: _now.subtract(const Duration(hours: 10)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm7',
        text: 'Yes! All confirmed. Delivery Thursday morning.',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 9, minutes: 30)),
      ),
      ChatMessage(
        id: 'm8',
        text: 'Perfect. Can you add 5kg of mozzarella to the order?',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 9, minutes: 10)),
      ),
      ChatMessage(
        id: 'm9',
        text: 'Also, do you have buffalo variety in stock?',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 9)),
      ),
    ],
  ),
  Conversation(
    id: '3',
    name: 'David Smith',
    avatarUrl: 'https://i.pravatar.cc/150?img=13',
    lastMessage: 'It is a long established fact that...',
    lastTime: _now.subtract(const Duration(hours: 21, minutes: 30)),
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm10',
        text: 'Morning David! Did the olive oil shipment arrive?',
        isMe: true,
        timestamp: _now.subtract(const Duration(days: 1)),
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: 'm11',
        text: 'Yes, got it this morning. Quality looks great!',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 22)),
      ),
    ],
  ),
  Conversation(
    id: '4',
    name: 'Carlos Gomez',
    avatarUrl: 'https://i.pravatar.cc/150?img=14',
    lastMessage: 'It is a long established fact',
    lastTime: _now.subtract(const Duration(hours: 12)),
    unreadCount: 4,
    messages: [
      ChatMessage(
        id: 'm12',
        text: 'Carlos, the invoice for last month is still pending.',
        isMe: true,
        timestamp: _now.subtract(const Duration(hours: 13)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm13',
        text: 'Sorry about the delay! Processing it right now.',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 12, minutes: 30)),
      ),
      ChatMessage(
        id: 'm14',
        text: 'Also wanted to ask — can we increase the order frequency?',
        isMe: false,
        timestamp: _now.subtract(const Duration(hours: 12, minutes: 15)),
      ),
    ],
  ),
];
class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier()
      : super(MessagesState(conversations: List.from(_seedConversations)));

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void sendMessage(String conversationId, String text) {
    if (text.trim().isEmpty) return;

    final msg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final updated = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(
        messages: [...c.messages, msg],
        lastMessage: text.trim(),
        lastTime: DateTime.now(),
        unreadCount: 0,
      );
    }).toList();

    state = state.copyWith(conversations: updated);
  }

  void markAsRead(String conversationId) {
    final updated = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(unreadCount: 0);
    }).toList();
    state = state.copyWith(conversations: updated);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final messagesProvider =
StateNotifierProvider<MessagesNotifier, MessagesState>(
      (ref) => MessagesNotifier(),
);

final conversationProvider =
Provider.family<Conversation?, String>((ref, id) {
  return ref
      .watch(messagesProvider)
      .conversations
      .cast<Conversation?>()
      .firstWhere((c) => c?.id == id, orElse: () => null);
});
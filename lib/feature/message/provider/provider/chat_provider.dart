import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/service/socket_service.dart';
import '../../../../core/service/network_caller.dart';
import '../../model/message_model.dart';
import '../state/chat_state.dart';


class ChatNotifier extends StateNotifier<ChatState> {
  final SocketService _socketService;
  final String roomId;
  final NetworkCaller _networkCaller = NetworkCaller();

  ChatNotifier(this._socketService, this.roomId) : super(ChatState()) {
    _init();
  }

  void _init() {
    fetchChatHistory();

    _socketService.setOnMessageReceived((data) {
      try {
        final Map<String, dynamic> messageMap = data is String ? jsonDecode(data) : data;
        final newMessage = Message.fromJson(messageMap);

        if (newMessage.roomId == roomId) {
          _addNewMessage(newMessage);
        }
      } catch (e) {
        print("Socket Data Error: $e");
      }
    });
  }

  Future<void> fetchChatHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _networkCaller.getRequest("AppUrl.chatHistory/$roomId");

      if (response.isSuccess && response.responseData != null) {
        final List<Message> fetchedList = (response.responseData['data'] as List)
            .map((e) => Message.fromJson(e))
            .toList();

        state = state.copyWith(messages: fetchedList, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: response.errorMessage);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _addNewMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final payload = {
      "type": "send-message",
      "roomId": roomId,
      "text": text,
      "createdAt": DateTime.now().toIso8601String(),
    };

    _socketService.sendMessage(payload);
  }

  void updateMessageStatusLocally(String messageId, bool isRead) {
    final updatedList = [
      for (final m in state.messages)
        if (m.id == messageId) m.copyWith(isRead: isRead) else m
    ];

    state = state.copyWith(messages: updatedList);
  }
}


final socketServiceProvider = Provider((ref) => SocketService());


final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, roomId) {
  final socket = ref.watch(socketServiceProvider);
  return ChatNotifier(socket, roomId);
});

final individualMessageProvider = Provider.family<Message?, ({String roomId, String messageId})>((ref, arg) {
  final chat = ref.watch(chatProvider(arg.roomId));

  try {
    return chat.messages.firstWhere((m) => m.id == arg.messageId);
  } catch (e) {
    return null;
  }
});
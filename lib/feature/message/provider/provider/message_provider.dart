import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:b2b_solution/core/service/app_url.dart';
import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/core/service/network_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/service/socket_service.dart';
import '../../model/conversation_data_model.dart';
import '../../model/chat_message.dart';
import '../state/message_state.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class MessagesNotifier extends StateNotifier<MessagesState> {
  final SocketService _socketService = SocketService();
  final ImagePicker imagePicker = ImagePicker();
  final NetworkCaller networkCaller = NetworkCaller();

  MessagesNotifier() : super(const MessagesState(conversations: [])) {
    _connectAndLoad();
  }

  /// image upload functionality
  Future<void> uploadChatImage() async {
    try {
      var response = await networkCaller.postRequest(
        AppUrl.uploadImage,
        body: {},
        token: "Bearer ${AuthService.token}",
      );
      if (response.isSuccess) {
        log("the image upload is complete");
      }
    } catch (e) {
      log("the exception is ${e.toString()}");
    }
  }

  Future<void> sendImageMessage(
    String roomId,
    File imageFile,
    String caption,
    String currentUserId,
  ) async {
    final previewText = caption.isNotEmpty ? caption : 'Sent an image';

    // 1. Optimistic conversation update
    _updateConversationLocally(
      roomId,
      LastMessage(
        content: previewText,
        createdAt: DateTime.now(),
        type: 'IMAGE',
        senderId: currentUserId,
      ),
    );

    try {
      // 2. Upload image via multipart HTTP
      final uploadedUrls = await _uploadImages([imageFile]);

      if (uploadedUrls.isEmpty) {
        log('Image upload failed: no URLs returned');
        return;
      }

      // 3. Send message via socket with fileUrl
      _socketService.sendMessage({
        'type': 'send-message',
        'roomId': roomId,
        'content': caption.trim(),
        'fileUrl': uploadedUrls, // ← attach uploaded URLs
      });

      log('Image message sent with URLs: $uploadedUrls');
    } catch (e) {
      log('Image upload error: $e');
    }
  }

  /// Uploads one or more images and returns their URLs
  Future<List<String>> _uploadImages(List<File> images) async {
    try {
      final uri = Uri.parse(AppUrl.uploadImage); // POST /chat/upload-files

      final request = http.MultipartRequest('POST', uri);

      // Auth header
      request.headers['Authorization'] = AuthService.token ?? '';

      // Attach each file under key 'files' with any mime type
      for (final image in images) {
        final mimeType =
            lookupMimeType(image.path) ?? 'application/octet-stream';
        final mimeParts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // ← key name from API
            image.path,
            contentType: http.MediaType(
              mimeParts[0],
              mimeParts[1],
            ), // ← any format
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Upload response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        // Adjust based on your actual API response shape
        // Common shapes: { "urls": [...] } or { "data": [...] } or { "files": [...] }
        final List<dynamic> urls = decoded['result'] ?? [];

        return urls.map((e) => e.toString()).toList();
      } else {
        log('Upload failed: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      log('Upload exception: $e');
      return [];
    }
  }

  Future<void> _connectAndLoad() async {
    state = state.copyWith(isLoading: true);
    final token = AuthService.token ?? '';
    final currentUserId = AuthService.id ?? '';

    await _socketService.connect(AppUrl.socketUrl, token);

    _socketService.setOnMessageReceived((String rawJson) {
      try {
        final Map<String, dynamic> data = jsonDecode(rawJson);
        final type = data['type'];

        if (type == 'conversations') {
          final List<dynamic> list = data['conversations'];
          final conversations = list
              .map(
                (e) => ConversationResult.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          setConversations(conversations);
        } else if (type == 'room-subscribed') {
          final String roomId = data['roomId'];
          final List<dynamic> initialList = data['initialMessages'] ?? [];

          final messages = initialList
              .map(
                (e) => ChatMessage.fromJson(
                  e as Map<String, dynamic>,
                  currentUserId: currentUserId,
                  fallbackRoomId:
                      roomId, // ← fixes missing roomId & messageType
                ),
              )
              .toList();

          _setRoomMessages(roomId, messages);
        } else if (type == 'message-sent' || type == 'new-message') {
          final msgData = data['message'] as Map<String, dynamic>?;
          if (msgData == null) return;

          final incomingMsg = ChatMessage.fromJson(
            msgData,
            currentUserId: currentUserId,
          );
          _handleIncomingMessage(incomingMsg);
          _addMessageToRoom(incomingMsg);
        }
      } catch (e) {
        log('Socket parse error: $e');
      }
    });

    state = state.copyWith(isLoading: false);
  }

  // --- Room Message Helpers ---

  void _setRoomMessages(String roomId, List<ChatMessage> messages) {
    final updatedMap = Map<String, List<ChatMessage>>.from(state.roomMessages);
    updatedMap[roomId] = messages;
    state = state.copyWith(roomMessages: updatedMap);
  }

  void _addMessageToRoom(ChatMessage msg) {
    final updatedMap = Map<String, List<ChatMessage>>.from(state.roomMessages);
    final existing = List<ChatMessage>.from(updatedMap[msg.roomId] ?? []);

    // Avoid duplicates by id
    if (!existing.any((m) => m.id == msg.id)) {
      existing.add(msg);
      updatedMap[msg.roomId] = existing;
      state = state.copyWith(roomMessages: updatedMap);
    }
  }



  void _handleIncomingMessage(ChatMessage msg) {
    // ← Use proper preview for image messages
    final previewContent =
        msg.messageType.toUpperCase() == 'IMAGE' ||
            msg.messageType.toUpperCase() == 'MEDIA'
        ? '📷 Photo'
        : msg.content;

    final newLastMsg = LastMessage(
      content: previewContent,
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

    updatedConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(conversations: updatedConversations);
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

  // --- Public Actions ---

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void joinRoom(String roomId) {
    _socketService.joinRoom(roomId);
  }

  void sendMessage(String roomId, String text, String currentUserId) {
    if (text.trim().isEmpty) return;

    // 1. Optimistic conversation update
    _updateConversationLocally(
      roomId,
      LastMessage(
        content: text.trim(),
        createdAt: DateTime.now(),
        type: 'TEXT',
        senderId: currentUserId,
      ),
    );

    // 2. Send via socket
    _socketService.sendMessage({
      'type': 'send-message',
      'roomId': roomId,
      'content': text.trim(),
    });
  }

  /* void sendImageMessage(
      String roomId,
      File imageFile,
      String caption,
      String currentUserId,
      ) {
    final previewText = caption.isNotEmpty ? caption : 'Sent an image';

    _updateConversationLocally(
      roomId,
      LastMessage(
        content: previewText,
        createdAt: DateTime.now(),
        type: 'IMAGE',
        senderId: currentUserId,
      ),
    );

    // Image upload via HTTP multipart happens here before sending URL via socket
  }*/

  void markAsRead(String roomId) {
    final currentUserId = AuthService.id ?? '';

    // 1. Notify backend
    _socketService.viewMessage(roomId, currentUserId);

    // 2. Update local unread count
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

// --- Providers ---

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>(
  (ref) {
    return MessagesNotifier();
  },
);

final conversationProvider = Provider.family<ConversationResult?, String>((
  ref,
  roomId,
) {
  final conversations = ref.watch(messagesProvider).conversations;
  try {
    return conversations.firstWhere((c) => c.roomId == roomId);
  } catch (_) {
    return null;
  }
});

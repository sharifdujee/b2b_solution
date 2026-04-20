import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/chat_message.dart';
import '../../provider/provider/message_provider.dart';
import '../widget/chat_input_bar.dart';
import '../widget/chat_top_bar.dart';
import '../widget/date_divider.dart';
import '../widget/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;

  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onImageSelected(File image) {
    setState(() => _selectedImage = image);
    _scrollToBottom();
  }

  void _clearSelectedImage() {
    setState(() => _selectedImage = null);
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    // In a real app, get this from your AuthProvider
    const String currentUserId = "69c233654cf6dafe440358a1";

    if (text.isEmpty && _selectedImage == null) return;

    if (_selectedImage != null) {
      ref.read(messagesProvider.notifier).sendImageMessage(
        widget.roomId,
        _selectedImage!,
        text,
        currentUserId,
      );
    } else {
      ref.read(messagesProvider.notifier).sendMessage(
          widget.roomId,
          text,
          currentUserId
      );
    }

    _msgController.clear();
    _clearSelectedImage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uses the room ID to find the conversation result
    final convo = ref.watch(conversationProvider(widget.roomId));

    if (convo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final messages = ref.watch(messagesProvider.select(
            (state) => state.roomMessages[widget.roomId] ?? []
    ));

    final grouped = _groupByDate(messages);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // Updated to pass ConversationResult
            ChatTopBar(conversation: convo),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final item = grouped[index];
                  if (item is String) return DateDivider(label: item);

                  final msg = item as ChatMessage;
                  final prevItem = index > 0 ? grouped[index - 1] : null;
                  final prevMsg = prevItem is ChatMessage ? prevItem : null;

                  final showAvatar = !msg.isMe &&
                      (prevMsg == null || prevMsg.isMe || prevItem is String);

                  return MessageBubble(
                    message: msg,
                    showAvatar: showAvatar,
                  );
                },
              ),
            ),

            ChatInputBar(
              controller: _msgController,
              onSend: _sendMessage,
              selectedImage: _selectedImage,
              onImagePicked: _onImageSelected,
              onClearImage: _clearSelectedImage,
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _groupByDate(List<ChatMessage> messages) {
    final result = <dynamic>[];
    String? lastDate;

    final sortedMessages = List<ChatMessage>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final msg in sortedMessages) {
      final dateLabel = _dateLabel(msg.createdAt);
      if (dateLabel != lastDate) {
        result.add(dateLabel);
        lastDate = dateLabel;
      }
      result.add(msg);
    }
    return result;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
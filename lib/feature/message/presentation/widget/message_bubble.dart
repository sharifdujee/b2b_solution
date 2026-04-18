import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../model/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final String avatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.avatarUrl,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  String _statusText(MessageStatus s) {
    switch (s) {
      case MessageStatus.sent: return 'Sent';
      case MessageStatus.delivered: return 'Delivered';
      case MessageStatus.read: return 'Read';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;
    final hasText = message.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? CircleAvatar(
              radius: 16.r,
              backgroundImage: NetworkImage(avatarUrl),
            )
                : SizedBox(width: 32.w),
            SizedBox(width: 8.w),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 260.w),
              // Reduced vertical padding if there's an image to let the image hit the edges
              padding: EdgeInsets.all(hasImage ? 4.r : 12.r),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2D6A4F) : AppColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- IMAGE CONTENT ---
                  if (hasImage)
                    Padding(
                      padding: EdgeInsets.only(bottom: hasText ? 6.h : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _buildImage(message.imageUrl!),
                      ),
                    ),

                  // --- TEXT CONTENT ---
                  if (hasText)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isMe ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // --- TIMESTAMP & STATUS ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        isMe
                            ? '${_formatTime(message.timestamp)} · ${_statusText(message.status)}'
                            : _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10.sp, // Slightly smaller for dense bubbles
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 18.sp, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    // Support for both Local Files (during upload) and Network URLs
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150.h,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
      );
    }
  }
}
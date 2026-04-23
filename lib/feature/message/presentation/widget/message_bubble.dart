import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../model/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    // Check if there are any files and if the type is IMAGE (or just check list length)
    final hasImage = message.fileUrl.isNotEmpty;
    final hasText = message.content.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- PARTNER AVATAR ---
          if (!isMe) ...[
            showAvatar
                ? CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: message.sender.profileImage != null
                  ? NetworkImage(message.sender.profileImage!)
                  : null,
              child: message.sender.profileImage == null
                  ? Icon(Icons.person, size: 16.sp, color: Colors.grey)
                  : null,
            )
                : SizedBox(width: 32.w),
            SizedBox(width: 8.w),
          ],

          Flexible(
            child: Container(
              // ← Remove constraints entirely, let content define the size
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
              child: IntrinsicWidth(   // ← makes width wrap content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // ← timestamp aligns correctly
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- IMAGE CONTENT ---
                    if (hasImage)
                      Padding(
                        padding: EdgeInsets.only(bottom: hasText ? 6.h : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: _buildImage(message.fileUrl.first.toString()),
                        ),
                      ),

                    // --- TEXT CONTENT ---
                    if (hasText)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isMe ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),

                    // --- TIMESTAMP ---
                    Padding(
                      padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 4.h),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10.sp,
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
          ),

          // --- MY AVATAR (Optional) ---
          if (isMe) ...[
            SizedBox(width: 8.w),
            showAvatar
                ? CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: message.sender.profileImage != null
                  ? NetworkImage(message.sender.profileImage!)
                  : null,
              child: message.sender.profileImage == null
                  ? Icon(Icons.person, size: 16.sp, color: Colors.grey)
                  : null,
            )
                : SizedBox(width: 32.w),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150.h,
          width: double.infinity,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
      );
    }
  }
}
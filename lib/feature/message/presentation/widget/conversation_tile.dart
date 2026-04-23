import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/conversation_data_model.dart';

class ConversationTile extends ConsumerWidget {
  // Pass the individual result item instead of the whole model
  final ConversationResult conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays >= 1) {
      return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
    }

    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar with Fallback
            CircleAvatar(
              radius: 26.r,
              backgroundImage: conversation.partner.profileImage != null
                  ? NetworkImage(conversation.partner.profileImage!)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: conversation.partner.profileImage == null
                  ? Icon(Icons.person, color: Colors.grey, size: 30.r)
                  : null,
            ),

            SizedBox(width: 12.w),

            // Name + Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.partner.fullName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getLastMessagePreview(conversation.lastMessage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: conversation.unreadCount > 0
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Time + Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: _formatTime(conversation.updatedAt),
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
                SizedBox(height: 6.h),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: EdgeInsets.all(4.w),
                    constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.h),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${conversation.unreadCount}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColor.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                // Keeps layout consistent when there is no badge
                  SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLastMessagePreview(LastMessage? lastMessage) {
    if (lastMessage == null) return 'No messages yet';

    switch (lastMessage.type.toUpperCase()) {
      case 'MEDIA':
      case 'IMAGE':
        return '📷 Photo';
      case 'VIDEO':
        return '🎥 Video';
      case 'FILE':
        return '📎 File';
      default:
        return lastMessage.content.isNotEmpty
            ? lastMessage.content
            : 'No messages yet';
    }
  }
}
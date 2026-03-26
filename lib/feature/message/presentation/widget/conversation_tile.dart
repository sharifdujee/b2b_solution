import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/conversation_data_model.dart';


class ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 1) {
      return '${dt.day}/${dt.month}';
    }
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute\n$period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26.r,
              backgroundImage: NetworkImage(conversation.avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),

            SizedBox(width: 12.w),

            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastMessage,
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

            // Time + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(conversation.lastTime),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                if (conversation.unreadCount > 0)
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D7A5E), // green accent
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        '${conversation.unreadCount}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
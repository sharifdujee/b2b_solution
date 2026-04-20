import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/design_system/app_color.dart';
import '../../model/conversation_data_model.dart';

class ChatTopBar extends StatelessWidget {
  // Use ConversationResult to access the specific partner info
  final ConversationResult conversation;

  const ChatTopBar({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // Adjusted padding for a cleaner look in the header
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 10.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.arrow_back, size: 24.sp, color: Colors.black87),
          ),

          SizedBox(width: 12.w),

          // Avatar with Null Safety
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: conversation.partner.profileImage != null
                ? NetworkImage(conversation.partner.profileImage!)
                : null,
            child: conversation.partner.profileImage == null
                ? Icon(Icons.person, size: 20.sp, color: Colors.grey)
                : null,
          ),

          SizedBox(width: 12.w),

          // Name and Room Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.partner.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                // Optional: Show business name if available
                if (conversation.partner.businessName != null)
                  Text(
                    conversation.partner.businessName.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // PING button
          InkWell(
            onTap: () {
              // Handle Ping action
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C842),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'PING',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
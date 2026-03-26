import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';
import '../../model/conversation_data_model.dart';
import '../screen/message_screen.dart';


class ChatTopBar extends StatelessWidget {
  final Conversation conversation;
  const ChatTopBar({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(Icons.arrow_back, size: 22.sp, color: Colors.black87),
          ),

          SizedBox(width: 10.w),

          // Avatar
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(conversation.avatarUrl),
          ),

          SizedBox(width: 10.w),

          // Name
          Expanded(
            child: Text(
              conversation.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // PING button
          Container(
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
        ],
      ),
    );
  }
}
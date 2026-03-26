import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_color.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
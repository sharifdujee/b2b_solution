import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../provider/provider/message_provider.dart';

class ConversationSearchBar extends StatefulWidget {
  final MessagesNotifier notifier;

  const ConversationSearchBar({
    super.key,
    required this.notifier,
  });

  @override
  State<ConversationSearchBar> createState() => _ConversationSearchBarState();
}

class _ConversationSearchBarState extends State<ConversationSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {}); // rebuild to show/hide clear button
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, size: 20.sp, color: Colors.grey.shade500),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: widget.notifier.search,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                widget.notifier.search('');
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../provider/provider/message_provider.dart';

// Changed to ConsumerStatefulWidget to access "ref"
class ConversationSearchBar extends ConsumerStatefulWidget {
  const ConversationSearchBar({super.key});

  @override
  ConsumerState<ConversationSearchBar> createState() => _ConversationSearchBarState();
}

class _ConversationSearchBarState extends ConsumerState<ConversationSearchBar> {
  final TextEditingController _searchController = TextEditingController();

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
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, size: 20.sp, color: Colors.grey.shade500),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              // Use ref.read to access the notifier and call search
              onChanged: (value) {
                ref.read(messagesProvider.notifier).search(value);
              },
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

          // ValueListenableBuilder is more efficient than calling setState()
          // on every keystroke just for the clear button
          ValueListenableBuilder(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(messagesProvider.notifier).search('');
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
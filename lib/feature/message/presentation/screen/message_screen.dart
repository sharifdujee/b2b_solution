
import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/feature/message/presentation/widget/conversation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../provider/provider/message_provider.dart';
import '../widget/conversation_tile.dart';
import 'chat_screen.dart';










class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final notifier = ref.read(messagesProvider.notifier);
    final filtered = state.filtered;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: CustomText(
                text: 'Message',
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 16.h),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConversationSearchBar(notifier: notifier),
            ),

            SizedBox(height: 8.h),

            // ── Conversation list ────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: CustomText(
                  text: 'No conversations found',
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final convo = filtered[index];
                  return ConversationTile(
                    conversation: convo,
                    onTap: () {
                      notifier.markAsRead(convo.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProviderScope(
                            child: ChatScreen(conversationId: convo.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}


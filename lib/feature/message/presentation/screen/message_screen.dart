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
  // Logic to initialize socket on screen entry
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to perform side effects after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If your initSocket logic is inside _connectAndLoad in the constructor, 
      // you might not need this. Otherwise, call it here.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watching the state ensures the list rebuilds when search query or conversations change
    final state = ref.watch(messagesProvider);
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
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 16.h),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConversationSearchBar(),
            ),

            SizedBox(height: 24.h),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1, color: AppColor.grey50),
            ),

            // ── Conversation list ────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
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
                  return Column(
                    children: [
                      ConversationTile(
                        conversation: convo,
                        onTap: () {
                          // 1. Mark room as read
                          ref.read(messagesProvider.notifier).markAsRead(convo.roomId);

                          // 2. Subscribe/join the room before navigating
                          ref.read(messagesProvider.notifier).joinRoom(convo.roomId);

                          // 3. Navigate to ChatScreen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(roomId: convo.roomId),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(thickness: 1, color: AppColor.grey50),
                      ),
                    ],
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
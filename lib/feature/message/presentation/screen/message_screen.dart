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

// ... existing imports ...

class _MessageScreenState extends ConsumerState<MessageScreen> {
  @override
  void initState() {
    super.initState();
    // It's good practice to ensure data is loaded when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider.notifier).initSocket();
    });
  }

  @override
  Widget build(BuildContext context) {
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

            // ── Conversation list with RefreshIndicator ─────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColor.primary, // Customize the loader color
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await ref.read(messagesProvider.notifier).initSocket();
                },
                child: state.isLoading && filtered.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? ListView(
                  children: [
                    SizedBox(height: 200.h),
                    Center(
                      child: CustomText(
                        text: 'No conversations found',
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  physics: const AlwaysScrollableScrollPhysics(), // Important for small lists
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final convo = filtered[index];
                    return Column(
                      children: [
                        ConversationTile(
                          conversation: convo,
                          onTap: () {
                            ref.read(messagesProvider.notifier).markAsRead(convo.roomId);
                            ref.read(messagesProvider.notifier).joinRoom(convo.roomId);
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
            ),
          ],
        ),
      ),
    );
  }
}
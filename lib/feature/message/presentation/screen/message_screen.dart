import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:b2b_solution/feature/message/presentation/widget/conversation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/conversation_data_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(messagesProvider.notifier);
      notifier.initSocket();
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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: CustomText(
                text: 'Message',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const ConversationSearchBar(),
            ),
            SizedBox(height: 24.h),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1, color: AppColor.grey50),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Cleanly reset connection on pull-to-refresh
                  await ref.read(messagesProvider.notifier).initSocket();
                },
                child: state.isLoading && filtered.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildList(filtered),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
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
    );
  }

  Widget _buildList(List<ConversationResult> filtered) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      physics: const AlwaysScrollableScrollPhysics(),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1, color: AppColor.grey50),
            ),
          ],
        );
      },
    );
  }
}
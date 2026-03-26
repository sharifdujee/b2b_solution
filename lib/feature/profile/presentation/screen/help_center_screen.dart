import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/local_assets/icon_path.dart';
import '../../provider/faq_provider.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqState = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Image.asset(IconPath.arrowLeft, height: 24.h, width: 24.w),
                  ),
                  SizedBox(width: 12.w),
                  CustomText(
                    text: "Help Center",
                    fontSize: 20.sp,
                    color: AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),

              SizedBox(height: 24.h),
              CustomText(
                text: "FAQs",
                fontSize: 20.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 16.h),

              // --- FAQ List ---
              Expanded( // FIXED: Added Expanded to prevent layout overflow
                child: faqState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: faqState.faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqState.faqs[index];
                    return _buildFaqItem(context, ref, faq);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, WidgetRef ref, dynamic faq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          // Removes the default splash/highlight from ListTile to match the clean design
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => ref.read(faqProvider.notifier).toggleFaq(faq.id),
            title: CustomText(
              text: faq.question,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B), // Slate 800
            ),
            trailing: Icon(
              faq.isExpanded
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: const Color(0xFF64748B), // Slate 500
              size: 24.sp,
            ),
          ),
        ),

        // Animated expansion for a smoother feel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: faq.isExpanded
              ? Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: CustomText(
              text: faq.answer,
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
              height: 1.5, // Better readability
            ),
          )
              : const SizedBox.shrink(),
        ),

        const Divider(thickness: 1),
      ],
    );
  }
}
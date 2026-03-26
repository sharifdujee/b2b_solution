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
              Divider(thickness: 0.5,),

              SizedBox(height: 24.h),
              CustomText(
                text: "FAQs",
                fontSize: 20.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 16.h),

              Expanded(
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
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => ref.read(faqProvider.notifier).toggleFaq(faq.id),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFF3F4F6), // Slate 200 (Matches the design)
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Question Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      text: faq.question,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black, // Slate 800
                    ),
                  ),
                  Icon(
                    faq.isExpanded
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: faq.isExpanded? AppColor.grey400 : AppColor.black,
                    size: 24.sp,
                  ),
                ],
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  children: [
                    SizedBox(height: 12.h),
                    const Divider(color: Color(0xFFF1F5F9)),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: faq.answer,
                      fontSize: 14.sp,
                      color: AppColor.grey600,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ],
                ),
                crossFadeState: faq.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
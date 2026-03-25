


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/app_color.dart';




class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffixIcon;
  final String? prefixIconPath;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool readonly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final int maxLines;
  final Color? containerColor;
  final Color? hintTextColor;
  final double? hintTextSize;
  final String? suffixText;
  final TextStyle? suffixTextStyle;
  final String? Function(String?)? validator;
  final double? borderRadius;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.prefixIconPath,
    this.prefixIcon,
    this.onChanged,
    this.readonly = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.maxLines = 1,
    this.containerColor = const Color(0xffF9FAFB),
    this.hintTextColor = AppColor.primaryDarker,
    this.hintTextSize = 15,
    this.suffixText,
    this.suffixTextStyle,
    this.validator,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      readOnly: readonly,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged, // ✅ FIXED
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: isDarkMode ? AppColor.white : AppColor.primaryDarker,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? const Color(0xff282828) : Colors.white,

        prefixIcon: prefixIcon ??
            (prefixIconPath != null
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Image.asset(
                prefixIconPath!,
                height: 24.h,
                width: 24.w,
              ),
            )
                : null),

        suffixIcon: suffixIcon,
        suffixText: suffixText,
        suffixStyle: suffixTextStyle ??
            GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColor.primaryLighter,
            ),

        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: hintTextSize?.sp ?? 15.sp,
          fontWeight: FontWeight.w400,
          color: hintTextColor,
        ),

        contentPadding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 12.w,
        ),

        border: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),

        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),

        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: const BorderSide(color: AppColor.primaryDarker),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          borderSide: const BorderSide(color: AppColor.primaryLighter),
        ),
      ),
    );
  }
}

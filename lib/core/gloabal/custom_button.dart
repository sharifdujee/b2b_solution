

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/app_color.dart';


class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  /// Background
  final Color? backgroundColor; // nullable for gradient
  final Gradient? backgroundGradient;

  /// Text
  final Color textColor;
  final TextStyle? textStyle;

  /// Border
  final Gradient? borderGradient; // gradient for border
  final double borderWidth;
  final double borderRadius;
  final bool isOutlined;
  final double? horizontalPadding;
  final double? verticalPadding;


  /// Shape & size
  final double height;
  final double width;
  final bool isCircle;

  /// Optional icons or image
  final IconData? suffixIcon;
  final Widget? image;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.backgroundGradient,
    this.textColor = AppColor.white,
    this.textStyle,
    this.borderGradient,
    this.borderWidth = 2.0,
    this.borderRadius = 45,
    this.height = 50,
    this.width = double.infinity,
    this.isOutlined = false,
    this.isCircle = false,
    this.suffixIcon,
    this.image,
    this.horizontalPadding,
    this.verticalPadding,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    if (widget.onPressed != null) setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final effectiveOpacity = isDisabled ? 0.55 : 1.0;

    /// Background
    final bgDecoration = widget.isOutlined
        ? null
        : (widget.backgroundGradient ??
        (widget.backgroundColor?.withValues(alpha: effectiveOpacity) ??
            AppColor.primaryLighter.withValues(alpha: effectiveOpacity)));

    /// Border gradient
    final effectiveBorderGradient = widget.borderGradient ??
        LinearGradient(
          colors: [
            (widget.backgroundColor ?? AppColor.primaryDarker)
                .withValues(alpha: effectiveOpacity),
            (widget.backgroundColor ?? AppColor.primaryLighter)
                .withValues(alpha: effectiveOpacity * 0.4),
          ],
        );

    final effectiveTextColor =
    isDisabled ? widget.textColor.withValues(alpha: 0.6) : widget.textColor;

    /// Button content (text + optional suffix icon/image)
    final buttonContent = widget.isCircle
        ? Center(
      child: widget.image ??
          (widget.suffixIcon != null
              ? Icon(
            widget.suffixIcon,
            color: effectiveTextColor,
            size: 20.sp,
          )
              : null),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text on left
        Text(
          widget.text,
          textAlign: TextAlign.center,
          style: widget.textStyle ??
              GoogleFonts.poppins(
                color: effectiveTextColor,
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
        ),
        // spacing if icon or image exists
        if (widget.suffixIcon != null || widget.image != null)
          SizedBox(width: 8.w),
        // Icon or Image on right
        if (widget.suffixIcon != null)
          Icon(
            widget.suffixIcon,
            size: 20.sp,
            color: effectiveTextColor,
          ),
        if (widget.image != null) widget.image!,
      ],
    );

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: effectiveOpacity,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: widget.height,
            width: widget.isCircle ? widget.height : widget.width,
            decoration: BoxDecoration(
              gradient: !widget.isOutlined && bgDecoration is Gradient
                  ? bgDecoration
                  : null,
              color: !widget.isOutlined && bgDecoration is Color
                  ? bgDecoration
                  : null,
              borderRadius: widget.isCircle
                  ? null
                  : BorderRadius.circular(widget.borderRadius),
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: widget.isOutlined
                ? Container(
              decoration: BoxDecoration(
                gradient: effectiveBorderGradient,
                borderRadius: widget.isCircle
                    ? null
                    : BorderRadius.circular(widget.borderRadius),
              ),
              padding: EdgeInsets.all(widget.borderWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.transparent,
                  borderRadius: widget.isCircle
                      ? null
                      : BorderRadius.circular(
                      widget.borderRadius - widget.borderWidth),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: widget.isCircle ? 0 : 5.r,
                  horizontal: widget.isCircle ? 0 : 20.w,
                ),
                child: buttonContent,
              ),
            )
                : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.horizontalPadding ?? 0.w,
                vertical: widget.verticalPadding ?? 0.h,
              ),
              child: Container(
                alignment: Alignment.center,
                child: buttonContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

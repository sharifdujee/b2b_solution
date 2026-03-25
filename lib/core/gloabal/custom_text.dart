



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppFont {
  inter,
  roboto,
  poppins,
  impact, // 👈 add this
}


class CustomText extends StatelessWidget {
  final String text;
  final AppFont font;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? height;
  final FontStyle? fontStyle;
  final TextDirection? textDirection;
  final TextBaseline? textBaseline;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Locale? locale;
  final bool? softWrap;

  const CustomText({
    super.key,
    required this.text,
    this.font = AppFont.inter, // 👈 default font
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.letterSpacing,
    this.height,
    this.fontStyle,
    this.textDirection,
    this.textBaseline,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.locale,
    this.softWrap,
  });

  TextStyle _getFontStyle() {
    switch (font) {
      case AppFont.impact:
        return const TextStyle(fontFamily: 'Impact');  // Use asset font here
      case AppFont.roboto:
        return GoogleFonts.roboto();
      case AppFont.poppins:
        return GoogleFonts.poppins();
      case AppFont.inter:
      default:
        return GoogleFonts.inter();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      softWrap: softWrap,
      style: _getFontStyle().copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        textBaseline: textBaseline,
        locale: locale,
      ),
    );
  }
}
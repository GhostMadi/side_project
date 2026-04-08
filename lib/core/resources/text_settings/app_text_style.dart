import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:sizer/sizer.dart';

class AppTextStyle {
  static TextStyle base(
    double size, {
    double? height,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) => TextStyle(
    fontSize: size.sp,
    color: color,
    fontFamily: 'Manrope',
    fontWeight: fontWeight ?? FontWeight.w300,
    height: height,
    letterSpacing: letterSpacing,
  );

  // Presets for consistent UI typography.
  static TextStyle titleLg() => base(19, fontWeight: FontWeight.w700, color: AppColors.textColor);
  static TextStyle titleMd() => base(16, fontWeight: FontWeight.w600, color: AppColors.textColor);
  static TextStyle bodyMd() => base(14, color: AppColors.textColor, height: 1.4);
  static TextStyle bodySubtle() => base(13, color: AppColors.subTextColor, height: 1.35);
}

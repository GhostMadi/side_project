import 'package:flutter/material.dart';
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
    letterSpacing: letterSpacing
  );
}

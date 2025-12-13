import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppTextStyle {
  static TextStyle style(double size, {Color? color, FontWeight? fontWeight}) =>
      TextStyle(
        fontSize: size.sp,
        color: color,
        fontFamily: 'Manrope',
        fontWeight: fontWeight ?? FontWeight.w300,
      );
}

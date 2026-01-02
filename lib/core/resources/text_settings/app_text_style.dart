import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppTextStyle {
  static TextStyle base(
    double size, {
    double? height,
    Color? color,
    FontWeight? weight,
  }) => TextStyle(
    fontSize: size.sp,
    color: color,
    fontFamily: 'Manrope',
    fontWeight: weight ?? FontWeight.w300,
    height: height,
  );
}

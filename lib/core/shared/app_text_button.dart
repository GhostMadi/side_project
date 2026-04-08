import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.color = AppColors.btnBackground,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed?.call();
            },
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
        textStyle: AppTextStyle.base(fontSize, fontWeight: fontWeight),
      ),
      child: Text(text),
    );
  }
}

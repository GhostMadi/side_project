import 'package:flutter/material.dart';
import 'package:side_project/core/resources/app_colors.dart';
import 'package:side_project/core/resources/app_text_style.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// если надо как на скрине — на всю ширину
  final bool ixExpanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.ixExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final style = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),

      // капсула
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      // размер как на скрине
      minimumSize: const WidgetStatePropertyAll(Size(0, 64)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 28),
      ),

      // цвета из appColors
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final disabled = states.contains(WidgetState.disabled);
        if (disabled) return colors.brand.withValues(alpha: 0.45);
        return colors.brand;
      }),

      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.0),
      ),
    );

    final button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.style(
          16,
          color: colors.secondary,
          fontWeight: FontWeight.w300,
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

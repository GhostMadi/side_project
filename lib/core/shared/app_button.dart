import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart'; // Только цвета через extension
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ЦВЕТА (Динамические, зависят от темы)
    final colors = context.appColors;

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      // 2. РАЗМЕРЫ (Статические, 12.w ≈ 48px)
      height: 60,
      width: isExpanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.brand, // Цвет бренда из темы
          foregroundColor:
              colors.secondary, // Цвет текста кнопки (черный/белый)

          elevation: 0,
          shadowColor: Colors.transparent,

          padding: isExpanded
              ? EdgeInsets.zero
              // Отступ Middle из статики
              : EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle),

          shape: RoundedRectangleBorder(
            // Радиус круга из статики
            borderRadius: BorderRadius.circular(AppDimensions.rCircle),
          ),

          // Цвета для выключенной кнопки
          disabledBackgroundColor: colors.fourth,
          disabledForegroundColor: colors.third,
        ),
        child: isLoading
            ? SizedBox(
                height: AppDimensions.iconMiddle,
                width: AppDimensions.iconMiddle,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
                ),
              )
            : Text(
                text,
                // 3. ШРИФТ (Статический конструктор + цвет из темы)
                style: AppTextStyle.base(
                  16,
                  weight: FontWeight.w300,
                  color: isEnabled ? colors.secondary : colors.third,
                ),
              ),
      ),
    );
  }
}

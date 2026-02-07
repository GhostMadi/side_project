import 'package:flutter/material.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Достаем палитру
    // final colors = context.appColors;

    // Хелпер для бордеров
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.rCircle),
        borderSide: BorderSide(color: color, width: 1.0),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,

      // Текст ввода
      // style: AppTextStyle.base(16, color: colors.secondary),
      // cursorColor: colors.brand,
      decoration: InputDecoration(
        hintText: hintText,

        // Текст подсказки (серый)
        // hintStyle: AppTextStyle.base(16, color: colors.third),
        filled: true,

        // fillColor: colors.primary, // Фон поля (Белый/Черный)
        contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMiddle, vertical: 16),

        suffixIcon: suffixIcon,

        // Состояния границ (цвета берем из темы)
        // enabledBorder: border(colors.third), // Серый бордюр
        // focusedBorder: border(colors.brand), // Брендовый при фокусе
        // errorBorder: border(colors.error),
        // focusedErrorBorder: border(colors.error),
      ),
    );
  }
}

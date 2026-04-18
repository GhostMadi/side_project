import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final double? radius;

  const AppTextField({
    super.key,
    required this.hintText,
    this.focusNode,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.inputFormatters,
    this.maxLines,
    this.minLines,
    this.autofocus = false,
    this.readOnly = false,
    this.contentPadding,
    this.radius,
  });

  static const double _radius = 12;

  /// То же значение, что и `contentPadding` по умолчанию — для выравнивания кастомных полей (напр. голос в чате).
  static const EdgeInsets defaultContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.inputBorder;
    final fill = AppColors.inputBackground;
    final effectiveMaxLines = obscureText ? 1 : maxLines;
    final effectiveMinLines = obscureText ? null : minLines;

    OutlineInputBorder outline(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? _radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      controller: controller,
      obscureText: obscureText,
      maxLines: effectiveMaxLines,
      minLines: effectiveMinLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      textCapitalization: textCapitalization,
      autocorrect: obscureText ? false : autocorrect,
      enableSuggestions: !obscureText,
      inputFormatters: inputFormatters,
      style: AppTextStyle.base(16, color: AppColors.textColor, height: 1.25),
      cursorColor: AppColors.btnBackground,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: AppTextStyle.base(16, color: AppColors.subTextColor.withValues(alpha: 0.65)),
        filled: true,
        fillColor: fill,
        contentPadding: contentPadding ?? defaultContentPadding,
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        enabledBorder: outline(borderColor),
        focusedBorder: outline(AppColors.btnBackground, width: 1.5),
        errorBorder: outline(AppColors.error),
        focusedErrorBorder: outline(AppColors.error, width: 1.5),
        border: outline(borderColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/app_colors.dart';
import 'package:side_project/core/resources/app_text_style.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.formatters = const [],
    this.validator,
    this.readOnly = false,
    this.isPassword = false,
    this.prefixWidget,
    this.suffixIcon,
    this.isDense = true,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.onComplete,
    this.hintText,
    this.onTap,
    this.enabled,
  });

  final TextEditingController? controller;
  final String? label;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool isPassword;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final bool isDense;
  final bool? enabled;
  final TextAlign textAlign;
  final String? hintText;
  final void Function(String value)? onChanged;
  final void Function()? onComplete;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    OutlineInputBorder border(Color color, {double w = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: w),
        );

    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      readOnly: readOnly,
      obscureText: isPassword,
      textAlign: textAlign,
      onChanged: onChanged,
      onFieldSubmitted: onComplete == null ? null : (_) => onComplete!.call(),
      onTap: onTap,
      cursorColor: c.secondary,
      decoration: InputDecoration(
        isDense: isDense,
        labelText: label,
        hintText: hintText,
        hintStyle: AppTextStyle.style(14, color: c.fourth),
        labelStyle: AppTextStyle.style(14, color: c.fourth),
        prefixIcon: prefixWidget,
        suffixIcon: suffixIcon,

        enabledBorder: border(c.fourth),
        focusedBorder: border(c.brand),
        disabledBorder: border(c.fourth),

        errorBorder: border(c.error),
        focusedErrorBorder: border(c.error),

        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }
}

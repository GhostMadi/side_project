import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Общая тема чекбокса приложения ([AppCheckbox], [AppCheckboxListTile]).
abstract final class AppCheckboxTheme {
  static CheckboxThemeData get data => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.inputBorder.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: AppColors.border.withValues(alpha: 0.6));
          }
          return const BorderSide(color: AppColors.inputBorder, width: 1.5);
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
}

/// Строка списка как в [ListTile] single select: те же отступы и типографика.
class AppCheckboxListTile extends StatelessWidget {
  const AppCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(checkboxTheme: AppCheckboxTheme.data),
      child: CheckboxListTile(
        value: value,
        onChanged: enabled
            ? (v) {
                if (v != null) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                }
              }
            : null,
        title: Text(
          label,
          style: AppTextStyle.base(
            16,
            color: enabled ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.65),
            fontWeight: value ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        controlAffinity: ListTileControlAffinity.leading,
        dense: false,
      ),
    );
  }
}

/// Чекбокс в стиле приложения: брендовый `primary`, скругление, опциональная подпись.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  static const double _box = 22;

  @override
  Widget build(BuildContext context) {
    final effectiveOnChanged = enabled ? onChanged : null;

    final box = SizedBox(
      width: _box,
      height: _box,
      child: CheckboxTheme(
        data: AppCheckboxTheme.data,
        child: Checkbox(
          value: value,
          onChanged: effectiveOnChanged == null
              ? null
              : (v) {
                  if (v != null) {
                    HapticFeedback.selectionClick();
                    effectiveOnChanged(v);
                  }
                },
        ),
      ),
    );

    if (label == null || label!.isEmpty) {
      return box;
    }

    return InkWell(
      onTap: effectiveOnChanged == null ? null : () => effectiveOnChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            box,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label!,
                style: AppTextStyle.base(
                  16,
                  color: enabled ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.65),
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

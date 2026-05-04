import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Строка-список с переключателем справа (как интерактивный [ListTile], в т.ч. в bottom sheet).
class AppTileToggle extends StatelessWidget {
  const AppTileToggle({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.onChanged,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;

  /// Состояние переключателя (включён = «активный» режим по смыслу экрана).
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.btnBackground,
      ),
    );
  }
}

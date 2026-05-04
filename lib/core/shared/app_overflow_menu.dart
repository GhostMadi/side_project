import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppOverflowMenuItem<T> {
  const AppOverflowMenuItem({
    required this.value,
    required this.title,
    this.icon,
    this.titleColor,
    this.iconColor,
    this.enabled = true,
  });

  final T value;
  final String title;
  final IconData? icon;
  final Color? titleColor;
  final Color? iconColor;
  final bool enabled;
}

/// Reusable overflow "⋯" menu for any actions.
///
/// - Provide [items] and handle [onSelected].
/// - If [items] is empty, renders nothing.
class AppOverflowMenu<T> extends StatelessWidget {
  const AppOverflowMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.menuTooltip = 'Опции',
    this.iconColor,
    this.iconPadding,
  });

  final List<AppOverflowMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  final String menuTooltip;
  final Color? iconColor;
  final EdgeInsets? iconPadding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<T>(
      tooltip: menuTooltip,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          for (final it in items)
            PopupMenuItem<T>(
              value: it.value,
              enabled: it.enabled,
              child: Row(
                children: [
                  if (it.icon != null) ...[
                    Icon(
                      it.icon,
                      size: 20,
                      color: it.iconColor ?? AppColors.textColor,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    it.title,
                    style: AppTextStyle.base(
                      14,
                      fontWeight: FontWeight.w700,
                      color: it.titleColor ?? AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
        ];
      },
      child: Padding(
        padding: iconPadding ?? EdgeInsets.zero,
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: iconColor ?? AppColors.subTextColor.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}


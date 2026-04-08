import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_list_item.dart';

/// Один пункт в [AppActionSheet].
class AppActionSheetItem<T> {
  const AppActionSheetItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.subtitle,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final String? subtitle;
}

/// Переиспользуемая «маленькая шторка выбора действий».
///
/// Использование:
/// - Оберни любой [child] в [AppActionSheet] и передай [items]
/// - На тап откроется компактная шторка; выбранный пункт вернётся в [onSelected]
class AppActionSheet<T> extends StatelessWidget {
  const AppActionSheet({
    super.key,
    required this.child,
    required this.items,
    required this.onSelected,
    this.title,
    this.enabled = true,
  });

  final Widget child;
  final List<AppActionSheetItem<T>> items;
  final ValueChanged<T> onSelected;
  final String? title;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    if (items.isEmpty) return;

    final picked = await AppBottomSheet.show<T>(
      context: context,
      title: title,
      upperCaseTitle: false,
      showCloseButton: true,
      contentBottomSpacing: 16,
      content: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        itemBuilder: (ctx, i) {
          final it = items[i];
          final color = it.isDestructive ? AppColors.error : AppColors.textColor;
          return AppListTile(
            onTap: () => Navigator.of(ctx).pop(it.value),
            leading: it.icon == null
                ? null
                : Icon(it.icon, color: it.isDestructive ? AppColors.error : AppColors.primary, size: 22),
            title: Text(
              it.label,
              style: AppTextStyle.base(15, color: color, fontWeight: FontWeight.w600),
            ),
            subtitle: (it.subtitle == null || it.subtitle!.trim().isEmpty)
                ? null
                : Text(
                    it.subtitle!.trim(),
                    style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.25),
                  ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subTextColor),
            isDestructive: it.isDestructive,
          );
        },
      ),
    );

    if (picked == null) return;
    onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: child,
    );
  }
}


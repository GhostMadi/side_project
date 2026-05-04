import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_overflow_menu.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';

/// Кнопка "⋯" → меню с одной опцией "Удалить" (с подтверждением).
///
/// Использовать для маркеров/постов/элементов списка, где пока нужна только операция удаления.
class AppOverflowDeleteMenu extends StatelessWidget {
  const AppOverflowDeleteMenu({
    super.key,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.onDelete,
    this.onDeletedToast = 'Удалено',
    this.menuTooltip = 'Опции',
    this.iconColor,
    this.iconPadding,
    this.popAfterDelete,
  });

  final String confirmTitle;
  final String confirmMessage;
  final Future<void> Function() onDelete;

  final String onDeletedToast;
  final String menuTooltip;

  /// Цвет иконки ⋯. Если null — muted.
  final Color? iconColor;

  /// Padding вокруг иконки ⋯ (полезно в AppBar actions).
  final EdgeInsets? iconPadding;

  /// Если задано — после успешного удаления закрыть текущий route и вернуть это значение.
  final Object? popAfterDelete;

  @override
  Widget build(BuildContext context) {
    return AppOverflowMenu<_Action>(
      menuTooltip: menuTooltip,
      iconColor: iconColor,
      iconPadding: iconPadding,
      items: const [
        AppOverflowMenuItem<_Action>(
          value: _Action.delete,
          title: 'Удалить',
          icon: Icons.delete_outline_rounded,
          titleColor: AppColors.destructive,
          iconColor: AppColors.destructive,
        ),
      ],
      onSelected: (a) async {
        if (a != _Action.delete) return;
        HapticFeedback.selectionClick();
        final ok = await AppDialog.showConfirm(
          context: context,
          title: confirmTitle,
          message: confirmMessage,
          confirmLabel: 'Удалить',
          confirmIsDestructive: true,
        );
        if (ok != true || !context.mounted) return;
        try {
          await onDelete();
          if (!context.mounted) return;
          AppSnackBar.show(context, message: onDeletedToast, kind: AppSnackBarKind.success);
          final popValue = popAfterDelete;
          if (popValue != null) {
            Navigator.of(context).maybePop(popValue);
          }
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
        }
      },
    );
  }
}

enum _Action { delete }

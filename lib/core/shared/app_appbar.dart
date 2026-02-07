import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const AppAppBar({
    super.key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // final colors = context.appColors;

    return AppBar(
      // backgroundColor: backgroundColor ?? colors.primary,
      // foregroundColor: colors.secondary,
      // surfaceTintColor: colors.primary,
      elevation: 0,
      centerTitle: true,

      // Мы отключаем автоматику самого Flutter AppBar,
      // потому что хотим полностью контролировать кнопку (своя иконка + AutoRoute)
      automaticallyImplyLeading: false,

      title: title,

      // ЛОГИКА:
      // 1. Если передали кастомный leading -> ставим его.
      // 2. Иначе, если включен авто-режим -> ставим нашу кнопку "Назад".
      // 3. Иначе -> null (пусто).
      leading:
          leading ??
          (automaticallyImplyLeading
              ? IconButton(
                  // Используем умный геттер .icon (сам выберет iOS/Android)
                  icon: Icon(AppIcons.back.icon), // Или colors.white
                  // Используем AutoRoute для возврата
                  onPressed: () => context.router.maybePop(),
                )
              : null),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

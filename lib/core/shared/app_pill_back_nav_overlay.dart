import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/shared/app_pill_navigation_bar.dart';

export 'app_pill_navigation_bar.dart' show AppPillNavItem;

/// Плавающая пилюля [AppPillNavigationBar] поверх контента: [Stack] — скролл на весь экран, пилюля не сжимает layout.
///
/// По умолчанию — только «Назад»; [extraItems] добавляют справа (например, «+» / новый пост) в той же пилюле.
///
/// У скроллов задайте нижний отступ через [scrollBottomInset], иначе текст окажется под пилюлей.
///
/// В [AppBar] для таких экранов задайте [AppAppBar.automaticallyImplyLeading] = false.
class AppPillBackNavOverlay extends StatelessWidget {
  const AppPillBackNavOverlay({super.key, required this.child, this.extraItems = const []});

  final Widget child;

  /// Кнопки в той же [AppPillNavigationBar] после «Назад» (две и более колонки в [AppPillNavigationBar._buildMulti]).
  final List<AppPillNavItem> extraItems;

  /// Safe area снизу + зазор под пилюлю (высота 60) и отступ от низа.
  static double scrollBottomInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 90;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final items = <AppPillNavItem>[
      AppPillNavItem(icon: AppIcons.back.icon, label: 'Назад', onTap: () => context.router.maybePop()),
      ...extraItems,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 20,
          right: 20,
          bottom: bottomSafe + 10,
          child: Center(
            child: AppPillNavigationBar(height: 60, shrinkWrapMulti: extraItems.isNotEmpty, items: items),
          ),
        ),
      ],
    );
  }
}

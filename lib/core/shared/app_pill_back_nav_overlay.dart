import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/shared/app_pill_navigation_bar.dart';

/// Плавающая кнопка «Назад» поверх контента: [Stack] — скролл на весь экран, пилюля не сжимает layout.
///
/// У скроллов задайте нижний отступ через [scrollBottomInset], иначе текст окажется под пилюлей.
///
/// В [AppBar] для таких экранов задайте [AppAppBar.automaticallyImplyLeading] = false.
class AppPillBackNavOverlay extends StatelessWidget {
  const AppPillBackNavOverlay({super.key, required this.child});

  final Widget child;

  /// Safe area снизу + зазор под плавающую [AppPillNavigationBar] (~60) и отступ от края (~10).
  static double scrollBottomInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 96;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomSafe + 10,
          child: Center(
            child: AppPillNavigationBar(
              height: 60,
              items: [
                AppPillNavItem(
                  icon: AppIcons.back.icon,
                  label: 'Назад',
                  onTap: () => context.router.maybePop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

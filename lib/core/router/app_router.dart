import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart'; // Нужен для Curves и виджетов анимации
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/router/guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard _authGuard = AuthGuard();

  // 1. ПЕРЕОПРЕДЕЛЯЕМ ГЛОБАЛЬНУЮ АНИМАЦИЮ
  @override
  RouteType get defaultRouteType => RouteType.custom(
    // Используем нашу кастомную функцию (см. ниже)
    transitionsBuilder: _slideAndFadeTransition,
    duration: Duration(milliseconds: 300),
    reverseDuration: Duration(milliseconds: 300),
  );

  @override
  List<AutoRoute> get routes => [
    // Login и Register тоже будут с этой анимацией.
    // Если хотите для них другую (например, снизу вверх),
    // используйте CustomRoute(page: ..., transitionsBuilder: ...)
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: ExampleRoute.page),
    AutoRoute(page: AdminEditorRoute.page),
    AutoRoute(page: RegisterRoute.page),

    // Application
    AutoRoute(
      page: ApplicationRoute.page,
      initial: true,
      // guards: [_authGuard],
      children: [
        // ВАЖНО: Если эти страницы переключаются в BottomNavigationBar,
        // лучше отключить анимацию, заменив AutoRoute на CustomRoute
        // с transitionsBuilder: TransitionsBuilders.noTransition
        AutoRoute(page: MessageRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: HomeRoute.page, initial: true),
      ],
    ),

    // Settings
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: BusinessRequestsRoute.page),
  ];
}

// 2. СОЗДАЕМ КРАСИВУЮ ФУНКЦИЮ АНИМАЦИИ (Вне класса или как static метод)
Widget _slideAndFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Настройка кривой (Curve) делает движение "живым"
  const curve = Curves.easeInOut;

  // Анимация движения (справа налево)
  var slideTween = Tween<Offset>(
    begin: const Offset(0.1, 0.0), // 0.1 означает небольшой сдвиг, 1.0 - полный выезд
    end: Offset.zero,
  ).chain(CurveTween(curve: curve));

  // Анимация прозрачности
  var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(slideTween),
    child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
  );
}

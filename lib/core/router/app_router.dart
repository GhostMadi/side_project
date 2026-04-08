import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: _slideAndFadeTransition,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SessionGateRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(
      page: ApplicationRoute.page,
      children: [
        AutoRoute(page: MapRoute.page, initial: true),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
    AutoRoute(page: ClusterCreateRoute.page),
    AutoRoute(page: PostCreateRoute.page),
    AutoRoute(page: PostDetailRoute.page),
    AutoRoute(page: EditProfileRoute.page),
    AutoRoute(page: ProfileImageEditRoute.page),
    AutoRoute(page: EditProfileFieldRoute.page),
    AutoRoute(page: EditProfileSelectFieldRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: ArchivedRoute.page),
    AutoRoute(page: MyAppointmentsRoute.page),
    AutoRoute(page: OrganizerProfileRoute.page),
  ];
}

Widget _slideAndFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const curve = Curves.easeInOut;
  final slideTween = Tween<Offset>(
    begin: const Offset(0.1, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: curve));
  final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(slideTween),
    child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
  );
}

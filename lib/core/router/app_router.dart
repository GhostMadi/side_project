import 'package:auto_route/auto_route.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/router/guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard _authGuard = AuthGuard();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(
      page: ApplicationRoute.page,
      initial: true,
      guards: [_authGuard],
      children: [
        AutoRoute(page: MessageRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: HomeRoute.page, initial: true),
      ],
    ),
  ];
}

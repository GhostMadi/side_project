import 'package:auto_route/auto_route.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authCubit = sl.get<AuthCubit>();

    final isAuthenticated = authCubit.state.maybeWhen(
      authenticated: () => true,
      orElse: () => false,
    );

    if (isAuthenticated) {
      resolver.next(true);
    } else {
      router.replaceAll([const LoginRoute()]);
      resolver.next(false);
    }
  }
}

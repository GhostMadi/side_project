import 'package:auto_route/auto_route.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/login/domain/repository/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  // Добавляем async, чтобы использовать await внутри
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final authRepository = sl<AuthRepository>();

    // 1. БЫСТРАЯ ПРОВЕРКА (КЭШ)
    // Если даже в телефоне ничего нет, сразу кидаем на логин.
    // Это экономит время и трафик.
    if (authRepository.currentUser == null) {
      resolver.redirectUntil(const LoginRoute());
      return;
    }

    // 2. СТРОГАЯ ПРОВЕРКА (СЕРВЕР)
    // Если в кэше что-то есть, проверяем, актуально ли это на сервере.
    // Приложение "замрет" на белом экране на 0.5-1 секунду, пока идет запрос.
    final isValid = await authRepository.checkSession();

    if (isValid) {
      // Всё супер, пропускаем
      resolver.next(true);
    } else {
      // В кэше данные были, но сервер сказал "такого юзера нет"
      // 1. Очищаем грязный кэш
      await authRepository.signOut();
      // 2. Кидаем на логин
      resolver.redirectUntil(const LoginRoute());
    }
  }
}

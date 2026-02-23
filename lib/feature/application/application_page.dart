import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/feature/profile/cubit/profile_cubit.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_bottom_bar.dart';

@RoutePage()
class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().loadMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [HomeRoute(), PublicRoute(), ProfileRoute()],
      transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        return Scaffold(
          // Используем extendBody, чтобы контент мог заходить под системные элементы
          extendBody: true,
          // Убираем стандартный параметр bottomNavigationBar
          body: Stack(
            children: [
              // 1. Контент страницы (карта или другой экран) на весь экран
              SizedBox.expand(child: child),

              // 2. Левитирующий BottomBar
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16, // Учет отступа снизу + зазор
                child: const AppBottomBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}

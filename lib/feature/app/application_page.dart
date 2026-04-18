import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/app/widget/app_bottom_bar.dart';

@RoutePage()
class ApplicationPage extends StatelessWidget {
  const ApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [MapRoute(), ChatListRoute(), ProfileRoute()],
      builder: (context, child) {
        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: child,
          bottomNavigationBar: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            color: Colors.transparent,
            child: const AppBottomBar(),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.dart';
import 'package:side_project/core/theme/theme.dart';
import 'package:side_project/core/user/cubit/user_cubit.dart';
import 'package:sizer/sizer.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   MapboxOptions.setAccessToken(
  //     'pk.eyJ1IjoibWFkaWsiLCJhIjoiY21qYWU0YjJwMDR4ZDNkcjBhbDR0MnczcCJ9.aC8lF8sNPSYMrrOdMgZUwQ',
  //   );

  //   super.initState();
  // }
  @override
  void initState() {
    sl<UserCubit>().loadProfile();
    super.initState();
  }

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.config(),
        theme: lightTheme(),
        // darkTheme: blackTheme(),
      ),
    );
  }
}

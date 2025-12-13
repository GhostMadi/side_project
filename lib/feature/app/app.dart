import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.dart';
import 'package:side_project/core/theme/theme.dart';
import 'package:side_project/feature/login/presentation/cubit/auth_cubit.dart';
import 'package:sizer/sizer.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<AuthCubit>(),
      child: Sizer(
        builder: (context, orientation, screenType) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _appRouter.config(),
          theme: lightTheme(),
          darkTheme: blackTheme(),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/locale/app_locale_cubit.dart';
import 'package:side_project/core/locale/app_supported_locales.dart';
import 'package:side_project/core/router/app_router.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/cities/presentation/cubit/cities_cubit.dart';
import 'package:side_project/feature/countries/presentation/cubit/countries_cubit.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart' hide AuthState;
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_categories/presentation/cubit/profile_categories_cubit.dart';
import 'package:side_project/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final _appRouter = AppRouter();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Yandex MapKit: ключ задаётся в android/.../MainApplication.kt и ios/Runner/AppDelegate.swift

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _appRouter.replaceAll([const LoginRoute()]);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) => MultiBlocProvider(
        providers: [
          BlocProvider<AppLocaleCubit>.value(value: sl<AppLocaleCubit>()),
          BlocProvider<CountriesCubit>.value(value: sl<CountriesCubit>()),
          BlocProvider<CitiesCubit>.value(value: sl<CitiesCubit>()),
          BlocProvider<ProfileCategoriesCubit>.value(value: sl<ProfileCategoriesCubit>()),
          BlocProvider<ProfileCubit>.value(value: sl<ProfileCubit>()),
          BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        ],
        child: BlocBuilder<AppLocaleCubit, Locale>(
          buildWhen: (prev, next) => prev != next,
          builder: (context, locale) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: _appRouter.config(),
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EE6)),
                fontFamily: 'Manrope',
              ),
              locale: locale,
              supportedLocales: AppSupportedLocales.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              localeResolutionCallback: (deviceLocale, supported) {
                if (deviceLocale == null) return supported.first;
                for (final l in supported) {
                  if (l.languageCode == deviceLocale.languageCode) return l;
                }
                return AppSupportedLocales.matchDeviceOrFallback(deviceLocale);
              },
            );
          },
        ),
      ),
    );
  }
}

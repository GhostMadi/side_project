import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Стартовый экран: читает сохранённую сессию Supabase и ведёт на [ApplicationRoute] или [LoginRoute].
@RoutePage()
class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      sl<AuthCubit>().checkAuthStatus();
      if (!mounted) return;
      context.router.replace(const ApplicationRoute());
    } else {
      sl<AuthCubit>().checkAuthStatus();
      if (!mounted) return;
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

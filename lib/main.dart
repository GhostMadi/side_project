import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/feature/meta/cubit/splash_cubit.dart';
import 'package:side_project/feature/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Берём токен из окружения и передаём в MapboxOptions
  String accessToken = const String.fromEnvironment(
    "pk.eyJ1IjoibWFkaWsiLCJhIjoiY21qYWU0YjJwMDR4ZDNkcjBhbDR0MnczcCJ9.aC8lF8sNPSYMrrOdMgZUwQ",
  );

  await Supabase.initialize(
    url: 'https://odrkmufrzfsqevscxzoz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kcmttdWZyemZzcWV2c2N4em96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODIwMzgsImV4cCI6MjA4MDk1ODAzOH0.xoYYfVzrY5CaFBIf5oOdlq_oKYasp8zpWDE8P6n51ZQ',
  );
  await configureDependencies();
  sl<SplashCubit>();

  runApp(const Application());
}

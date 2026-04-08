import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Импортируй это!
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/network/supabase_logging_http_client.dart';
import 'package:side_project/feature/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wewrosbaxhkukbefjwzf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indld3Jvc2JheGhrdWtiZWZqd3pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NDE0NDgsImV4cCI6MjA5MDExNzQ0OH0.JooHavhBbhSjk5IRr6j4pC7dd_ToQRj5TTlp5a_HK9A',
    debug: supabaseHttpLoggingEnabled,
    httpClient: supabaseHttpLoggingEnabled ? SupabaseLoggingHttpClient() : null,
  );
  await configureDependencies();

  await initializeDateFormatting('ru', null);
  runApp(const Application());
}


import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Импортируй это!
import 'package:side_project/core/config/supabase_config.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/network/supabase_logging_http_client.dart';
import 'package:side_project/feature/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: supabaseHttpLoggingEnabled,
    httpClient: supabaseHttpLoggingEnabled ? SupabaseLoggingHttpClient() : null,
  );
  await configureDependencies();

  await initializeDateFormatting('ru', null);
  runApp(const Application());
}
 
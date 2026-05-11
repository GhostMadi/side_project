import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Импортируй это!
import 'package:side_project/core/config/supabase_config.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/network/supabase_logging_http_client.dart';
import 'package:side_project/feature/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Supabase first
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: supabaseHttpLoggingEnabled,
      httpClient: supabaseHttpLoggingEnabled ? SupabaseLoggingHttpClient() : null,
    );

    // 2. Load Dependencies
    await configureDependencies();

    // 3. Localization
    await Future.wait([initializeDateFormatting('en', null), initializeDateFormatting('ru', null)]);

    // 4. Force a tiny gap to let the Native bridge "breathe"
    // This often fixes EXC_BAD_ACCESS during high-concurrency startups
    await Future.delayed(const Duration(milliseconds: 100));

    runApp(const Application());
  } catch (e, stack) {
    debugPrint('Fatal Startup Error: $e');
    debugPrint(stack.toString());
  }
}

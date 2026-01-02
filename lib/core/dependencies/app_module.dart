import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class AppModule {
  // Мы говорим: "Когда кто-то попросит SupabaseClient, дай ему вот этот instance"
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}

import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:side_project/core/storage/kv/isar_kv_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class AppModule {
  // Мы говорим: "Когда кто-то попросит SupabaseClient, дай ему вот этот instance"
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [IsarKvEntrySchema],
      directory: dir.path,
    );
  }
}

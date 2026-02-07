import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/city/data/repository/city_repository.dart';
import 'package:side_project/core/feature/country/data/repository/country_repository.dart';
import 'package:side_project/core/feature/establishments/data/repository/establishment_repository.dart';
import 'package:side_project/core/feature/meta/models/dictionary_version.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SyncService {
  final SupabaseClient _supabase;
  final IEstablishmentRepository _estRepo;
  final ICountryRepository _countryRepo; // Добавили
  final ICityRepository _cityRepo; // Добавили
  // final ICountryRepository _countryRepo;

  SyncService(this._supabase, this._estRepo, this._countryRepo, this._cityRepo);

  Future<void> syncDictionaries() async {
    try {
      // 1. Запрос версий с сервера
      final response = await _supabase.from('dictionary_versions').select();

      final remoteVersions = (response as List)
          .map((e) => DictionaryVersion.fromJson(e))
          .toList();

      // 2. Проверка каждой таблицы
      for (final meta in remoteVersions) {
        await _syncTable(meta);
      }
    } catch (e) {
      print('SyncService Error (Offline?): $e');
    }
  }

  Future<void> _syncTable(DictionaryVersion meta) async {
    final serverVersion = meta.version;

    switch (meta.tableName) {
      case 'establishment_types':
        final localVersion = _estRepo.getLocalVersion();
        if (serverVersion > localVersion) {
          print(
            '🔄 SyncService: Updating Establishments (v$localVersion -> v$serverVersion)',
          );
          await _estRepo.fetchAndSave(serverVersion);
        } else {
          print('✅ SyncService: Establishments up to date.');
        }
        break;

      case 'countries':
        // Логика для СТРАН
        final localVersion = _countryRepo.getLocalVersion();
        if (serverVersion > localVersion) {
          print(
            '🔄 SyncService: Updating Countries (v$localVersion -> v$serverVersion)',
          );
          await _countryRepo.fetchAndSave(serverVersion);
        } else {
          print('✅ SyncService: Countries up to date.');
        }
        break;

      case 'cities':
        // Логика для ГОРОДОВ
        final localVersion = _cityRepo.getLocalVersion();
        if (serverVersion > localVersion) {
          print(
            '🔄 SyncService: Updating Cities (v$localVersion -> v$serverVersion)',
          );
          await _cityRepo.fetchAndSave(serverVersion);
        } else {
          print('✅ SyncService: Cities up to date.');
        }
        break;
    }
  }
}

import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/establishments/data/datasources/establishment_local_data_source.dart';
import 'package:side_project/core/feature/establishments/data/models/establishment_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IEstablishmentRepository {
  /// Получить данные для UI (из кэша)
  List<EstablishmentType> getTypes();

  /// Получить текущую локальную версию (для SyncService)
  int getLocalVersion();

  /// Скачать с сервера и сохранить в локальный DataSource (для SyncService)
  Future<void> fetchAndSave(int newVersion);
}

@LazySingleton(as: IEstablishmentRepository)
class EstablishmentRepository implements IEstablishmentRepository {
  final SupabaseClient _supabase;
  final EstablishmentLocalDataSource _localDataSource;

  EstablishmentRepository(this._supabase, this._localDataSource);

  @override
  List<EstablishmentType> getTypes() {
    // 1. Берем "сырые" JSON-ы из DataSource
    final jsonList = _localDataSource.getJsonList();

    // 2. Превращаем в модели
    return jsonList.map((json) => EstablishmentType.fromJson(json)).toList();
  }

  @override
  int getLocalVersion() {
    final versionStr = _localDataSource.getVersion();
    return int.tryParse(versionStr) ?? 0;
  }

  @override
  Future<void> fetchAndSave(int newVersion) async {
    // 1. Качаем свежие данные с Supabase
    final response = await _supabase.from('establishment_types').select();

    final dataList = response as List<dynamic>;

    // 2. Преобразуем в List<Map<String, dynamic>> для сохранения
    final List<Map<String, dynamic>> jsonToSave = dataList
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // 3. Сохраняем данные через DataSource
    await _localDataSource.saveJsonList(jsonToSave);

    // 4. Обновляем версию через DataSource
    await _localDataSource.setVersion(newVersion.toString());
  }
}

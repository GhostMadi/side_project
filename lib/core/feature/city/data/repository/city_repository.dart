import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/city/data/datasources/city_local_data_source.dart';
import 'package:side_project/core/feature/city/data/models/city.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ICityRepository {
  List<City> getCities();
  int getLocalVersion();
  Future<void> fetchAndSave(int newVersion);
}

@LazySingleton(as: ICityRepository)
class CityRepository implements ICityRepository {
  final SupabaseClient _supabase;
  final CityLocalDataSource _local;

  CityRepository(this._supabase, this._local);

  @override
  List<City> getCities() =>
      _local.getJsonList().map((e) => City.fromJson(e)).toList();

  @override
  int getLocalVersion() => int.tryParse(_local.getVersion()) ?? 0;

  @override
  Future<void> fetchAndSave(int newVersion) async {
    final data = await _supabase.from('cities').select();
    await _local.saveJsonList(List<Map<String, dynamic>>.from(data));
    await _local.setVersion(newVersion.toString());
  }
}

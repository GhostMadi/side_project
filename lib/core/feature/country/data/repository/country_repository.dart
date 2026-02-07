import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/country/data/datasources/country_local_data_source.dart';
import 'package:side_project/core/feature/country/data/models/country.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ICountryRepository {
  List<Country> getCountries();
  int getLocalVersion();
  Future<void> fetchAndSave(int newVersion);
}

@LazySingleton(as: ICountryRepository)
class CountryRepository implements ICountryRepository {
  final SupabaseClient _supabase;
  final CountryLocalDataSource _local;

  CountryRepository(this._supabase, this._local);

  @override
  List<Country> getCountries() =>
      _local.getJsonList().map((e) => Country.fromJson(e)).toList();

  @override
  int getLocalVersion() => int.tryParse(_local.getVersion()) ?? 0;

  @override
  Future<void> fetchAndSave(int newVersion) async {
    final data = await _supabase.from('countries').select();
    await _local.saveJsonList(List<Map<String, dynamic>>.from(data));
    await _local.setVersion(newVersion.toString());
  }
}

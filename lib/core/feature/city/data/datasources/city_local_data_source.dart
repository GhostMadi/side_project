import 'package:injectable/injectable.dart';
import 'package:side_project/core/locale/abstract_local_datasource.dart';
@injectable
class CityLocalDataSource extends AbstractLocalDataSource {
  CityLocalDataSource(super.prefs);
  @override
  String get versionKey => 'cities_version';
  @override
  String get dataKey => 'cities_data';
}
import 'package:injectable/injectable.dart';
import 'package:side_project/core/locale/abstract_local_datasource.dart';
@injectable
class CountryLocalDataSource extends AbstractLocalDataSource {
  CountryLocalDataSource(super.prefs);
  @override
  String get versionKey => 'countries_version';
  @override
  String get dataKey => 'countries_data';
}
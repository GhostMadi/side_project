import 'package:injectable/injectable.dart';
import 'package:side_project/core/locale/abstract_local_datasource.dart';

@injectable
class EstablishmentLocalDataSource extends AbstractLocalDataSource {
  // Injectable сам подставит SharedPreferences
  EstablishmentLocalDataSource(super.prefs);

  @override
  String get versionKey => 'establishment_types_version';

  @override
  String get dataKey => 'establishment_types_data';
}

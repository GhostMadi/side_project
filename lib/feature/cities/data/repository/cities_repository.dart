import 'package:side_project/feature/cities/data/models/city_model.dart';

abstract class CitiesRepository {
  Future<List<CityModel>> fetchActiveByCountryOrdered(String countryCode);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/country/data/models/country.dart';
import 'package:side_project/core/feature/country/data/repository/country_repository.dart';

part 'country_cubit.freezed.dart';

// --- State (внутри того же файла или вынеси отдельно) ---

@freezed
class CountryState with _$CountryState {
  const factory CountryState.initial() = _Initial;
  const factory CountryState.loading() = _Loading;
  const factory CountryState.success(List<Country> countries) = _Success;
  const factory CountryState.error(String message) = _Error;
}

@singleton
class CountryCubit extends Cubit<CountryState> {
  final ICountryRepository _repository;

  CountryCubit(this._repository) : super(const CountryState.initial());

  void loadCountries() {
    emit(const CountryState.loading());
    try {
      final data = _repository.getCountries();
      emit(CountryState.success(data));
    } catch (e) {
      emit(CountryState.error(e.toString()));
    }
  }
}

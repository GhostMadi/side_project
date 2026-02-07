import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/city/data/models/city.dart';
import 'package:side_project/core/feature/city/data/repository/city_repository.dart';

part 'city_cubit.freezed.dart';

// --- State (внутри того же файла или вынеси отдельно) ---

@freezed
class CityState with _$CityState {
  const factory CityState.initial() = _Initial;
  const factory CityState.loading() = _Loading;
  const factory CityState.success(List<City> cities) = _Success;
  const factory CityState.error(String message) = _Error;
}

@singleton
class CityCubit extends Cubit<CityState> {
  final ICityRepository _repository;

  CityCubit(this._repository) : super(const CityState.initial());

  void loadCities() {
    emit(const CityState.loading());
    try {
      final data = _repository.getCities();
      emit(CityState.success(data));
    } catch (e) {
      emit(CityState.error(e.toString()));
    }
  }
}

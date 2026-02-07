import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/establishments/data/models/establishment_type.dart';
import 'package:side_project/core/feature/establishments/data/repository/establishment_repository.dart';

part 'establishment_types_cubit.freezed.dart';

// --- State (внутри того же файла или вынеси отдельно) ---

@freezed
class EstablishmentTypesState with _$EstablishmentTypesState {
  const factory EstablishmentTypesState.initial() = _Initial;
  const factory EstablishmentTypesState.loading() = _Loading;

  // Успех теперь хранит список Моделей
  const factory EstablishmentTypesState.success(List<EstablishmentType> types) =
      _Success;

  const factory EstablishmentTypesState.error(String message) = _Error;
}

@singleton
class EstablishmentTypesCubit extends Cubit<EstablishmentTypesState> {
  final IEstablishmentRepository _repository;

  EstablishmentTypesCubit(this._repository)
    : super(const EstablishmentTypesState.initial());

  void loadTypes() {
    emit(const EstablishmentTypesState.loading());

    try {
      // 1. Получаем данные мгновенно (синхронно) из репозитория
      // В репозитории метод называется getTypes() (как мы договаривались ранее)
      final types = _repository.getTypes();
        
      // 2. Сразу эмитим успех
      emit(EstablishmentTypesState.success(types));
    } catch (e) {
      // На случай, если json парсинг упадет (маловероятно, но всё же)
      emit(EstablishmentTypesState.error(e.toString()));
    }
  }
}

part of 'profile_cubit.dart';

@freezed
class ProfileState with _$ProfileState {
  // Состояние 1: Загрузка (или начальное состояние)
  const factory ProfileState.loading() = _Loading;

  // Состояние 2: Данные успешно получены
  const factory ProfileState.loaded(UserStatsModel stats) = _Loaded;

  // Состояние 3: Произошла ошибка
  const factory ProfileState.error(String message) = _Error;
}
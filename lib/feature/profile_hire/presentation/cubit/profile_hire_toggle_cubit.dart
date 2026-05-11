import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile_hire/data/reposiotry/profile_hire_mine.dart';

part 'profile_hire_toggle_cubit.freezed.dart';

@freezed
sealed class ProfileHireToggleState with _$ProfileHireToggleState {
  /// Инициализация или первичная загрузка
  const factory ProfileHireToggleState.loading() = _Loading;

  /// Состояние с данными
  const factory ProfileHireToggleState.loaded({required bool isEnabled, @Default(false) bool isSubmitting}) =
      _Loaded;

  /// Ошибка (сеть, RLS и т.д.)
  const factory ProfileHireToggleState.error(String message) = _Error;
}

@injectable
class HiringToggleCubit extends Cubit<ProfileHireToggleState> {
  HiringToggleCubit(this._repository) : super(const ProfileHireToggleState.loading());

  final ProfileHireRepository _repository;

  Future<void> load() async {
    emit(const ProfileHireToggleState.loading());

    // 1. Быстрый показ из кэша Isar
    final peek = await _repository.peekGate();
    if (peek.cacheKnown && !isClosed) {
      emit(ProfileHireToggleState.loaded(isEnabled: peek.stored?.hiringEnabled ?? false));
    }

    // 2. Синхронизация с базой profiles
    try {
      final mine = await _repository.refreshRemoteAndCache();
      if (!isClosed) {
        emit(ProfileHireToggleState.loaded(isEnabled: mine.hiringEnabled));
      }
    } catch (e) {
      if (!isClosed) {
        final p = await _repository.peekGate();
        if (p.cacheKnown) {
          emit(ProfileHireToggleState.loaded(isEnabled: p.stored?.hiringEnabled ?? false));
        } else {
          emit(ProfileHireToggleState.error('Ошибка загрузки статуса найма'));
        }
      }
    }
  }

  Future<String?> toggle(bool value) async {
    final currentState = state.maybeWhen(loaded: (val, _) => val, orElse: () => null);
    if (currentState == null || currentState == value) return null;

    emit(ProfileHireToggleState.loaded(isEnabled: value, isSubmitting: true));
    try {
      await _repository.updateHiringStatus(value);
      if (!isClosed) emit(ProfileHireToggleState.loaded(isEnabled: value));
      return null;
    } catch (e) {
      if (!isClosed) emit(ProfileHireToggleState.loaded(isEnabled: currentState));
      return 'Не удалось сохранить изменения';
    }
  }
}

@injectable
class MembershipToggleCubit extends Cubit<ProfileHireToggleState> {
  MembershipToggleCubit(this._repository) : super(const ProfileHireToggleState.loading());

  final ProfileHireRepository _repository;

  Future<void> load() async {
    emit(const ProfileHireToggleState.loading());

    final peek = await _repository.peekGate();
    if (peek.cacheKnown && !isClosed) {
      emit(ProfileHireToggleState.loaded(isEnabled: peek.stored?.openForMemberships ?? false));
    }

    try {
      final mine = await _repository.refreshRemoteAndCache();
      if (!isClosed) {
        emit(ProfileHireToggleState.loaded(isEnabled: mine.openForMemberships));
      }
    } catch (e) {
      if (!isClosed) {
        final p = await _repository.peekGate();
        if (p.cacheKnown) {
          emit(ProfileHireToggleState.loaded(isEnabled: p.stored?.openForMemberships ?? false));
        } else {
          emit(ProfileHireToggleState.error('Ошибка загрузки статуса команд'));
        }
      }
    }
  }

  Future<String?> toggle(bool value) async {
    final currentState = state.maybeWhen(loaded: (val, _) => val, orElse: () => null);
    if (currentState == null || currentState == value) return null;

    emit(ProfileHireToggleState.loaded(isEnabled: value, isSubmitting: true));
    try {
      await _repository.updateMembershipsStatus(value);
      if (!isClosed) emit(ProfileHireToggleState.loaded(isEnabled: value));
      return null;
    } catch (e) {
      if (!isClosed) emit(ProfileHireToggleState.loaded(isEnabled: currentState));
      return 'Ошибка при обновлении доступа к командам';
    }
  }
}

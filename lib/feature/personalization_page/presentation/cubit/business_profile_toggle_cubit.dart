import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_repository.dart';

part 'business_profile_toggle_cubit.freezed.dart';

/// Переключатель «бизнес-аккаунт активен» (штора персонализации).
@injectable
class BusinessProfileToggleCubit extends Cubit<BusinessProfileToggleState> {
  BusinessProfileToggleCubit(this._repository) : super(const BusinessProfileToggleState.loading());

  final BusinessProfileRepository _repository;

  Future<void> load() async {
    emit(const BusinessProfileToggleState.loading());
    final initialPeek = await _repository.peekGate();
    if (initialPeek.cacheKnown && !isClosed) {
      emit(BusinessProfileToggleState.loaded(isActive: businessProfileIsActiveFromPeek(initialPeek)));
    }
    try {
      final mine = await _repository.refreshRemoteAndCache();
      if (!isClosed) emit(BusinessProfileToggleState.loaded(isActive: mine?.isActive ?? false));
    } catch (e) {
      if (!isClosed) {
        final p = await _repository.peekGate();
        if (p.cacheKnown) {
          emit(BusinessProfileToggleState.loaded(isActive: businessProfileIsActiveFromPeek(p)));
        } else {
          emit(BusinessProfileToggleState.error(_humanError(e)));
        }
      }
    }
  }

  /// При ошибке сохранения возвращает текст для snackbar.
  Future<String?> applyActive(bool wantsActive) async {
    final current = state.maybeWhen(loaded: (a, _) => a, orElse: () => null);
    if (current == null) return null;
    if (current == wantsActive) return null;

    emit(BusinessProfileToggleState.loaded(isActive: current, submitting: true));
    try {
      await _repository.upsertMyStatus(wantsActive ? BusinessProfileStatus.active : BusinessProfileStatus.deactive);
      if (isClosed) return null;
      emit(BusinessProfileToggleState.loaded(isActive: wantsActive));
      return null;
    } catch (e) {
      if (isClosed) return _humanError(e);
      emit(BusinessProfileToggleState.loaded(isActive: current));
      return _humanError(e);
    }
  }

  static String _humanError(Object e) {
    final m = '$e'.toLowerCase();
    if (m.contains('not_authenticated')) return 'Войдите в аккаунт.';
    final low = m.toLowerCase();
    if (low.contains('could not find the table') || low.contains('pgrst301')) {
      return 'Таблица business_profiles недоступна. Накатите миграции Supabase.';
    }
    return m;
  }
}

@freezed
sealed class BusinessProfileToggleState with _$BusinessProfileToggleState {
  const factory BusinessProfileToggleState.loading() = _BpLoading;

  const factory BusinessProfileToggleState.loaded({required bool isActive, @Default(false) bool submitting}) =
      _BpLoaded;

  const factory BusinessProfileToggleState.error(String message) = _BpError;
}

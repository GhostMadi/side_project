import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/meta/sync_service/sync_service.dart';

part 'splash_cubit.freezed.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState.initial() = _Initial;
  const factory SplashState.loading() = _Loading; // Показываем лоадер/лого
  const factory SplashState.success() = _Success; // Можно переходить на Home
  const factory SplashState.error(String msg) = _Error;
}

@singleton // <-- Как ты и просил
class SplashCubit extends Cubit<SplashState> {
  final SyncService _syncService;

  SplashCubit(this._syncService) : super(const SplashState.initial()) {
    initApp();
  }

  Future<void> initApp() async {
    emit(const SplashState.loading());

    // Запускаем синхронизацию справочников
    // Мы не используем try-catch здесь, потому что SyncService
    // внутри себя обрабатывает ошибки сети и позволяет работать оффлайн.
    await _syncService.syncDictionaries();

    // Тут можно добавить другие инициализации (проверка авторизации и т.д.)
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Для красоты анимации

    emit(const SplashState.success());
  }
}

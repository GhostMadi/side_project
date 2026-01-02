import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/login/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

part 'auth_cubit.freezed.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial()) {
    // При создании Кубита сразу проверяем, не залогинен ли уже юзер
    checkAuthStatus();
  }

  /// 1. Проверка текущей сессии (для Splash Screen)
  void checkAuthStatus() {
    final user = _repository.currentUser;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  /// 2. Вход через Google
  Future<void> signInWithGoogle() async {
    try {
      emit(const AuthState.loading());

      // Вся сложная логика в репозитории
      await _repository.signInWithGoogle();

      // Если ошибки не вылетело, берем юзера
      final user = _repository.currentUser;

      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        // На случай, если вход прошел, но юзер null (редкий кейс)
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      // Обработка ошибок
      // Можно приукрасить текст ошибки для пользователя
      final message = e.toString().contains('canceled')
          ? 'Вход отменен'
          : 'Ошибка входа: $e';

      emit(AuthState.error(message));

      // Возвращаем в состояние "не авторизован", чтобы убрать лоадер
      // Но лучше оставить error, чтобы UI показал SnackBar,
      // а потом UI сам решит, что рисовать.
    }
  }

  /// 3. Выход из аккаунта
  Future<void> signOut() async {
    try {
      emit(const AuthState.loading());
      await _repository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}

@freezed
class AuthState with _$AuthState {
  /// Состояние при старте
  const factory AuthState.initial() = _Initial;

  /// Крутится лоадер (запрос идет)
  const factory AuthState.loading() = _Loading;

  /// Успешный вход (несем внутри объект User, чтобы сразу иметь доступ к ID/Email)
  const factory AuthState.authenticated(sp.User user) = _Authenticated;

  /// Пользователь не авторизован (или вышел)
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Произошла ошибка (несем текст ошибки для SnackBar)
  const factory AuthState.error(String message) = _Error;
}

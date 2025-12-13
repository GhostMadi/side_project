import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/login/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<sp.AuthState>? _sub;

  AuthCubit(this._authRepository) : super(const AuthState.initial()) {
    _init();
  }

  void _init() {
    // 1) Берём текущую сессию из Supabase синхронно
    final session = _authRepository.currentSession;
    if (session != null) {
      emit(const AuthState.authenticated());
    } else {
      emit(const AuthState.unauthenticated());
    }

    // 2) Подписываемся на изменения
    _monitorAuthChanges();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signUp(email: email, password: password);
      // дальше состояние придёт через стрим (signedIn / initialSession)
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signIn(email: email, password: password);
      // Supabase триггернет AuthChangeEvent.signedIn → authenticated
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      // Supabase триггернет signedOut → unauthenticated
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  void _monitorAuthChanges() {
    _sub = _authRepository.authStateChanges.listen((data) {
      final event = data.event;

      switch (event) {
        case sp.AuthChangeEvent.initialSession:
          // при старте приложения
          if (data.session != null) {
            emit(const AuthState.authenticated());
          } else {
            emit(const AuthState.unauthenticated());
          }
          break;

        case sp.AuthChangeEvent.signedIn:
          emit(const AuthState.authenticated());
          break;

        case sp.AuthChangeEvent.signedOut:
          emit(const AuthState.unauthenticated());
          break;

        default:
          // остальные события пока можно игнорить или логировать
          break;
      }
    });
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

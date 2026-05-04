import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/business_profile_cache_storage.dart';
import 'package:side_project/feature/login_page/data/model/auth_user.dart';
import 'package:side_project/feature/login_page/data/repository/auth_repository.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_gate_listenable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthApiException;

part 'auth_cubit.freezed.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._businessProfileCache, this._businessProfileGateListen)
      : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  final AuthRepository _repository;
  final BusinessProfileCacheStorage _businessProfileCache;
  final BusinessProfileGateListenable _businessProfileGateListen;

  void checkAuthStatus() {
    final user = _repository.currentUser;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(const AuthState.loading());
      final user = await _repository.signInWithGoogle();
      emit(AuthState.authenticated(user));
    } on GoogleSignInException catch (e) {
      final message = e.code == GoogleSignInExceptionCode.canceled
          ? 'Вход отменён'
          : 'Ошибка Google: ${e.description ?? e.code.name}';
      emit(AuthState.error(message));
    } on AuthApiException catch (e) {
      final text = e.message;
      final message =
          text.toLowerCase().contains('cancel') ? 'Вход отменён' : 'Ошибка входа: $text';
      emit(AuthState.error(message));
    } catch (e) {
      final text = e.toString();
      final message =
          text.toLowerCase().contains('cancel') ? 'Вход отменён' : 'Ошибка входа: $text';
      emit(AuthState.error(message));
    }
  }

  Future<void> signOut() async {
    try {
      emit(const AuthState.loading());
      final uid = _repository.currentUser?.id.trim();
      if (uid != null && uid.isNotEmpty) {
        await _businessProfileCache.clear(uid);
        _businessProfileGateListen.notifyGateChanged();
      }
      await _repository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthUser user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

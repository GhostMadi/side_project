import 'dart:developer';

import 'package:side_project/feature/login/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

class AuthRepositoryImpl implements AuthRepository {
  final sp.GoTrueClient _authClient = sp.Supabase.instance.client.auth;

  @override
  Future<void> signUp({required String email, required String password}) async {
    final res = await _authClient.signUp(email: email, password: password);
    log('signUp: $res');
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final res = await _authClient.signInWithPassword(
      email: email,
      password: password,
    );
    log('signIn: $res');
  }

  @override
  Future<void> signOut() async {
    await _authClient.signOut();
  }

  @override
  Stream<sp.AuthState> get authStateChanges => _authClient.onAuthStateChange;

  @override
  sp.Session? get currentSession => _authClient.currentSession;
}

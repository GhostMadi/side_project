import 'package:supabase_flutter/supabase_flutter.dart' as sp;

abstract class AuthRepository {
  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();

  // стрим изменения auth состояния от Supabase
  Stream<sp.AuthState> get authStateChanges;

  // синхронный доступ к текущей сессии
  sp.Session? get currentSession;
}

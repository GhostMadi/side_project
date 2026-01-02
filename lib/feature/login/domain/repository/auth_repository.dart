import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  /// Вход через Google
  Future<AuthResponse> signInWithGoogle();

  /// Выход из системы
  Future<void> signOut();

  /// Проверка текущей сессии (опционально)
  User? get currentUser;

  Future<bool> checkSession();
}

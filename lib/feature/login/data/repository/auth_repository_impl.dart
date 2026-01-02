import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/login/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthRepository)
class IAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  // В v7 мы обращаемся к .instance, а не создаем new GoogleSignIn()
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  IAuthRepository(this._supabase);

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Сбрасываем Google (чтобы точно показалось окно выбора аккаунта, если нужно)
      // Это полезно, если у человека несколько аккаунтов
      await _googleSignIn.signOut();

      // 2. Инициализация
      await _googleSignIn.initialize(
        serverClientId: 'ТВОЙ_CLIENT_ID.apps.googleusercontent.com',
      );

      // 3. Вход
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw const AuthException('Нет токена');
      }

      // 4. Supabase получает новые токены и САМ ОБНОВЛЯЕТ КЭШ
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    // Выход отовсюду
    await Future.wait([
      _googleSignIn.signOut(), // Работает так же
      _supabase.auth.signOut(),
    ]);
  }

  @override
  Future<bool> checkSession() async {
    try {
      // .getUser() игнорирует кэш и идет на сервер.
      // Если юзер удален или токен поддельный — выпадет ошибка.
      final response = await _supabase.auth.getUser();
      return response.user != null;
    } catch (e) {
      return false;
    }
  }
}

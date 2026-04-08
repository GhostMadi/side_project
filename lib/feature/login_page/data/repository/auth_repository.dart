import 'dart:developer' as developer;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/config/google_auth_config.dart';
import 'package:side_project/feature/login_page/data/model/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

abstract class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  @override
  AuthUser? get currentUser => _supabase.auth.currentUser?.toAuthUser();

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    final webClientId = GoogleAuthConfig.serverClientId.trim();
    await _googleSignIn.initialize(serverClientId: webClientId.isEmpty ? null : webClientId);
    _googleInitialized = true;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    await _googleSignIn.signOut();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google не вернул idToken. Для Android: Web client ID в strings.xml или '
        '--dart-define=GOOGLE_SERVER_CLIENT_ID=....apps.googleusercontent.com',
      );
    }

    await _supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);

    final sessionUser = _supabase.auth.currentUser;
    if (sessionUser == null) {
      throw Exception('Сессия Supabase не создана после входа Google');
    }
    final appUser = sessionUser.toAuthUser();
    developer.log(
      'Модель AuthUser: id=${appUser.id} email=${appUser.email ?? "-"} '
      'displayName=${appUser.displayName ?? "-"} avatarUrl=${appUser.avatarUrl != null ? "(есть)" : "нет"}',
      name: 'GoogleAuth',
    );
    return appUser;
  }

  @override
  Future<void> signOut() async {
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
    await _supabase.auth.signOut();
  }
}

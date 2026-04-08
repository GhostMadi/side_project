import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_user.freezed.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) = _AuthUser;
}

extension AuthUserFromSupabase on User {
  AuthUser toAuthUser() {
    final meta = userMetadata ?? {};
    return AuthUser(
      id: id,
      email: email,
      displayName:
          meta['full_name'] as String? ??
          meta['name'] as String? ??
          meta['given_name'] as String?,
      avatarUrl: meta['avatar_url'] as String? ?? meta['picture'] as String?,
    );
  }
}

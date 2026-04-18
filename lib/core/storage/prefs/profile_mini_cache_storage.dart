import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

@lazySingleton
class ProfileMiniCacheStorage {
  ProfileMiniCacheStorage(this._store);

  final IsarKvStore _store;

  String _key(String userId) => 'profile_mini_v1_$userId';

  Future<({String? username, String? avatarUrl})?> read(String userId) async {
    if (userId.trim().isEmpty) return null;
    final raw = await _store.read(_key(userId));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final m = decoded.cast<String, dynamic>();
      final u = (m['username'] as String?)?.trim();
      final a = (m['avatar_url'] as String?)?.trim();
      return (username: (u != null && u.isNotEmpty) ? u : null, avatarUrl: (a != null && a.isNotEmpty) ? a : null);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String userId, {String? username, String? avatarUrl}) async {
    if (userId.trim().isEmpty) return;
    final u = username?.trim();
    final a = avatarUrl?.trim();
    if ((u == null || u.isEmpty) && (a == null || a.isEmpty)) {
      await _store.delete(_key(userId));
      return;
    }
    await _store.write(
      _key(userId),
      jsonEncode({
        'username': (u != null && u.isNotEmpty) ? u : null,
        'avatar_url': (a != null && a.isNotEmpty) ? a : null,
      }),
    );
  }
}

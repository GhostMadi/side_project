import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/base_storage.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

/// Локальный кэш статуса подписки "я подписан на профиль" — чтобы UI мог показывать кнопку сразу.
///
/// Храним per-user, чтобы при logout/login не смешивать данные.
@lazySingleton
class ProfileFollowStatusPrefsStorage {
  ProfileFollowStatusPrefsStorage(this._store);

  final IsarKvStore _store;

  String _cacheKey(String userId) => 'profile_follow_status_cache_v1_$userId';

  Future<Map<String, bool>> readCached(String userId) async {
    final raw = await BaseStorage<String>(
      key: _cacheKey(userId),
      read: _store.read,
      write: _store.write,
      delete: _store.delete,
    ).read();
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map((k, v) => MapEntry(k.toString(), v == true || v == 'true'));
    } catch (_) {
      return const {};
    }
  }

  Future<void> writeCached(String userId, Map<String, bool> map) async {
    await BaseStorage<String>(
      key: _cacheKey(userId),
      read: _store.read,
      write: _store.write,
      delete: _store.delete,
    ).save(jsonEncode(map));
  }

  /// `null` — ещё не знаем (нет в кэше).
  Future<bool?> readCachedForTarget(String userId, String targetUserId) async {
    final m = await readCached(userId);
    return m.containsKey(targetUserId) ? m[targetUserId]! : null;
  }

  Future<void> setCached(String userId, String targetUserId, bool isFollowing) async {
    final m = Map<String, bool>.from(await readCached(userId));
    m[targetUserId] = isFollowing;
    await writeCached(userId, m);
  }

  Future<void> setCachedBatch(String userId, Map<String, bool> updates) async {
    if (updates.isEmpty) return;
    final m = Map<String, bool>.from(await readCached(userId));
    for (final e in updates.entries) {
      if (e.key.isEmpty) continue;
      m[e.key] = e.value;
    }
    await writeCached(userId, m);
  }
}


import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/base_storage.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

/// Локальный кэш моей реакции на пост + очередь "хочу такое состояние" (pending).
///
/// Храним per-user, чтобы при logout/login не смешивались реакции.
@lazySingleton
class PostReactionsPrefsStorage {
  PostReactionsPrefsStorage(this._store);

  final IsarKvStore _store;

  String _cacheKey(String userId) => 'post_reactions_cache_v1_$userId';
  String _pendingKey(String userId) => 'post_reactions_pending_v1_$userId';

  Future<Map<String, String>> readCachedKinds(String userId) async {
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
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> writeCachedKinds(String userId, Map<String, String> map) async {
    await BaseStorage<String>(
      key: _cacheKey(userId),
      read: _store.read,
      write: _store.write,
      delete: _store.delete,
    ).save(jsonEncode(map));
  }

  Future<String?> readCachedKind(String userId, String postId) async {
    final m = await readCachedKinds(userId);
    final v = m[postId];
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Future<void> setCachedKind(String userId, String postId, String? kind) async {
    final m = Map<String, String>.from(await readCachedKinds(userId));
    if (kind == null || kind.isEmpty) {
      m.remove(postId);
    } else {
      m[postId] = kind;
    }
    await writeCachedKinds(userId, m);
  }

  /// Apply many updates in one write. `null` removes the key.
  Future<void> setCachedKindsBatch(String userId, Map<String, String?> updates) async {
    if (updates.isEmpty) return;
    final m = Map<String, String>.from(await readCachedKinds(userId));
    for (final e in updates.entries) {
      final postId = e.key;
      final kind = e.value;
      if (postId.isEmpty) continue;
      if (kind == null || kind.isEmpty) {
        m.remove(postId);
      } else {
        m[postId] = kind;
      }
    }
    await writeCachedKinds(userId, m);
  }

  Future<Map<String, String>> readPendingDesired(String userId) async {
    final raw = await BaseStorage<String>(
      key: _pendingKey(userId),
      read: _store.read,
      write: _store.write,
      delete: _store.delete,
    ).read();
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> writePendingDesired(String userId, Map<String, String> map) async {
    await BaseStorage<String>(
      key: _pendingKey(userId),
      read: _store.read,
      write: _store.write,
      delete: _store.delete,
    ).save(jsonEncode(map));
  }

  Future<void> setPendingDesired(String userId, String postId, String desiredKind) async {
    final m = Map<String, String>.from(await readPendingDesired(userId));
    m[postId] = desiredKind;
    await writePendingDesired(userId, m);
  }

  Future<void> clearPending(String userId, String postId) async {
    final m = Map<String, String>.from(await readPendingDesired(userId));
    m.remove(postId);
    await writePendingDesired(userId, m);
  }
}

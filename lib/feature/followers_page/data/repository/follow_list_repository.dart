import 'package:injectable/injectable.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FollowListRepository {
  Future<List<ProfileFollowRow>> listFollowers(String profileId, {int limit = 50, int offset = 0});

  Future<List<ProfileFollowRow>> listFollowing(String profileId, {int limit = 50, int offset = 0});

  Future<void> followUser(String targetUserId);

  Future<void> unfollowUser(String targetUserId);

  Future<bool> isFollowing(String targetUserId);

  /// Батч-проверка статуса подписки на несколько профилей.
  ///
  /// Пытается вызвать RPC `is_following_users(p_targets uuid[])` (если есть на сервере),
  /// иначе падает обратно на последовательные `isFollowing`.
  Future<Map<String, bool>> isFollowingBatch(List<String> targetUserIds);
}

String mapFollowRpcError(Object e) {
  if (e is PostgrestException) {
    final m = e.message.toLowerCase();
    final code = e.code;
    if (code == '404' || m.contains('could not find the function')) {
      return 'На сервере нет функции follow. Накатите миграции (profile_follows).';
    }
    if (m.contains('user_sleeping')) return 'Пользователь в режиме сна — подписка недоступна.';
    if (m.contains('user_blocked')) return 'Подписка недоступна (блокировка).';
    if (m.contains('follow_rate_limited')) return 'Слишком много подписок в час. Попробуйте позже.';
    if (m.contains('not_authenticated')) return 'Войдите в аккаунт.';
    if (m.contains('cannot_follow_self')) return 'Нельзя подписаться на себя.';
    if (m.contains('user_not_found')) return 'Пользователь не найден.';
    return e.message;
  }
  return e.toString();
}

@LazySingleton(as: FollowListRepository)
class FollowListRepositoryImpl implements FollowListRepository {
  FollowListRepositoryImpl(this._client);

  final SupabaseClient _client;

  List<ProfileFollowRow> _parseRows(dynamic data) {
    if (data is! List) return const [];
    final out = <ProfileFollowRow>[];
    for (final row in data) {
      if (row is! Map) continue;
      try {
        out.add(ProfileFollowRow.fromRpc(Map<String, dynamic>.from(row)));
      } catch (_) {}
    }
    return out;
  }

  @override
  Future<List<ProfileFollowRow>> listFollowers(
    String profileId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client.rpc(
      'list_profile_followers',
      params: {
        'p_profile_id': profileId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _parseRows(data);
  }

  @override
  Future<List<ProfileFollowRow>> listFollowing(
    String profileId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client.rpc(
      'list_profile_following',
      params: {
        'p_profile_id': profileId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _parseRows(data);
  }

  @override
  Future<void> followUser(String targetUserId) async {
    await _client.rpc<void>('follow_user', params: {'p_target': targetUserId});
  }

  @override
  Future<void> unfollowUser(String targetUserId) async {
    await _client.rpc<void>('unfollow_user', params: {'p_target': targetUserId});
  }

  @override
  Future<bool> isFollowing(String targetUserId) async {
    final v = await _client.rpc<dynamic>('is_following_user', params: {'p_target': targetUserId});
    if (v is bool) return v;
    if (v == null) return false;
    throw StateError('is_following_user: expected bool, got ${v.runtimeType}');
  }

  @override
  Future<Map<String, bool>> isFollowingBatch(List<String> targetUserIds) async {
    final ids = targetUserIds.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) return const {};

    // Best-effort RPC (очень быстрый: один roundtrip).
    try {
      final data = await _client.rpc<dynamic>('is_following_users', params: {'p_targets': ids});
      if (data is List) {
        final out = <String, bool>{};
        for (final row in data) {
          if (row is! Map) continue;
          final m = Map<String, dynamic>.from(row);
          final id = (m['target_user_id'] ?? m['profile_id'] ?? m['target']) as String?;
          final v = m['is_following'];
          if (id == null || id.isEmpty) continue;
          if (v is bool) out[id] = v;
        }
        // Если сервер вернул неполный список — оставшиеся дотянем фоллбеком ниже.
        if (out.length == ids.length) return out;
        final missing = ids.where((e) => !out.containsKey(e)).toList();
        for (final id in missing) {
          out[id] = await isFollowing(id);
        }
        return out;
      }
    } catch (_) {
      // ignore: fallback below
    }

    // Fallback: N запросов (хуже, но работает без миграции).
    final out = <String, bool>{};
    for (final id in ids) {
      out[id] = await isFollowing(id);
    }
    return out;
  }
}

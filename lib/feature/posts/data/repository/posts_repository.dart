import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/network/supabase_edge_functions_invoker.dart';
import 'package:side_project/core/storage/prefs/post_reactions_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/post_saves_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/posts/data/models/post_feed_item.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/models/post_saver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PostsRepository {
  /// Публичная лента пользователя: только живые (не архив, не удалённые) посты.
  Future<List<PostModel>> listUserFeed(String userId, {int limit = 24, int offset = 0});

  /// Текущий пользователь: свои посты в архиве (не удалённые).
  Future<List<PostModel>> listMyArchivedPosts({int limit = 24, int offset = 0});

  /// Лента профиля одним RPC: пост + медиа + автор + моя реакция; кэши обновляются внутри.
  Future<List<PostFeedItem>> listUserFeedEnriched({
    required String userId,
    required int limit,
    required int offset,
  });

  /// То же, что enriched, но keyset (быстрее на длинных лентах). Курсор — последний пост порции (самый старый).
  /// [clusterId] — только посты кластера; [onlyWithoutCluster] — только без кластера; иначе вся лента.
  Future<List<PostFeedItem>> listUserFeedEnrichedCursor({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorPostId,
    String? clusterId,
    bool onlyWithoutCluster = false,
  });

  /// Hot 24h одним RPC (MV + пост + автор + моя реакция).
  Future<List<PostFeedItem>> listHotFeedEnriched({int limit = 24, int offset = 0});

  /// Пост по id (с медиа).
  Future<PostModel?> getById(String postId);

  /// Один RPC: пост + автор + моя реакция + сохранено (для детального экрана).
  Future<PostFeedItem?> getPostEnriched(String postId);

  /// Set current user's reaction explicitly (race-safe).
  /// kind: 'like' | 'dislike' | null
  Future<String?> setMyReaction(String postId, String? kind);

  /// Current user's reaction kind for this post: 'like' | 'dislike' | null.
  Future<String?> getMyReactionKind(String postId);

  /// Batch: {postId -> kind} for given post ids.
  Future<Map<String, String>> getMyReactionKindsBatch(List<String> postIds);

  /// Cached reaction kind (instant UI): 'like' | 'dislike' | null.
  Future<String?> getCachedMyReactionKind(String postId);

  /// Cached reactions for a batch of posts (single local read).
  Future<Map<String, String>> getCachedMyReactionKindsBatch(List<String> postIds);

  /// Fetch reactions from server and write them to local cache.
  /// For ids missing in server response -> cached kind becomes null (removed).
  Future<Map<String, String>> fetchAndCacheMyReactionKindsBatch(List<String> postIds);

  /// Best-effort sync of pending desired reactions.
  Future<void> syncPendingReactions();

  /// Горячая лента за 24 часа (materialized view).
  Future<List<PostModel>> listHot24h({int limit = 24, int offset = 0});

  /// Hard delete post + media (DB + Storage).
  Future<void> deletePost(String postId);

  /// Сохранён ли пост у текущего пользователя.
  Future<bool> isPostSavedByMe(String postId);

  /// Локальный кэш «сохранено» (из ленты / прошлых заходов); `null` если неизвестно.
  Future<bool?> getCachedIsPostSaved(String postId);

  /// Добавить в сохранённые (идемпотентно: повторный insert не падает).
  Future<void> savePost(String postId);

  /// Убрать из сохранённых.
  Future<void> unsavePost(String postId);

  /// Кто сохранил пост (только для автора поста; иначе пустой список).
  Future<List<PostSaver>> listPostSavers(String postId, {int limit = 50, int offset = 0});

  /// Скрыть пост из лент (архив) или вернуть в ленту — только свой пост.
  Future<void> setPostArchived(String postId, bool archived);
}

@LazySingleton(as: PostsRepository)
class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl(this._client, this._edge, this._reactionsStorage, this._savesStorage, this._profileMiniCache);

  final SupabaseClient _client;
  final SupabaseEdgeFunctionsInvoker _edge;
  final PostReactionsPrefsStorage _reactionsStorage;
  final PostSavesPrefsStorage _savesStorage;
  final ProfileMiniCacheStorage _profileMiniCache;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<List<PostModel>> listUserFeed(String userId, {int limit = 24, int offset = 0}) async {
    final data = await _client
        .from('posts')
        .select('*, post_media(*)')
        .eq('user_id', userId)
        .eq('is_archived', false)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final list = data as List<dynamic>;
    return list.map((e) => PostModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(growable: false);
  }

  @override
  Future<List<PostModel>> listMyArchivedPosts({int limit = 24, int offset = 0}) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const [];
    final data = await _client
        .from('posts')
        .select('*, post_media(*)')
        .eq('user_id', uid)
        .eq('is_archived', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final list = data as List<dynamic>;
    return list.map((e) => PostModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(growable: false);
  }

  @override
  Future<List<PostFeedItem>> listUserFeedEnriched({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    if (userId.trim().isEmpty) return const [];
    final res = await _client.rpc(
      'list_user_feed_enriched',
      params: {
        'p_user_id': userId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _consumeEnrichedRpc(res);
  }

  @override
  Future<List<PostFeedItem>> listUserFeedEnrichedCursor({
    required String userId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorPostId,
    String? clusterId,
    bool onlyWithoutCluster = false,
  }) async {
    if (userId.trim().isEmpty) return const [];
    // Не передаём p_cluster_id / p_only_without_cluster, если фильтр не нужен — иначе PostgREST
    // может не сопоставить запрос со старой 4-параметровой функцией на БД без миграции → 404.
    final params = <String, dynamic>{
      'p_user_id': userId,
      'p_limit': limit,
    };
    final cid = clusterId?.trim();
    if (onlyWithoutCluster) {
      params['p_only_without_cluster'] = true;
    } else if (cid != null && cid.isNotEmpty) {
      params['p_cluster_id'] = cid;
    }
    if (cursorPostId != null && cursorCreatedAt != null && cursorPostId.isNotEmpty) {
      params['p_cursor_created_at'] = cursorCreatedAt.toUtc().toIso8601String();
      params['p_cursor_id'] = cursorPostId;
    }
    final res = await _client.rpc('list_user_feed_enriched_cursor', params: params);
    return _consumeEnrichedRpc(res);
  }

  @override
  Future<List<PostFeedItem>> listHotFeedEnriched({int limit = 24, int offset = 0}) async {
    final res = await _client.rpc(
      'list_hot_feed_enriched',
      params: {
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _consumeEnrichedRpc(res);
  }

  Future<List<PostFeedItem>> _consumeEnrichedRpc(dynamic res) async {
    if (res is! List) return const [];

    final uid = _uid;
    final items = <PostFeedItem>[];
    final reactionUpdates = <String, String?>{};
    final savedUpdates = <String, bool>{};

    for (final row in res) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final postRaw = m['post'];
      final authorRaw = m['author'];
      final myReaction = m['my_reaction'];
      final mySavedRaw = m['my_saved'];

      if (postRaw is! Map) continue;
      final postMap = Map<String, dynamic>.from(postRaw);
      final post = PostModel.fromJson(postMap);

      String? authorUsername;
      String? authorAvatarUrl;
      String? authorId;
      if (authorRaw is Map) {
        final am = Map<String, dynamic>.from(authorRaw);
        authorId = am['id'] as String?;
        final u = (am['username'] as String?)?.trim();
        final a = (am['avatar_url'] as String?)?.trim();
        authorUsername = (u != null && u.isNotEmpty) ? u : null;
        authorAvatarUrl = (a != null && a.isNotEmpty) ? a : null;
      }

      String? kind;
      if (myReaction is String && myReaction.isNotEmpty) {
        kind = myReaction;
      }

      final mySaved = mySavedRaw is bool
          ? mySavedRaw
          : (mySavedRaw is String &&
                  (mySavedRaw == 'true' || mySavedRaw == 't' || mySavedRaw == '1'));

      items.add(
        PostFeedItem(
          post: post,
          authorUsername: authorUsername,
          authorAvatarUrl: authorAvatarUrl,
          myReactionKind: kind,
          mySaved: mySaved,
        ),
      );

      if (authorId != null && authorId.isNotEmpty) {
        unawaited(_profileMiniCache.write(authorId, username: authorUsername, avatarUrl: authorAvatarUrl));
      }

      reactionUpdates[post.id] = kind;
      savedUpdates[post.id] = mySaved;
    }

    if (uid != null && uid.isNotEmpty && reactionUpdates.isNotEmpty) {
      await _reactionsStorage.setCachedKindsBatch(uid, reactionUpdates);
    }
    if (uid != null && uid.isNotEmpty && savedUpdates.isNotEmpty) {
      await _savesStorage.setCachedBatch(uid, savedUpdates);
    }

    return items;
  }

  @override
  Future<PostModel?> getById(String postId) async {
    final data = await _client.from('posts').select('*, post_media(*)').eq('id', postId).maybeSingle();
    if (data == null) return null;
    return PostModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<PostFeedItem?> getPostEnriched(String postId) async {
    final id = postId.trim();
    if (id.isEmpty) return null;
    final res = await _client.rpc('get_post_enriched', params: {'p_post_id': id});
    final list = await _consumeEnrichedRpc(res);
    if (list.isEmpty) return null;
    return list.first;
  }

  @override
  Future<String?> setMyReaction(String postId, String? kind) async {
    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      await _reactionsStorage.setCachedKind(uid, postId, kind);
      if (kind == null || kind.isEmpty) {
        await _reactionsStorage.clearPending(uid, postId);
      } else {
        await _reactionsStorage.setPendingDesired(uid, postId, kind);
      }
    }

    final res = await _client.rpc('set_post_reaction', params: {'p_post_id': postId, 'p_kind': kind});

    String? serverKind;
    if (res is List && res.isNotEmpty && res.first is Map) {
      final m = Map<String, dynamic>.from(res.first as Map);
      final v = m['kind'];
      serverKind = v is String ? v : null;
    } else if (res is Map) {
      final m = Map<String, dynamic>.from(res);
      final v = m['kind'];
      serverKind = v is String ? v : null;
    }

    if (uid != null && uid.isNotEmpty) {
      if (serverKind == kind) {
        await _reactionsStorage.clearPending(uid, postId);
      }
      await _reactionsStorage.setCachedKind(uid, postId, serverKind);
    }

    return serverKind;
  }

  @override
  Future<String?> getMyReactionKind(String postId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return null;
    final data = await _client
        .from('post_reactions')
        .select('kind')
        .eq('post_id', postId)
        .eq('user_id', uid)
        .maybeSingle();
    if (data == null) return null;
    final m = Map<String, dynamic>.from(data);
    final v = m['kind'];
    return v is String && v.isNotEmpty ? v : null;
  }

  @override
  Future<Map<String, String>> getMyReactionKindsBatch(List<String> postIds) async {
    if (postIds.isEmpty) return const {};
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const {};

    final res = await _client.rpc('get_my_post_reactions', params: {'p_post_ids': postIds});
    if (res is! List) return const {};

    final out = <String, String>{};
    for (final row in res) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final pid = m['post_id'];
      final k = m['kind'];
      if (pid is String && k is String && k.isNotEmpty) {
        out[pid] = k;
      }
    }
    return out;
  }

  @override
  Future<String?> getCachedMyReactionKind(String postId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return null;
    return await _reactionsStorage.readCachedKind(uid, postId);
  }

  @override
  Future<Map<String, String>> getCachedMyReactionKindsBatch(List<String> postIds) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const {};
    if (postIds.isEmpty) return const {};
    final all = await _reactionsStorage.readCachedKinds(uid);
    if (all.isEmpty) return const {};
    final out = <String, String>{};
    for (final id in postIds) {
      final k = all[id];
      if (k != null && k.isNotEmpty) out[id] = k;
    }
    return out;
  }

  @override
  Future<Map<String, String>> fetchAndCacheMyReactionKindsBatch(List<String> postIds) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const {};
    if (postIds.isEmpty) return const {};

    final server = await getMyReactionKindsBatch(postIds);
    final updates = <String, String?>{};
    for (final id in postIds) {
      updates[id] = server[id]; // null removes
    }
    await _reactionsStorage.setCachedKindsBatch(uid, updates);
    return server;
  }

  @override
  Future<void> syncPendingReactions() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    final pending = await _reactionsStorage.readPendingDesired(uid);
    if (pending.isEmpty) return;

    final ids = pending.keys.where((e) => e.isNotEmpty).toList(growable: false);
    if (ids.isEmpty) return;

    Map<String, String> serverMap = const {};
    try {
      serverMap = await getMyReactionKindsBatch(ids);
    } catch (_) {}

    for (final e in pending.entries) {
      final postId = e.key;
      final desired = e.value;
      if (postId.isEmpty || (desired != 'like' && desired != 'dislike')) continue;
      try {
        final server = serverMap[postId] ?? await getMyReactionKind(postId);
        if (server == desired) {
          await _reactionsStorage.clearPending(uid, postId);
          continue;
        }
        final after = await setMyReaction(postId, desired);
        if (after == desired) {
          await _reactionsStorage.clearPending(uid, postId);
        }
      } catch (_) {
        // keep pending, will retry next time
      }
    }
  }

  @override
  Future<List<PostModel>> listHot24h({int limit = 24, int offset = 0}) async {
    final enriched = await listHotFeedEnriched(limit: limit, offset: offset);
    return enriched.map((e) => e.post).toList(growable: false);
  }

  @override
  Future<void> deletePost(String postId) async {
    final res = await _edge.invoke('delete_post', body: {'post_id': postId});
    if (res.data is Map) {
      final m = Map<String, dynamic>.from(res.data as Map);
      if (m['ok'] == true) return;
    }
    throw StateError('delete_post: unexpected response');
  }

  @override
  Future<bool?> getCachedIsPostSaved(String postId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return null;
    return _savesStorage.readCachedForPost(uid, postId);
  }

  @override
  Future<bool> isPostSavedByMe(String postId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return false;
    final res = await _client.rpc('is_post_saved_by_me', params: {'p_post_id': postId});
    final b = res is bool ? res : false;
    await _savesStorage.setCached(uid, postId, b);
    return b;
  }

  @override
  Future<void> savePost(String postId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('savePost: not authenticated');
    }
    await _client.rpc('save_post', params: {'p_post_id': postId});
    await _savesStorage.setCached(uid, postId, true);
  }

  @override
  Future<void> unsavePost(String postId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('unsavePost: not authenticated');
    }
    await _client.rpc('unsave_post', params: {'p_post_id': postId});
    await _savesStorage.setCached(uid, postId, false);
  }

  @override
  Future<List<PostSaver>> listPostSavers(String postId, {int limit = 50, int offset = 0}) async {
    final data = await _client.rpc(
      'list_post_savers',
      params: {'p_post_id': postId, 'p_limit': limit, 'p_offset': offset},
    );
    if (data is! List) return const [];

    final out = <PostSaver>[];
    for (final row in data) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final uid = m['user_id'];
      if (uid is! String) continue;
      final rawAt = m['saved_at'];
      DateTime savedAt;
      if (rawAt is String) {
        savedAt = DateTime.tryParse(rawAt) ?? DateTime.utc(1970);
      } else if (rawAt is DateTime) {
        savedAt = rawAt;
      } else {
        savedAt = DateTime.utc(1970);
      }
      out.add(
        PostSaver(
          userId: uid,
          username: m['username'] as String?,
          avatarUrl: m['avatar_url'] as String?,
          savedAt: savedAt,
        ),
      );
    }
    return out;
  }

  @override
  Future<void> setPostArchived(String postId, bool archived) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('setPostArchived: not authenticated');
    }
    await _client.from('posts').update({'is_archived': archived}).eq('id', postId).eq('user_id', uid);
  }
}

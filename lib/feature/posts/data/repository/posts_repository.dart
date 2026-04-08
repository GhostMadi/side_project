import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PostsRepository {
  /// Публичная лента пользователя: только живые (не архив, не удалённые) посты.
  Future<List<PostModel>> listUserFeed(String userId, {int limit = 24, int offset = 0});

  /// Пост по id (с медиа).
  Future<PostModel?> getById(String postId);

  /// Горячая лента за 24 часа (materialized view).
  Future<List<PostModel>> listHot24h({int limit = 24, int offset = 0});
}

@LazySingleton(as: PostsRepository)
class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl(this._client);

  final SupabaseClient _client;

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
  Future<PostModel?> getById(String postId) async {
    final data = await _client.from('posts').select('*, post_media(*)').eq('id', postId).maybeSingle();
    if (data == null) return null;
    return PostModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<PostModel>> listHot24h({int limit = 24, int offset = 0}) async {
    // MV содержит только post_id + score_24h + counters. Подтягиваем посты отдельным select.
    final hot = await _client
        .from('hot_posts_24h')
        .select('post_id')
        .order('score_24h', ascending: false)
        .range(offset, offset + limit - 1);

    final ids = (hot as List<dynamic>)
        .map((e) => (e as Map)['post_id'] as String?)
        .whereType<String>()
        .toList(growable: false);
    if (ids.isEmpty) return const [];

    final posts = await _client
        .from('posts')
        .select('*, post_media(*)')
        .inFilter('id', ids)
        .eq('is_archived', false)
        .isFilter('deleted_at', null);

    final map = <String, PostModel>{};
    for (final row in (posts as List<dynamic>)) {
      final m = PostModel.fromJson(Map<String, dynamic>.from(row as Map));
      map[m.id] = m;
    }
    return ids.map((id) => map[id]).whereType<PostModel>().toList(growable: false);
  }
}

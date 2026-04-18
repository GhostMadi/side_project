import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/post_saves_prefs_storage.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Список постов, сохранённых текущим пользователем (`list_my_saved_posts`;
/// без удалённых и без архивных).
/// Сущность поста — [PostModel] из фичи постов.
abstract class SavedListRepository {
  Future<List<PostModel>> listSavedPosts({int limit = 24, int offset = 0});
}

@LazySingleton(as: SavedListRepository)
class SavedListRepositoryImpl implements SavedListRepository {
  SavedListRepositoryImpl(this._client, this._savesStorage);

  final SupabaseClient _client;
  final PostSavesPrefsStorage _savesStorage;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<List<PostModel>> listSavedPosts({int limit = 24, int offset = 0}) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const [];

    final data = await _client.rpc(
      'list_my_saved_posts',
      params: {'p_limit': limit, 'p_offset': offset},
    );
    if (data is! List) return const [];

    final posts = <PostModel>[];
    for (final row in data) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final pr = m['post'];
      if (pr is! Map) continue;
      try {
        posts.add(PostModel.fromJson(Map<String, dynamic>.from(pr)));
      } catch (_) {}
    }
    if (posts.isNotEmpty) {
      await _savesStorage.setCachedBatch(uid, {for (final p in posts) p.id: true});
    }
    return posts;
  }
}

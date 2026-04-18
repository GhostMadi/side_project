import 'package:injectable/injectable.dart';
import 'package:side_project/feature/comment/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Страница комментариев: строки + «мои» реакции за один RPC (`list_*_enriched`).
class CommentsPage {
  const CommentsPage({required this.comments, required this.myReactionsByCommentId});

  final List<CommentModel> comments;
  final Map<String, String> myReactionsByCommentId;
}

abstract class CommentsRepository {
  /// Корневые комментарии поста (без ответов), новые сверху; [myReactionsByCommentId] с сервера в том же запросе.
  Future<CommentsPage> fetchRootComments(
    String postId, {
    int limit = 24,
    int offset = 0,
  });

  /// Прямые ответы на комментарий, старые сверху вниз; мои реакции в том же запросе.
  Future<CommentsPage> fetchReplies(
    String postId,
    String parentCommentId, {
    int limit = 50,
    int offset = 0,
  });

  /// Добавить комментарий; [parentCommentId] — ответ на другой комментарий (ветка).
  Future<CommentModel> addComment(
    String postId,
    String text, {
    String? parentCommentId,
  });

  /// Корневой комментарий (удобный алиас).
  Future<CommentModel> addRootComment(String postId, String text);

  /// Реакция текущего пользователя: `like`, `dislike` или `null` (снять). Аналог `set_post_reaction` для постов.
  Future<String?> setMyCommentReaction(String commentId, String? kind);

  /// Текущие реакции пользователя для списка id (для сверки после ошибки; основная лента — через `fetch*Comments` enriched).
  Future<Map<String, String>> getMyCommentReactionsBatch(List<String> commentIds);

  /// Одна строка комментария (для отката счётчиков после ошибки RPC).
  Future<CommentModel?> fetchCommentById(String commentId);
}

@LazySingleton(as: CommentsRepository)
class CommentsRepositoryImpl implements CommentsRepository {
  CommentsRepositoryImpl(this._client);

  final SupabaseClient _client;

  /// Явный FK-hint: PostgREST иначе может не разрешить embed `profiles`.
  static const _selectWithAuthor =
      'id, post_id, user_id, text, parent_comment_id, likes_count, dislikes_count, replies_count, created_at, edited_at, is_deleted, profiles!comments_user_id_fkey(username, avatar_url)';

  static CommentsPage _parseEnrichedRows(dynamic res) {
    if (res is! List) {
      return const CommentsPage(comments: [], myReactionsByCommentId: {});
    }
    final comments = <CommentModel>[];
    final my = <String, String>{};
    for (final raw in res) {
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);
      final cj = row['comment'];
      if (cj is! Map) continue;
      final commentMap = Map<String, dynamic>.from(cj);
      final model = CommentModel.fromApi(commentMap);
      comments.add(model);
      final k = row['my_kind'];
      if (k is String && k.isNotEmpty) {
        my[model.id] = k;
      }
    }
    return CommentsPage(comments: comments, myReactionsByCommentId: my);
  }

  @override
  Future<CommentsPage> fetchRootComments(
    String postId, {
    int limit = 24,
    int offset = 0,
  }) async {
    if (postId.trim().isEmpty) {
      return const CommentsPage(comments: [], myReactionsByCommentId: {});
    }
    final res = await _client.rpc(
      'list_post_root_comments_enriched',
      params: {
        'p_post_id': postId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _parseEnrichedRows(res);
  }

  @override
  Future<CommentsPage> fetchReplies(
    String postId,
    String parentCommentId, {
    int limit = 50,
    int offset = 0,
  }) async {
    if (postId.trim().isEmpty || parentCommentId.trim().isEmpty) {
      return const CommentsPage(comments: [], myReactionsByCommentId: {});
    }
    final res = await _client.rpc(
      'list_comment_replies_enriched',
      params: {
        'p_post_id': postId,
        'p_parent_comment_id': parentCommentId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _parseEnrichedRows(res);
  }

  @override
  Future<CommentModel> addComment(
    String postId,
    String text, {
    String? parentCommentId,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw StateError('Нужна авторизация, чтобы оставить комментарий');
    }
    final t = text.trim();
    if (t.isEmpty) {
      throw ArgumentError('Пустой комментарий');
    }
    if (t.length > 2000) {
      throw ArgumentError('Не больше 2000 символов');
    }

    final insert = <String, dynamic>{
      'post_id': postId,
      'user_id': uid,
      'text': t,
    };
    final pid = parentCommentId?.trim();
    if (pid != null && pid.isNotEmpty) {
      insert['parent_comment_id'] = pid;
    }

    final row = await _client.from('comments').insert(insert).select(_selectWithAuthor).single();

    return CommentModel.fromApi(Map<String, dynamic>.from(row));
  }

  @override
  Future<CommentModel> addRootComment(String postId, String text) => addComment(postId, text);

  @override
  Future<String?> setMyCommentReaction(String commentId, String? kind) async {
    final id = commentId.trim();
    if (id.isEmpty) throw ArgumentError('commentId');

    final res = await _client.rpc(
      'set_comment_reaction',
      params: {'p_comment_id': id, 'p_kind': kind},
    );

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
    return serverKind;
  }

  @override
  Future<Map<String, String>> getMyCommentReactionsBatch(List<String> commentIds) async {
    if (commentIds.isEmpty) return const {};
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return const {};

    final res = await _client.rpc(
      'get_my_comment_reactions',
      params: {'p_comment_ids': commentIds},
    );
    if (res is! List) return const {};

    final out = <String, String>{};
    for (final row in res) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final cid = m['comment_id'];
      final k = m['kind'];
      if (cid is String && k is String && k.isNotEmpty) {
        out[cid] = k;
      }
    }
    return out;
  }

  @override
  Future<CommentModel?> fetchCommentById(String commentId) async {
    final id = commentId.trim();
    if (id.isEmpty) return null;
    final row = await _client.from('comments').select(_selectWithAuthor).eq('id', id).maybeSingle();
    if (row == null) return null;
    return CommentModel.fromApi(Map<String, dynamic>.from(row));
  }
}

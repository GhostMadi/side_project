import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';

@freezed
abstract class CommentAuthorSnippet with _$CommentAuthorSnippet {
  const factory CommentAuthorSnippet({
    String? username,
    String? avatarUrl,
  }) = _CommentAuthorSnippet;
}

@freezed
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    required String postId,
    required String userId,
    required String text,
    String? parentCommentId,
    required int likesCount,
    @Default(0) int dislikesCount,
    /// Прямые ответы (неудалённые); с сервера `replies_count`.
    @Default(0) int repliesCount,
    required DateTime createdAt,
    DateTime? editedAt,
    required bool isDeleted,
    CommentAuthorSnippet? author,
  }) = _CommentModel;

  factory CommentModel.fromApi(Map<String, dynamic> m) {
    CommentAuthorSnippet? author;
    final p = m['profiles'];
    if (p is Map) {
      final map = Map<String, dynamic>.from(p);
      author = CommentAuthorSnippet(
        username: map['username'] as String?,
        avatarUrl: map['avatar_url'] as String?,
      );
    } else if (p is List && p.isNotEmpty && p.first is Map) {
      final map = Map<String, dynamic>.from(p.first as Map);
      author = CommentAuthorSnippet(
        username: map['username'] as String?,
        avatarUrl: map['avatar_url'] as String?,
      );
    }

    return CommentModel(
      id: m['id'] as String,
      postId: m['post_id'] as String,
      userId: m['user_id'] as String,
      text: m['text'] as String,
      parentCommentId: m['parent_comment_id'] as String?,
      likesCount: (m['likes_count'] as num?)?.toInt() ?? 0,
      dislikesCount: (m['dislikes_count'] as num?)?.toInt() ?? 0,
      repliesCount: (m['replies_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(m['created_at'] as String),
      editedAt: m['edited_at'] != null ? DateTime.tryParse(m['edited_at'].toString()) : null,
      isDeleted: m['is_deleted'] as bool? ?? false,
      author: author,
    );
  }
}

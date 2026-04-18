/// Строка из RPC [list_post_savers]: кто сохранил пост.
class PostSaver {
  const PostSaver({
    required this.userId,
    this.username,
    this.avatarUrl,
    required this.savedAt,
  });

  final String userId;
  final String? username;
  final String? avatarUrl;
  final DateTime savedAt;
}

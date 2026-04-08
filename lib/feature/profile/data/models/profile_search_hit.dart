/// Результат поиска профиля для отметок и шторки выбора.
class ProfileSearchHit {
  const ProfileSearchHit({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  factory ProfileSearchHit.fromRow(Map<String, dynamic> json) {
    return ProfileSearchHit(
      id: json['id'] as String,
      username: (json['username'] as String?)?.trim(),
      fullName: (json['full_name'] as String?)?.trim(),
      avatarUrl: (json['avatar_url'] as String?)?.trim(),
    );
  }

  /// Строка как в прежних моках: `@ник · Имя`.
  String get displayLabel {
    final u = username;
    final nick = (u != null && u.isNotEmpty) ? '@$u' : '@…';
    final name = fullName;
    if (name != null && name.isNotEmpty) {
      return '$nick · $name';
    }
    return nick;
  }
}

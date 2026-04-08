import 'dart:typed_data';

/// Комментарий к посту (муляж / ответ API). [replies] — вложенные ответы.
class ProfilePostComment {
  const ProfilePostComment({
    required this.authorLabel,
    required this.text,
    this.timeLabel,
    this.likesCount,
    this.replies = const [],
  });

  final String authorLabel;
  final String text;
  final String? timeLabel;

  /// Лайки на этом комментарии (для шторки).
  final int? likesCount;

  final List<ProfilePostComment> replies;
}

/// Элемент сетки постов на экране профиля (пока без бэкенда — список снаружи).
class ProfilePostPreview {
  const ProfilePostPreview({
    required this.id,
    required this.thumbnailUrl,
    this.thumbnailAspectRatio,
    this.mediaUrls,
    this.title,
    this.subtitle,
    this.description,
    this.taggedAccountLabels = const [],
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.comments,
    this.caption,
    this.likesCount,
    this.dislikesCount,
    this.commentsCount,
    this.sharesCount,
    this.savesCount,
    this.timeLabel,
  });

  final String id;
  final String thumbnailUrl;

  /// Соотношение сторон превью (width/height). Для Pinterest-подобной сетки.
  /// Если null — считаем квадратом.
  final double? thumbnailAspectRatio;

  /// Несколько кадров в карусели; если пусто — один [thumbnailUrl].
  final List<String>? mediaUrls;

  /// Заголовок и подзаголовок поста (карточка деталей).
  final String? title;
  final String? subtitle;

  /// Развёрнутый текст; если пусто, в UI можно опереться на [caption].
  final String? description;

  /// Подписи отмеченных профилей, напр. «@nick · Имя».
  final List<String> taggedAccountLabels;

  /// Геометка для карты; оба заданы — показываем «место на карте».
  final double? latitude;
  final double? longitude;

  /// Короткая подпись к точке («Алматы»).
  final String? locationLabel;

  /// Явный список комментариев; иначе в деталях можно сгенерировать муляж по [commentsCount].
  final List<ProfilePostComment>? comments;

  final String? caption;

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite;
  final int? likesCount;
  final int? dislikesCount;
  final int? commentsCount;
  final int? sharesCount;
  final int? savesCount;

  /// Подпись времени («2 ч. назад»).
  final String? timeLabel;

  List<String> get allMediaUrls {
    final m = mediaUrls;
    if (m != null && m.isNotEmpty) {
      return m;
    }
    return [thumbnailUrl];
  }

  int get effectiveLikes => likesCount ?? 0;
  int get effectiveDislikes => dislikesCount ?? 0;
  int get effectiveComments => commentsCount ?? 0;
  int get effectiveShares => sharesCount ?? 0;
  int get effectiveSaves => savesCount ?? 0;
}

String profilePostHeroTag(String postId) => 'profile_post_$postId';

/// Строка с количеством фото в коллекции.
String profileCollectionCountLabel(int count) {
  if (count <= 0) return 'Нет фото';
  return '$count фото';
}

/// Муляж числа постов на карточке черновика кластера (пока сетка пустая).
const int kProfileClusterDraftMockPostCount = 12;

/// Размер сетки муляжа профиля / карты.
const int kProfileMockGridPostCount = 16;

/// Колонки сетки координат мок-постов (4×4 при 16 постах).
const int kProfileMockGeoGridCols = 4;

/// Коллекция: обложка, заголовок, подпись между заголовком и счётчиком, посты для сетки.
class ProfileCollectionPreview {
  const ProfileCollectionPreview({
    required this.id,
    required this.title,
    required this.posts,
    this.subtitle,
    this.coverImageUrl,
    this.coverMemory,
    this.mockPostsCount,
  });

  final String id;
  final String title;

  /// Короткая подпись между названием и количеством (например «Полная лента»).
  final String? subtitle;
  final List<ProfilePostPreview> posts;

  /// Явная обложка; иначе — превью первого поста.
  final String? coverImageUrl;

  /// Локальное изображение (черновик кластера и т.п.); приоритетнее сети.
  final Uint8List? coverMemory;

  /// Если задано — подпись счётчика как при таком числе постов (муляж для UI).
  final int? mockPostsCount;

  String get countLabel => mockPostsCount != null
      ? profileCollectionCountLabel(mockPostsCount!)
      : profileCollectionCountLabel(posts.length);

  String get effectiveCoverUrl {
    if (coverMemory != null && coverMemory!.isNotEmpty) return '';
    final c = coverImageUrl?.trim();
    if (c != null && c.isNotEmpty) return c;
    for (final p in posts) {
      final t = p.thumbnailUrl.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}

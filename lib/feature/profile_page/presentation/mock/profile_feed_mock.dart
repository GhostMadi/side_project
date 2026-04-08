import 'package:side_project/feature/profile_page/presentation/models/profile_feed_preview.dart';

double? _mockProfilePostLat(int i) {
  if (!_mockProfilePostHasGeo(i)) {
    return null;
  }
  const base = 43.218;
  const cols = kProfileMockGeoGridCols;
  final col = i % cols;
  final row = i ~/ cols;
  return base + row * 0.0042 + (col % 3) * 0.0004;
}

double? _mockProfilePostLng(int i) {
  if (!_mockProfilePostHasGeo(i)) {
    return null;
  }
  const base = 76.905;
  const cols = kProfileMockGeoGridCols;
  final col = i % cols;
  final row = i ~/ cols;
  return base + col * 0.0048 + row * 0.00045;
}

String? _mockProfilePostLocationLabel(int i) {
  if (!_mockProfilePostHasGeo(i)) {
    return null;
  }
  const labels = [
    'Алматы, центр',
    'Медеу',
    'Кок-Тобе',
    'Алатау',
    'Сайран',
    'Абай',
  ];
  return labels[i % labels.length];
}

bool _mockProfilePostHasGeo(int i) => true;

double _mockAspectRatio(int i) {
  // Pinterest-like: разные высоты при одинаковой ширине.
  // 0.75 (высокая), 1.0 (квадрат), 1.25 (широкая)
  return switch (i % 6) {
    0 || 3 => 0.75,
    1 || 4 => 1.0,
    _ => 1.25,
  };
}

List<String> _mockLocationLabelsForTheme(String themeKey, int count) {
  const travel = ['Медеу', 'Чимбулак', 'Большое Алматинское озеро', 'Алатау', 'Кок-Жайляу', 'Тургень', 'Иссык', 'Заилийский Алатау'];
  const city = ['Абая — проспект', 'Арбат', 'Green Mall', 'Парк 28 панфиловцев', 'Назарбаева', 'Театр оперы', 'Кок-Тобе', 'Сайран'];
  const cafe = ['Кофейня на Достык', 'Рынок Зелёный базар', 'Food court', 'Патиссери', 'Винный бар', 'Брунч'];
  const night = ['Ночной Алматы', 'Клубный квартал', 'Крыша', 'Неон', 'Закат с террасы'];
  return switch (themeKey) {
    'travel' => List.generate(count, (i) => travel[i % travel.length]),
    'city' => List.generate(count, (i) => city[i % city.length]),
    'cafe' => List.generate(count, (i) => cafe[i % cafe.length]),
    'night' => List.generate(count, (i) => night[i % night.length]),
    _ => List.generate(count, (i) => _mockProfilePostLocationLabel(i) ?? 'Алматы'),
  };
}

/// Посты одной тематической коллекции: свои seed’ы картинок и свой кластер на карте.
List<ProfilePostPreview> _mockThemedPosts({
  required String idPrefix,
  required String picSeedPrefix,
  required String themeKey,
  required int count,
  required double latBase,
  required double lngBase,
  double latStep = 0.0038,
  double lngStep = 0.0044,
}) {
  final labels = _mockLocationLabelsForTheme(themeKey, count);
  return List.generate(
    count,
    (j) {
      final hasCarousel = j % 5 == 0;
      return ProfilePostPreview(
        id: '${idPrefix}_$j',
        thumbnailUrl: 'https://picsum.photos/seed/${picSeedPrefix}_thumb_$j/1080/1080',
        thumbnailAspectRatio: _mockAspectRatio(j),
        mediaUrls: hasCarousel
            ? [
                'https://picsum.photos/seed/${picSeedPrefix}_${j}_a/1080/1080',
                'https://picsum.photos/seed/${picSeedPrefix}_${j}_b/1080/1080',
              ]
            : null,
        title: switch (themeKey) {
          'travel' => j.isEven ? 'Выезд на природу' : 'Тропа и вид',
          'city' => j.isEven ? 'Городской ритм' : 'Улица дня',
          'cafe' => j.isEven ? 'Кофе и завтрак' : 'Локальное место',
          'night' => j.isEven ? 'Огни города' : 'Вечерний кадр',
          _ => null,
        },
        subtitle: switch (themeKey) {
          'travel' => 'Серия «где-то рядом с горами»',
          'city' => 'Центр и новые кварталы',
          'cafe' => 'Где сидеть и пробовать',
          'night' => 'После заката',
          _ => null,
        },
        description: 'Коллекция «$themeKey», кадр ${j + 1}. Муляж для превью и карты.',
        taggedAccountLabels: j % 2 == 0 ? const ['@aigerim_k · Айгерим К.'] : const <String>[],
        latitude: latBase + (j % 4) * latStep + (j ~/ 4) * 0.0009,
        longitude: lngBase + (j ~/ 4) * lngStep + (j % 3) * 0.0011,
        locationLabel: labels[j],
        caption: 'Снимок ${j + 1} · $themeKey',
        likesCount: 120 + j * 41,
        dislikesCount: j % 7,
        commentsCount: 3 + j * 2,
        sharesCount: 1 + j,
        savesCount: 20 + j * 5,
        timeLabel: '${j + 1} дн. назад',
      );
    },
  );
}

/// Временный муляж сетки (picsum). Заменить списком с API.
abstract final class ProfilePostsMock {
  static List<ProfilePostPreview> get grid => List.generate(
    kProfileMockGridPostCount,
    (i) => ProfilePostPreview(
      id: 'mock_$i',
      thumbnailUrl: 'https://picsum.photos/seed/side_profile_${i}_0/1080/1080',
      thumbnailAspectRatio: _mockAspectRatio(i),
      mediaUrls: i % 4 == 0
          ? [
              'https://picsum.photos/seed/side_profile_${i}_0/1080/1080',
              'https://picsum.photos/seed/side_profile_${i}_1/1080/1080',
              'https://picsum.photos/seed/side_profile_${i}_2/1080/1080',
            ]
          : null,
      title: i % 3 == 0 ? 'Вечер в городе' : (i == 1 ? 'Новая подборка' : null),
      subtitle: i % 3 == 0 ? 'Фото с прогулки' : null,
      description:
          'Тестовая подпись к посту — как в ленте. Кадр ${i + 1}, можно листать фото выше. '
          'Здесь может быть длинное описание события или мысли.',
      taggedAccountLabels: i % 2 == 0
          ? const ['@aigerim_k · Айгерим К.', '@marat_photo · Марат']
          : const <String>[],
      latitude: _mockProfilePostLat(i),
      longitude: _mockProfilePostLng(i),
      locationLabel: _mockProfilePostLocationLabel(i),
      comments: i == 0
          ? const [
              ProfilePostComment(
                authorLabel: '@daniyar_s',
                text: 'Классный кадр!',
                timeLabel: '1 ч. назад',
                likesCount: 24,
                replies: [
                  ProfilePostComment(
                    authorLabel: '@author_you',
                    text: 'Спасибо!',
                    timeLabel: '50 мин. назад',
                    likesCount: 3,
                  ),
                  ProfilePostComment(
                    authorLabel: '@lina_events',
                    text: 'Согласна, свет отличный.',
                    timeLabel: '40 мин. назад',
                    likesCount: 8,
                  ),
                ],
              ),
              ProfilePostComment(
                authorLabel: '@lina_events',
                text: 'Жду продолжения серии.',
                timeLabel: '3 ч. назад',
                likesCount: 5,
                replies: [
                  ProfilePostComment(
                    authorLabel: '@marat_photo',
                    text: '+1, тоже жду',
                    timeLabel: '2 ч. назад',
                    likesCount: 1,
                  ),
                ],
              ),
            ]
          : null,
      caption:
          'Тестовая подпись к посту — как в ленте. Кадр ${i + 1}, можно листать фото выше.',
      likesCount: 48 + i * 127,
      dislikesCount: 1 + i,
      commentsCount: 2 + i * 3,
      sharesCount: 5 + i * 2,
      savesCount: 18 + i * 11,
      timeLabel: i == 0 ? 'Сейчас' : '${i + 1} ч. назад',
    ),
  );

  /// Несколько коллекций: разные обложки, разный состав постов и разные кластеры на карте.
  static List<ProfileCollectionPreview> get collections {
    final all = grid;
    final travelPosts = _mockThemedPosts(
      idPrefix: 'mock_travel',
      picSeedPrefix: 'almaty_travel',
      themeKey: 'travel',
      count: 9,
      latBase: 43.128,
      lngBase: 76.978,
    );
    final cityPosts = _mockThemedPosts(
      idPrefix: 'mock_city',
      picSeedPrefix: 'almaty_urban',
      themeKey: 'city',
      count: 10,
      latBase: 43.245,
      lngBase: 76.868,
    );
    final cafePosts = _mockThemedPosts(
      idPrefix: 'mock_cafe',
      picSeedPrefix: 'almaty_cafe',
      themeKey: 'cafe',
      count: 7,
      latBase: 43.238,
      lngBase: 76.918,
      latStep: 0.0022,
      lngStep: 0.0028,
    );
    final nightPosts = _mockThemedPosts(
      idPrefix: 'mock_night',
      picSeedPrefix: 'almaty_night',
      themeKey: 'night',
      count: 6,
      latBase: 43.212,
      lngBase: 76.892,
      latStep: 0.0045,
      lngStep: 0.0036,
    );

    return [
      ProfileCollectionPreview(
        id: 'c_all',
        title: 'Все публикации',
        subtitle: 'Полная лента',
        coverImageUrl: 'https://picsum.photos/seed/coll_cover_all_v2/800/800',
        posts: all,
      ),
      ProfileCollectionPreview(
        id: 'c_travel',
        title: 'Горы и выезды',
        subtitle: 'Тропы, озёра, вид с высоты',
        coverImageUrl: 'https://picsum.photos/seed/coll_cover_travel_v2/800/800',
        posts: travelPosts,
      ),
      ProfileCollectionPreview(
        id: 'c_city',
        title: 'Город',
        subtitle: 'Улицы, площади, архитектура',
        coverImageUrl: 'https://picsum.photos/seed/coll_cover_city_v2/800/800',
        posts: cityPosts,
      ),
      ProfileCollectionPreview(
        id: 'c_cafe',
        title: 'Кофе и места',
        subtitle: 'Завтраки, встречи, вкусное',
        coverImageUrl: 'https://picsum.photos/seed/coll_cover_cafe_v2/800/800',
        posts: cafePosts,
      ),
      ProfileCollectionPreview(
        id: 'c_night',
        title: 'Ночь',
        subtitle: 'Огни и вечерние кадры',
        coverImageUrl: 'https://picsum.photos/seed/coll_cover_night_v2/800/800',
        posts: nightPosts,
      ),
    ];
  }
}

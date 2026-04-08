import 'package:side_project/core/shared/app_map.dart';

/// Данные для обзора события с карты (из API / metadata маркера).
class EventPinPreview {
  const EventPinPreview({
    required this.organizerId,
    required this.organizerName,
    required this.organizerCity,
    this.organizerAvatarUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.startsAt,
    required this.venueLabel,
    this.coverImageUrls = const [],
  });

  final String organizerId;
  final String organizerName;
  final String organizerCity;
  final String? organizerAvatarUrl;
  final String title;
  final String subtitle;
  final String description;
  final DateTime startsAt;
  final String venueLabel;
  /// Обложки события (листаются в шите). Пусто — показываем плейсхолдер с эмодзи маркера.
  final List<String> coverImageUrls;

  static const _monthsRu = [
    '',
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  String get formattedDateTime {
    final d = startsAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(d.year, d.month, d.day);
    final t =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (eventDay == today) return 'Сегодня · $t';
    if (eventDay == today.add(const Duration(days: 1))) return 'Завтра · $t';
    return '${d.day} ${_monthsRu[d.month]} ${d.year} · $t';
  }

  static EventPinPreview fromMapMarker(MapMarker m) {
    final meta = m.metadata;
    if (meta != null && meta['title'] is String) {
      return EventPinPreview(
        organizerId: meta['organizerId'] as String? ?? 'org_${m.id}',
        organizerName: meta['organizerName'] as String? ?? 'Организатор',
        organizerCity: meta['organizerCity'] as String? ?? 'Алматы',
        organizerAvatarUrl: meta['organizerAvatarUrl'] as String?,
        title: meta['title'] as String,
        subtitle: meta['subtitle'] as String? ?? '',
        description: meta['description'] as String? ?? '',
        startsAt: _parseDate(meta['startsAt']) ?? DateTime.now().add(const Duration(hours: 3)),
        venueLabel: meta['venueLabel'] as String? ?? '',
        coverImageUrls: _parseCoverUrls(meta),
      );
    }
    return _fallback(m);
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static EventPinPreview _fallback(MapMarker m) {
    final seed = m.id.hashCode.abs();
    final titles = [
      'Открытая встреча у кофейни',
      'Вечер настолок',
      'Живая музыка на террасе',
      'Мастер-класс для гостей',
      'Дегустация сезонного меню',
      'Йога на крыше',
      'Распродажа коллекции',
    ];
    final orgs = [
      ('org_lumos', 'Lumos Coffee', 'Алматы, Бостандык'),
      ('org_green', 'Green Point', 'Алматы, Абай'),
      ('org_urban', 'Urban Yard', 'Алматы, центр'),
      ('org_wave', 'Wave Studio', 'Алматы, Самал'),
    ];
    final org = orgs[seed % orgs.length];
    return EventPinPreview(
      organizerId: org.$1,
      organizerName: org.$2,
      organizerCity: org.$3,
      organizerAvatarUrl: null,
      title: titles[seed % titles.length],
      subtitle: 'Приходите сегодня — расскажем о новинках и познакомимся с гостями.',
      description:
          'Короткий формат для бизнеса: показать, что сегодня у вас проходит событие, '
          'без лишнего текста. Уточнения — в чате с заведением.',
      startsAt: DateTime.now().add(Duration(hours: 2 + seed % 6)),
      venueLabel: 'Рядом с меткой на карте · ${org.$3}',
      coverImageUrls: const [],
    );
  }

  static List<String> _parseCoverUrls(Map<String, dynamic> meta) {
    final raw = meta['coverImageUrls'];
    if (raw is List) {
      return raw.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    final single = meta['coverImageUrl'];
    if (single is String && single.trim().isNotEmpty) {
      return [single.trim()];
    }
    return [];
  }
}

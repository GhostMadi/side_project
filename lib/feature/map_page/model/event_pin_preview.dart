import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/posts/data/models/post_feed_item.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';

/// Данные для обзора события с карты (из API / metadata маркера).
class EventPinPreview {
  const EventPinPreview({
    required this.organizerId,
    required this.organizerName,
    this.organizerUsername,
    this.organizerFullName,
    required this.organizerCity,
    this.organizerAvatarUrl,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.venueLabel,
    this.address,
    this.durationLabel,
    this.coverImageUrls = const [],
  });

  final String organizerId;
  final String organizerName;
  final String? organizerUsername;
  final String? organizerFullName;
  final String organizerCity;
  final String? organizerAvatarUrl;
  final String title;
  final String description;
  final DateTime startsAt;
  final String venueLabel;
  final String? address;
  final String? durationLabel;

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
    final t = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (eventDay == today) return 'Сегодня · $t';
    if (eventDay == today.add(const Duration(days: 1))) return 'Завтра · $t';
    return '${d.day} ${_monthsRu[d.month]} ${d.year} · $t';
  }

  /// Пост с ленты / [getPostEnriched] (автор, медиа, привязанный маркер).
  static EventPinPreview fromPostFeedItem(PostFeedItem item) {
    final p = item.post;
    final marker = p.marker;
    final urls = <String>[];
    for (final m in p.media) {
      final u = m.gridStaticImageUrl;
      if (u != null && u.trim().isNotEmpty) {
        urls.add(u.trim());
      }
    }
    final un = item.authorUsername?.trim();
    return EventPinPreview(
      organizerId: p.userId,
      organizerName: (un != null && un.isNotEmpty) ? un : 'Автор',
      organizerUsername: un,
      organizerFullName: null,
      organizerCity: '',
      organizerAvatarUrl: item.authorAvatarUrl,
      title: () {
        final t = p.title?.trim();
        if (t != null && t.isNotEmpty) return t;
        final mt = marker?.addressText?.trim();
        if (mt != null && mt.isNotEmpty) return mt;
        return '';
      }(),
      description: p.description?.trim() ?? '',
      startsAt: marker != null
          ? p.resolvedMarkerEventWindow.start.toLocal()
          : p.createdAt.toLocal(),
      venueLabel: marker != null ? _mapMarkerStatusRu(marker.status) : '',
      coverImageUrls: urls,
    );
  }

  /// Пост как в REST (`posts + post_media`) + мини-инфо об авторе (если есть).
  static EventPinPreview fromPostModel(
    PostModel p, {
    String? authorUsername,
    String? authorFullName,
    String? authorAvatarUrl,
  }) {
    final urls = <String>[];
    for (final m in p.media) {
      final u = m.gridStaticImageUrl;
      if (u != null && u.trim().isNotEmpty) {
        urls.add(u.trim());
      }
    }
    final t = p.title?.trim();
    final uname = authorUsername?.trim();
    final fname = authorFullName?.trim();
    final displayName = (fname != null && fname.isNotEmpty)
        ? fname
        : ((uname != null && uname.isNotEmpty) ? '@$uname' : 'Автор');
    return EventPinPreview(
      organizerId: p.userId,
      organizerName: displayName,
      organizerUsername: (uname != null && uname.isNotEmpty) ? uname : null,
      organizerFullName: (fname != null && fname.isNotEmpty) ? fname : null,
      organizerCity: '',
      organizerAvatarUrl: (authorAvatarUrl != null && authorAvatarUrl.trim().isNotEmpty)
          ? authorAvatarUrl.trim()
          : null,
      // Title must come from Post only; if empty -> show nothing.
      title: (t != null && t.isNotEmpty) ? t : '',
      description: p.description?.trim() ?? '',
      startsAt: p.createdAt.toLocal(),
      venueLabel: '',
      coverImageUrls: urls,
    );
  }

  static String _mapMarkerStatusRu(String status) {
    switch (status) {
      case 'upcoming':
        return 'Скоро';
      case 'active':
        return 'Идёт сейчас';
      case 'finished':
        return 'Завершено';
      case 'cancelled':
        return 'Отменено';
      default:
        return status;
    }
  }

  static EventPinPreview fromMapMarker(MapMarker m) {
    final meta = m.metadata;
    if (meta != null) {
      final startsAt = _parseDate(meta['startsAt']) ?? DateTime.now().add(const Duration(hours: 3));
      final endsAt = _parseDate(meta['endsAt']);
      final durationLabel = _formatDuration(startsAt, endsAt);
      final address = _markerAddress(meta);
      final cover = (meta['coverImageUrl'] as String?)?.trim();
      final title = (meta['title'] as String?)?.trim() ?? '';
      return EventPinPreview(
        organizerId: meta['organizerId'] as String? ?? 'org_${m.id}',
        organizerName: meta['organizerName'] as String? ?? 'Организатор',
        organizerUsername: meta['organizerUsername'] as String?,
        organizerFullName: meta['organizerFullName'] as String?,
        organizerCity: meta['organizerCity'] as String? ?? 'Алматы',
        organizerAvatarUrl: meta['organizerAvatarUrl'] as String?,
        title: title,
        description: (meta['description'] as String?)?.trim() ?? '',
        startsAt: startsAt,
        venueLabel: meta['venueLabel'] as String? ?? '',
        address: address,
        durationLabel: durationLabel,
        coverImageUrls: (cover != null && cover.isNotEmpty) ? [cover] : _parseCoverUrls(meta),
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

  static String? _markerAddress(Map<String, dynamic> meta) {
    final a = (meta['address'] as String?)?.trim();
    if (a != null && a.isNotEmpty) return a;
    final lat = meta['lat'];
    final lng = meta['lng'];
    if (lat is num && lng is num) {
      return 'Координаты: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
    return null;
  }

  static String? _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return null;
    final d = end.difference(start);
    if (d.inMinutes <= 0) return null;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0) return '$mм';
    if (m == 0) return '$hч';
    return '$hч $mм';
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

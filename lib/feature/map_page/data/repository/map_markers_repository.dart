import 'package:injectable/injectable.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:side_project/feature/marker_tag/data/repository/marker_tag_repository.dart';

/// Маркеры карты: запросы к [MarkerTagRepository.listMarkersMap] и маппинг в [MapMarker] для [AppMapWidget].
abstract class MapMarkersRepository {
  /// [tagDbKeys] — `marker_tags.key` (как [MarkerTagKey.dbKey]).
  Future<List<MapMarker>> listForMapView({
    required double lat,
    required double lng,
    required double radiusM,
    required DateTime atTime,
    List<String> tagDbKeys = const [],
    int limit = 200,
    int offset = 0,
  });
}

@LazySingleton(as: MapMarkersRepository)
class MapMarkersRepositoryImpl implements MapMarkersRepository {
  MapMarkersRepositoryImpl(this._markerTag);

  final MarkerTagRepository _markerTag;

  @override
  Future<List<MapMarker>> listForMapView({
    required double lat,
    required double lng,
    required double radiusM,
    required DateTime atTime,
    List<String> tagDbKeys = const [],
    int limit = 200,
    int offset = 0,
  }) async {
    final items = await _markerTag.listMarkersMap(
      lat: lat,
      lng: lng,
      radiusM: radiusM,
      atTime: atTime,
      emoji: null,
      tagKeys: tagDbKeys.isEmpty ? null : tagDbKeys,
      limit: limit,
      offset: offset,
    );
    // RPC даёт все «ещё не закончившиеся» к моменту p_at_time, без привязки к календарю.
    // В фильтре выбран конкретный день — оставляем только маркеры с этой же датой начала (локально).
    final onSelectedDay = items.where((m) => _sameLocalCalendarDay(m.eventTime, atTime)).toList();
    return onSelectedDay.map(_toMapMarker).toList();
  }
}

bool _sameLocalCalendarDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

MapMarker _toMapMarker(MarkerMapItemModel m) {
  final e = m.textEmoji?.trim();
  final addressText = m.addressText?.trim();
  final description = m.description?.trim();
  final cover = m.coverImageUrl?.trim();
  final pid = m.postId?.trim();
  final postCount = m.postCount;

  /// На карте только эмодзи в круге (как раньше): без превью постов и без обложки маркера —
  /// иначе тянем картинки и рисуем сетку/полароид. Счётчик постов остаётся в [markerPostCount].
  return MapMarker(
    id: m.id,
    lat: m.lat,
    lng: m.lng,
    emoji: (e != null && e.isNotEmpty) ? e : '📍',
    imageUrl: null,
    imageUrls: const <String>[],
    markerPostCount: postCount,
    pinFootLine: null,
    metadata: {
      // Title comes from Post (heavy layer). Marker stores address only.
      'title': '',
      'address': (addressText != null && addressText.isNotEmpty) ? addressText : null,
      'description': (description != null && description.isNotEmpty) ? description : null,
      'coverImageUrl': (cover != null && cover.isNotEmpty) ? cover : null,
      'postId': (pid != null && pid.isNotEmpty) ? pid : null,
      'postCount': postCount,
      'organizerId': m.ownerId,
      'organizerName': 'Организатор',
      'organizerCity': '',
      'startsAt': m.eventTime.toIso8601String(),
      'endsAt': m.endTime.toIso8601String(),
      'lat': m.lat,
      'lng': m.lng,
      'venueLabel': m.distanceM != null ? 'В радиусе ~ ${(m.distanceM! / 1000).toStringAsFixed(1)} км' : '',
    },
  );
}

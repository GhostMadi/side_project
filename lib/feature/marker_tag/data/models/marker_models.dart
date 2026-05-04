import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/marker_tag/domain/marker_tag_dictionary.dart';

part 'marker_models.freezed.dart';
part 'marker_models.g.dart';

enum MarkerStatus { upcoming, active, finished, cancelled }

@freezed
abstract class MarkerTagModel with _$MarkerTagModel {
  const factory MarkerTagModel({
    required String id,
    required String key,
    @JsonKey(name: 'group_key') String? groupKey,
  }) = _MarkerTagModel;

  factory MarkerTagModel.fromJson(Map<String, dynamic> json) => _$MarkerTagModelFromJson(json);
}

extension MarkerTagModelX on MarkerTagModel {
  MarkerTagKey? get keyEnum => markerTagKeyFromDb(key);

  MarkerTagGroupKey? get groupEnum {
    final k = keyEnum;
    if (k != null) return k.group;
    final g = groupKey;
    if (g == null || g.isEmpty) return null;
    for (final v in MarkerTagGroupKey.values) {
      if (v.dbKey == g) return v;
    }
    return null;
  }

  String get titleRu => keyEnum?.titleRu ?? key;

  String get groupTitleRu =>
      groupEnum?.titleRu ?? (groupKey?.trim().isNotEmpty == true ? groupKey!.trim() : 'Другое');
}

/// Lightweight map marker DTO (from RPC `list_markers_map`).
@freezed
abstract class MarkerMapItemModel with _$MarkerMapItemModel {
  const factory MarkerMapItemModel({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'text_emoji') String? textEmoji,
    @JsonKey(name: 'address_text') String? addressText,
    String? description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    required double lat,
    required double lng,
    @JsonKey(name: 'event_time') required DateTime eventTime,
    @JsonKey(name: 'end_time') required DateTime endTime,

    /// RPC returns string: upcoming|active|finished|cancelled
    required String status,
    @JsonKey(name: 'distance_m') double? distanceM,
    @JsonKey(name: 'post_id') String? postId,

    /// Сколько постов привязано к маркеру (`marker_posts`; 0 — пустой маркер на карте).
    @JsonKey(name: 'post_count') @Default(0) int postCount,

    /// До 4 превью URL первого медиа каждого поста (RPC `preview_image_urls`).
    @JsonKey(name: 'preview_image_urls') @Default(<String>[]) List<String> previewImageUrls,
  }) = _MarkerMapItemModel;

  factory MarkerMapItemModel.fromJson(Map<String, dynamic> json) => _$MarkerMapItemModelFromJson(json);
}

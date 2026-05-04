// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarkerTagModel _$MarkerTagModelFromJson(Map<String, dynamic> json) =>
    _MarkerTagModel(
      id: json['id'] as String,
      key: json['key'] as String,
      groupKey: json['group_key'] as String?,
    );

Map<String, dynamic> _$MarkerTagModelToJson(_MarkerTagModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'group_key': instance.groupKey,
    };

_MarkerMapItemModel _$MarkerMapItemModelFromJson(Map<String, dynamic> json) =>
    _MarkerMapItemModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      textEmoji: json['text_emoji'] as String?,
      addressText: json['address_text'] as String?,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      eventTime: DateTime.parse(json['event_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      postId: json['post_id'] as String?,
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
      previewImageUrls:
          (json['preview_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$MarkerMapItemModelToJson(_MarkerMapItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'text_emoji': instance.textEmoji,
      'address_text': instance.addressText,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'lat': instance.lat,
      'lng': instance.lng,
      'event_time': instance.eventTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': instance.status,
      'distance_m': instance.distanceM,
      'post_id': instance.postId,
      'post_count': instance.postCount,
      'preview_image_urls': instance.previewImageUrls,
    };

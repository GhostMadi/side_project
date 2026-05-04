// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  clusterId: json['cluster_id'] as String?,
  markerId: json['marker_id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  isArchived: json['is_archived'] as bool,
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  likesCount: (json['likes_count'] as num).toInt(),
  dislikesCount: (json['dislikes_count'] as num).toInt(),
  commentsCount: (json['comments_count'] as num).toInt(),
  savesCount: (json['saves_count'] as num).toInt(),
  sendsCount: (json['sends_count'] as num).toInt(),
  viewsCount: (json['views_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  eventTime: json['event_time'] == null
      ? null
      : DateTime.parse(json['event_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  media:
      (json['post_media'] as List<dynamic>?)
          ?.map((e) => PostMediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  marker: json['marker'] == null
      ? null
      : PostLinkedMarker.fromJson(json['marker'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'cluster_id': instance.clusterId,
      'marker_id': instance.markerId,
      'title': instance.title,
      'description': instance.description,
      'is_archived': instance.isArchived,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'likes_count': instance.likesCount,
      'dislikes_count': instance.dislikesCount,
      'comments_count': instance.commentsCount,
      'saves_count': instance.savesCount,
      'sends_count': instance.sendsCount,
      'views_count': instance.viewsCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'event_time': instance.eventTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'post_media': instance.media,
      'marker': instance.marker,
    };

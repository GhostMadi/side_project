// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostMediaModel _$PostMediaModelFromJson(Map<String, dynamic> json) =>
    _PostMediaModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      url: json['url'] as String,
      posterUrl: json['poster_url'] as String?,
      type: PostMediaType.fromJson(json['type']),
      sortOrder: (json['sort_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PostMediaModelToJson(_PostMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'url': instance.url,
      'poster_url': instance.posterUrl,
      'type': _postMediaTypeToJson(instance.type),
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String?,
      creatorId: json['creator_id'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      descriptions:
          (json['descriptions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    AnnouncementDescription.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <AnnouncementDescription>[],
    );

Map<String, dynamic> _$AnnouncementToJson(_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'title': instance.title,
      'type': instance.type,
      'category': instance.category,
      'image_urls': instance.imageUrls,
      'descriptions': instance.descriptions.map((e) => e.toJson()).toList(),
    };

_AnnouncementDescription _$AnnouncementDescriptionFromJson(
  Map<String, dynamic> json,
) => _AnnouncementDescription(
  id: json['id'] as String?,
  announcementId: json['announcement_id'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$AnnouncementDescriptionToJson(
  _AnnouncementDescription instance,
) => <String, dynamic>{
  'id': instance.id,
  'announcement_id': instance.announcementId,
  'description': instance.description,
  'image_url': instance.imageUrl,
};

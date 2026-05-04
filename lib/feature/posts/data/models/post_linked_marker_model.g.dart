// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_linked_marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostLinkedMarker _$PostLinkedMarkerFromJson(Map<String, dynamic> json) =>
    _PostLinkedMarker(
      id: json['id'] as String,
      textEmoji: json['text_emoji'] as String?,
      addressText: json['address_text'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      eventTime: DateTime.parse(json['event_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$PostLinkedMarkerToJson(_PostLinkedMarker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text_emoji': instance.textEmoji,
      'address_text': instance.addressText,
      'is_archived': instance.isArchived,
      'event_time': instance.eventTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': instance.status,
    };

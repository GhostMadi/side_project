// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatConversationModel _$ChatConversationModelFromJson(
  Map<String, dynamic> json,
) => _ChatConversationModel(
  id: json['id'] as String,
  type: json['type'] as String,
  title: json['title'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ChatConversationModelToJson(
  _ChatConversationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'created_at': instance.createdAt?.toIso8601String(),
};

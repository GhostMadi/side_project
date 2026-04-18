// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    _ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      kind: json['kind'] as String,
      text: json['text'] as String?,
      replyToMessageId: json['reply_to_message_id'] as String?,
      forwardedFromMessageId: json['forwarded_from_message_id'] as String?,
      clientMessageId: json['client_message_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] == null
          ? null
          : DateTime.parse(json['edited_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      readByPeer: json['read_by_peer'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatMessageModelToJson(_ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'kind': instance.kind,
      'text': instance.text,
      'reply_to_message_id': instance.replyToMessageId,
      'forwarded_from_message_id': instance.forwardedFromMessageId,
      'client_message_id': instance.clientMessageId,
      'created_at': instance.createdAt.toIso8601String(),
      'edited_at': instance.editedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'read_by_peer': instance.readByPeer,
    };

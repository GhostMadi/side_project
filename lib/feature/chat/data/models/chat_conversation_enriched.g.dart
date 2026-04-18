// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_enriched.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatConversationEnriched _$ChatConversationEnrichedFromJson(
  Map<String, dynamic> json,
) => _ChatConversationEnriched(
  conversation: ChatConversationModel.fromJson(
    json['conversation'] as Map<String, dynamic>,
  ),
  otherUser: json['otherUser'] == null
      ? null
      : ChatProfileMiniModel.fromJson(
          json['otherUser'] as Map<String, dynamic>,
        ),
  lastMessage: json['lastMessage'] == null
      ? null
      : ChatMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChatConversationEnrichedToJson(
  _ChatConversationEnriched instance,
) => <String, dynamic>{
  'conversation': instance.conversation,
  'otherUser': instance.otherUser,
  'lastMessage': instance.lastMessage,
  'unreadCount': instance.unreadCount,
};

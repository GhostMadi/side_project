// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_enriched.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatReactionSummary _$ChatReactionSummaryFromJson(Map<String, dynamic> json) =>
    _ChatReactionSummary(
      emoji: json['emoji'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ChatReactionSummaryToJson(
  _ChatReactionSummary instance,
) => <String, dynamic>{'emoji': instance.emoji, 'count': instance.count};

_ChatReplyPreview _$ChatReplyPreviewFromJson(Map<String, dynamic> json) =>
    _ChatReplyPreview(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String?,
      kind: json['kind'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatReplyPreviewToJson(_ChatReplyPreview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'text': instance.text,
      'kind': instance.kind,
      'created_at': instance.createdAt.toIso8601String(),
    };

_ChatPostRef _$ChatPostRefFromJson(Map<String, dynamic> json) => _ChatPostRef(
  postId: json['post_id'] as String,
  caption: json['caption'] as String?,
);

Map<String, dynamic> _$ChatPostRefToJson(_ChatPostRef instance) =>
    <String, dynamic>{'post_id': instance.postId, 'caption': instance.caption};

_ChatMessageEnriched _$ChatMessageEnrichedFromJson(
  Map<String, dynamic> json,
) => _ChatMessageEnriched(
  message: ChatMessageModel.fromJson(json['message'] as Map<String, dynamic>),
  sender: ChatProfileMiniModel.fromJson(json['sender'] as Map<String, dynamic>),
  replyPreview: json['reply_preview'] == null
      ? null
      : ChatReplyPreview.fromJson(
          json['reply_preview'] as Map<String, dynamic>,
        ),
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => ChatReactionSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChatReactionSummary>[],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map(
            (e) =>
                ChatMessageAttachmentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ChatMessageAttachmentModel>[],
  postRef: json['post_ref'] == null
      ? null
      : ChatPostRef.fromJson(json['post_ref'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageEnrichedToJson(
  _ChatMessageEnriched instance,
) => <String, dynamic>{
  'message': instance.message,
  'sender': instance.sender,
  'reply_preview': instance.replyPreview,
  'reactions': instance.reactions,
  'attachments': instance.attachments,
  'post_ref': instance.postRef,
};

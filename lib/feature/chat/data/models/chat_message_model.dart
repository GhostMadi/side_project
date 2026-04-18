import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
abstract class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String kind, // 'text'|'media'|'file'|'post_ref'|'system'
    String? text,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    @JsonKey(name: 'forwarded_from_message_id') String? forwardedFromMessageId,
    /// UUID с клиента для merge optimistic ↔ server без эвристик (send_message).
    @JsonKey(name: 'client_message_id') String? clientMessageId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'edited_at') DateTime? editedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
}


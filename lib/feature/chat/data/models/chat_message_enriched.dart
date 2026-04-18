import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/chat/data/models/chat_message_attachment_model.dart';
import 'package:side_project/feature/chat/data/models/chat_message_model.dart';
import 'package:side_project/feature/chat/data/models/chat_profile_mini_model.dart';

part 'chat_message_enriched.freezed.dart';
part 'chat_message_enriched.g.dart';

@freezed
abstract class ChatReactionSummary with _$ChatReactionSummary {
  const factory ChatReactionSummary({
    required String emoji,
    required int count,
  }) = _ChatReactionSummary;

  factory ChatReactionSummary.fromJson(Map<String, dynamic> json) => _$ChatReactionSummaryFromJson(json);
}

@freezed
abstract class ChatReplyPreview with _$ChatReplyPreview {
  const factory ChatReplyPreview({
    required String id,
    @JsonKey(name: 'sender_id') required String senderId,
    String? text,
    required String kind,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatReplyPreview;

  factory ChatReplyPreview.fromJson(Map<String, dynamic> json) => _$ChatReplyPreviewFromJson(json);
}

@freezed
abstract class ChatPostRef with _$ChatPostRef {
  const factory ChatPostRef({
    @JsonKey(name: 'post_id') required String postId,
    String? caption,
  }) = _ChatPostRef;

  factory ChatPostRef.fromJson(Map<String, dynamic> json) => _$ChatPostRefFromJson(json);
}

@freezed
abstract class ChatMessageEnriched with _$ChatMessageEnriched {
  const factory ChatMessageEnriched({
    required ChatMessageModel message,
    required ChatProfileMiniModel sender,
    @JsonKey(name: 'reply_preview') ChatReplyPreview? replyPreview,
    @Default(<ChatReactionSummary>[]) List<ChatReactionSummary> reactions,
    @Default(<ChatMessageAttachmentModel>[]) List<ChatMessageAttachmentModel> attachments,
    @JsonKey(name: 'post_ref') ChatPostRef? postRef,
  }) = _ChatMessageEnriched;

  factory ChatMessageEnriched.fromJson(Map<String, dynamic> json) => _$ChatMessageEnrichedFromJson(json);
}


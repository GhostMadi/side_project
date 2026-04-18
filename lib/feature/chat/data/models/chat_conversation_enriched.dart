import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_model.dart';
import 'package:side_project/feature/chat/data/models/chat_message_model.dart';
import 'package:side_project/feature/chat/data/models/chat_profile_mini_model.dart';

part 'chat_conversation_enriched.freezed.dart';
part 'chat_conversation_enriched.g.dart';

@freezed
abstract class ChatConversationEnriched with _$ChatConversationEnriched {
  const factory ChatConversationEnriched({
    required ChatConversationModel conversation,
    ChatProfileMiniModel? otherUser,
    ChatMessageModel? lastMessage,
    @Default(0) int unreadCount,
  }) = _ChatConversationEnriched;

  factory ChatConversationEnriched.fromJson(Map<String, dynamic> json) => _$ChatConversationEnrichedFromJson(json);
}


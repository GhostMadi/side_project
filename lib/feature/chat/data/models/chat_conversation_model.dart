import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation_model.freezed.dart';
part 'chat_conversation_model.g.dart';

@freezed
abstract class ChatConversationModel with _$ChatConversationModel {
  const factory ChatConversationModel({
    required String id,
    required String type, // 'dm'|'group'
    String? title,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ChatConversationModel;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) => _$ChatConversationModelFromJson(json);
}


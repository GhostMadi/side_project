import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_attachment_model.freezed.dart';
part 'chat_message_attachment_model.g.dart';

@freezed
abstract class ChatMessageAttachmentModel with _$ChatMessageAttachmentModel {
  const factory ChatMessageAttachmentModel({
    required String id,
    @JsonKey(name: 'message_id') required String messageId,
    required String bucket,
    required String path,
    String? mime,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    int? width,
    int? height,
    @JsonKey(name: 'duration_ms') int? durationMs,
    @JsonKey(name: 'preview_path') String? previewPath,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ChatMessageAttachmentModel;

  factory ChatMessageAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageAttachmentModelFromJson(json);
}


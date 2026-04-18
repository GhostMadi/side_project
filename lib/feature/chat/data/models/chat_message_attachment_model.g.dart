// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessageAttachmentModel _$ChatMessageAttachmentModelFromJson(
  Map<String, dynamic> json,
) => _ChatMessageAttachmentModel(
  id: json['id'] as String,
  messageId: json['message_id'] as String,
  bucket: json['bucket'] as String,
  path: json['path'] as String,
  mime: json['mime'] as String?,
  sizeBytes: (json['size_bytes'] as num?)?.toInt(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  durationMs: (json['duration_ms'] as num?)?.toInt(),
  previewPath: json['preview_path'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ChatMessageAttachmentModelToJson(
  _ChatMessageAttachmentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'message_id': instance.messageId,
  'bucket': instance.bucket,
  'path': instance.path,
  'mime': instance.mime,
  'size_bytes': instance.sizeBytes,
  'width': instance.width,
  'height': instance.height,
  'duration_ms': instance.durationMs,
  'preview_path': instance.previewPath,
  'created_at': instance.createdAt?.toIso8601String(),
};

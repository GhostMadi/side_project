import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/domain/chat_attachment_rules.dart';

/// Текст цитаты для превью ответа (как в списке сообщений).
String chatReplySnippet(ChatMessageEnriched data) {
  final raw = data.message.text?.trim();
  if (raw != null && raw.isNotEmpty) return raw;

  if (data.message.kind == 'post_ref') {
    final cap = data.postRef?.caption?.trim();
    return cap != null && cap.isNotEmpty ? 'Пост: $cap' : 'Пост';
  }

  if (data.attachments.isNotEmpty) {
    final a = data.attachments.first;
    final mime = ChatAttachmentRules.inferMime(a.path.split('/').last, a.mime);
    if (mime.startsWith('audio/')) return 'Голосовое сообщение';
    if (mime.startsWith('video/')) return 'Видео';
    if (ChatAttachmentRules.isImageMime(mime)) return 'Фото';
    if (mime == 'application/pdf') return 'PDF';
    return 'Файл';
  }

  return 'Сообщение';
}

ChatReplyPreview chatReplyPreviewFromEnriched(ChatMessageEnriched data) {
  return ChatReplyPreview(
    id: data.message.id,
    senderId: data.message.senderId,
    text: chatReplySnippet(data),
    kind: data.message.kind,
    createdAt: data.message.createdAt,
  );
}

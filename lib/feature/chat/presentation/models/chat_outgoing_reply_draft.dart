import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/presentation/models/chat_reply_preview_helpers.dart';

/// Черновик «ответить на сообщение» у композера (до отправки).
class ChatOutgoingReplyDraft {
  const ChatOutgoingReplyDraft({
    required this.messageId,
    required this.preview,
    required this.senderLabel,
  });

  final String messageId;
  final ChatReplyPreview preview;
  final String senderLabel;

  factory ChatOutgoingReplyDraft.fromEnriched(ChatMessageEnriched data, String? myUserId) {
    final mine = myUserId != null && myUserId == data.message.senderId;
    final uname = data.sender.username?.trim();
    final label = mine ? 'Вы' : (uname != null && uname.isNotEmpty ? uname : 'Пользователь');
    return ChatOutgoingReplyDraft(
      messageId: data.message.id,
      preview: chatReplyPreviewFromEnriched(data),
      senderLabel: label,
    );
  }
}

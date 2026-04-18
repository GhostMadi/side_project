import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_delivery.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_outgoing_part.dart';

part 'chat_thread_item.freezed.dart';

@freezed
class ChatThreadItem with _$ChatThreadItem {
  const factory ChatThreadItem.server(ChatMessageEnriched data) = _ChatThreadServer;

  /// Optimistic message: shown immediately as "sent".
  /// Backend confirmation attaches [server] without changing UI position.
  const factory ChatThreadItem.optimisticText({
    required String localId,
    required String conversationId,
    required String text,
    required DateTime createdAt,
    ChatMessageEnriched? server,
    @Default(ChatOptimisticDelivery.sending) ChatOptimisticDelivery delivery,

    /// [send_message(..., p_reply_to)] и превью цитаты в пузырьке до прихода с сервера.
    String? replyToMessageId,
    ChatReplyPreview? quotedPreview,
    String? quotedSenderLabel,
  }) = _ChatThreadOptimisticText;

  /// Фото / видео / файлы / голос — сразу в ленте; байты для превью.[server] после синка с API.
  const factory ChatThreadItem.optimisticAttachments({
    required String localId,
    required String conversationId,
    required DateTime createdAt,
    required List<ChatOptimisticOutgoingPart> parts,
    String? caption,
    ChatMessageEnriched? server,
    @Default(ChatOptimisticDelivery.sending) ChatOptimisticDelivery delivery,
    String? replyToMessageId,
    ChatReplyPreview? quotedPreview,
    String? quotedSenderLabel,
  }) = _ChatThreadOptimisticAttachments;
}

extension ChatThreadItemBubbleKeyX on ChatThreadItem {
  /// Стабильный ключ строки в списке (серверный id или локальный optimistic id).
  String get stableBubbleKey => when(
    server: (data) => data.message.id,
    optimisticText: (localId, conversationId, text, createdAt, server, delivery, _, ___, ____) => localId,
    optimisticAttachments:
        (localId, conversationId, createdAt, parts, caption, server, delivery, _, ___, ____) => localId,
  );
}

extension ChatThreadItemGroupX on ChatThreadItem {
  /// Идентификатор отправителя для группировки подряд идущих пузырьков.
  /// [myUserId] — для optimistic-сообщений считаем отправителем текущего пользователя.
  String? groupSenderKey(String? myUserId) => when(
    server: (data) => data.message.senderId,
    optimisticText: (_, __, ___, ____, _____, ______, _______, __________, ___________) => myUserId,
    optimisticAttachments: (_, __, ___, ____, _____, ______, _______, ________, _________, __________) =>
        myUserId,
  );
}

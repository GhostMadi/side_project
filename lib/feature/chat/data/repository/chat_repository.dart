import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/domain/chat_outgoing_attachment.dart';

abstract class ChatRepository {
  Future<String> createDm(String otherUserId);

  Future<String> createGroup({required String title, required List<String> userIds});

  Future<void> addParticipants({required String conversationId, required List<String> userIds});

  Future<void> removeParticipant({required String conversationId, required String userId});

  Future<List<ChatConversationEnriched>> listConversations({int limit = 30, int offset = 0});

  Future<List<ChatMessageEnriched>> listMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  });

  Future<String> sendText({
    required String conversationId,
    required String text,
    String? replyToMessageId,
    String? forwardFromMessageId,
  });

  Future<String> sendPostRef({
    required String conversationId,
    required String postId,
    String? caption,
    String? replyToMessageId,
  });

  /// Альбом как в Telegram: до 10 вложений, уже загруженные байты проверять на клиенте (размер/MIME).
  Future<String> sendMessageWithAttachments({
    required String conversationId,
    String? caption,
    String? replyToMessageId,
    required List<ChatOutgoingAttachment> parts,
  });

  Future<void> markRead({required String conversationId, String? lastMessageId});

  Future<List<({String conversationId, ChatMessageEnriched message})>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 50,
  });
}


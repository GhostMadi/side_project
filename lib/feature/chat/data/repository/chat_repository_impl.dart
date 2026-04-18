import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/network/supabase_edge_functions_invoker.dart';
import 'package:side_project/feature/chat/domain/chat_outgoing_attachment.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_model.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/data/models/chat_message_model.dart';
import 'package:side_project/feature/chat/data/models/chat_profile_mini_model.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctionsInvoker _edgeFunctions;

  @override
  Future<String> createDm(String otherUserId) async {
    final id = otherUserId.trim();
    final res = await _client.rpc<dynamic>('create_dm', params: {'p_other_user_id': id});
    if (res is String && res.isNotEmpty) return res;
    throw StateError('create_dm: unexpected response ${res.runtimeType}');
  }

  @override
  Future<String> createGroup({required String title, required List<String> userIds}) async {
    final res = await _client.rpc<dynamic>(
      'create_group',
      params: {
        'p_title': title,
        'p_user_ids': userIds,
      },
    );
    if (res is String && res.isNotEmpty) return res;
    throw StateError('create_group: unexpected response ${res.runtimeType}');
  }

  @override
  Future<void> addParticipants({required String conversationId, required List<String> userIds}) async {
    await _client.rpc<void>(
      'add_participants',
      params: {
        'p_conversation_id': conversationId,
        'p_user_ids': userIds,
      },
    );
  }

  @override
  Future<void> removeParticipant({required String conversationId, required String userId}) async {
    await _client.rpc<void>(
      'remove_participant',
      params: {
        'p_conversation_id': conversationId,
        'p_user_id': userId,
      },
    );
  }

  @override
  Future<List<ChatConversationEnriched>> listConversations({int limit = 30, int offset = 0}) async {
    final res = await _client.rpc<dynamic>(
      'list_conversations_enriched',
      params: {
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    if (res is! List) return const [];
    final out = <ChatConversationEnriched>[];
    for (final row in res) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final convId = (m['conversation_id'] as String?)?.trim();
      if (convId == null || convId.isEmpty) continue;
      final conv = ChatConversationModel(
        id: convId,
        type: (m['type'] as String?) ?? 'dm',
        title: m['title'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.tryParse(m['created_at'].toString()),
      );
      final other = m['other_user'];
      final otherUser = (other is Map) ? ChatProfileMiniModel.fromJson(Map<String, dynamic>.from(other)) : null;
      final last = m['last_message'];
      final lastMessage = (last is Map) ? ChatMessageModel.fromJson(Map<String, dynamic>.from(last)) : null;
      final unread = (m['unread_count'] is int) ? (m['unread_count'] as int) : int.tryParse('${m['unread_count']}') ?? 0;
      out.add(ChatConversationEnriched(conversation: conv, otherUser: otherUser, lastMessage: lastMessage, unreadCount: unread));
    }
    return out;
  }

  @override
  Future<List<ChatMessageEnriched>> listMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  }) async {
    final res = await _client.rpc<dynamic>(
      'list_messages_enriched',
      params: {
        'p_conversation_id': conversationId,
        'p_limit': limit,
        'p_before': before?.toIso8601String(),
      },
    );
    if (res is! List) return const [];
    final out = <ChatMessageEnriched>[];
    for (final row in res) {
      if (row is! Map) continue;
      out.add(ChatMessageEnriched.fromJson(Map<String, dynamic>.from(row)));
    }
    return out;
  }

  @override
  Future<ChatMessageEnriched?> getMessageEnriched(String messageId) async {
    final id = messageId.trim();
    if (id.isEmpty) return null;
    try {
      final res = await _client.rpc<dynamic>(
        'get_message_enriched',
        params: {'p_message_id': id},
      );
      Map<String, dynamic>? rowMap;
      if (res is Map) {
        rowMap = Map<String, dynamic>.from(res);
      } else if (res is List && res.isNotEmpty && res.first is Map) {
        rowMap = Map<String, dynamic>.from(res.first as Map);
      }
      if (rowMap == null) return null;
      return ChatMessageEnriched.fromJson(rowMap);
    } catch (_) {
      return null;
    }
  }

  /// Строка из Supabase Realtime `postgres_changes` для `chat_messages`.
  static Map<String, dynamic> _normalizeChatMessageInsert(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    void coerceId(String key) {
      final v = m[key];
      if (v != null) m[key] = v.toString();
    }

    coerceId('id');
    coerceId('conversation_id');
    coerceId('sender_id');
    coerceId('reply_to_message_id');
    coerceId('forwarded_from_message_id');
    coerceId('client_message_id');

    final k = m['kind'];
    if (k != null) {
      final s = k.toString();
      m['kind'] = s.contains('.') ? s.split('.').last : s;
    }

    Object? iso(Object? v) {
      if (v == null) return null;
      if (v is String) return v;
      if (v is DateTime) return v.toUtc().toIso8601String();
      return v.toString();
    }

    m['created_at'] = iso(m['created_at']);
    m['edited_at'] = iso(m['edited_at']);
    m['deleted_at'] = iso(m['deleted_at']);
    return m;
  }

  @override
  ChatMessageEnriched? enrichedFromRealtimeInsertRow(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      if (raw['deleted_at'] != null) return null;
      final message = ChatMessageModel.fromJson(_normalizeChatMessageInsert(raw));
      return ChatMessageEnriched(
        message: message,
        sender: ChatProfileMiniModel(id: message.senderId, username: null, avatarUrl: null),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> sendText({
    required String conversationId,
    required String text,
    String? replyToMessageId,
    String? forwardFromMessageId,
    String? clientMessageId,
  }) async {
    final cm = clientMessageId?.trim();
    final res = await _client.rpc<dynamic>(
      'send_message',
      params: {
        'p_conversation_id': conversationId,
        'p_kind': 'text',
        'p_text': text,
        'p_reply_to': replyToMessageId,
        'p_forward_from': forwardFromMessageId,
        'p_post_id': null,
        if (cm != null && cm.isNotEmpty) 'p_client_message_id': cm,
      },
    );
    if (res is String && res.isNotEmpty) return res;
    throw StateError('send_message(text): unexpected response ${res.runtimeType}');
  }

  @override
  Future<String> sendPostRef({
    required String conversationId,
    required String postId,
    String? caption,
    String? replyToMessageId,
  }) async {
    final res = await _client.rpc<dynamic>(
      'send_message',
      params: {
        'p_conversation_id': conversationId,
        'p_kind': 'post_ref',
        'p_text': caption,
        'p_reply_to': replyToMessageId,
        'p_forward_from': null,
        'p_post_id': postId,
      },
    );
    if (res is String && res.isNotEmpty) return res;
    throw StateError('send_message(post_ref): unexpected response ${res.runtimeType}');
  }

  @override
  Future<String> sendMessageWithAttachments({
    required String conversationId,
    String? caption,
    String? replyToMessageId,
    required List<ChatOutgoingAttachment> parts,
  }) async {
    final uid = _client.auth.currentUser?.id.trim();
    if (uid == null || uid.isEmpty) {
      throw StateError('Нет сессии: войдите в аккаунт');
    }
    final cid = conversationId.trim();
    if (cid.isEmpty) throw ArgumentError('conversationId');
    if (parts.isEmpty) throw ArgumentError('parts');

    final captionTrim = caption?.trim();
    final replyTrim = replyToMessageId?.trim();

    final multipartFiles = <http.MultipartFile>[];
    for (final p in parts) {
      multipartFiles.add(
        http.MultipartFile.fromBytes(
          'files',
          p.bytes,
          filename: _attachmentFilenameForUpload(p.filename),
          contentType: _multipartContentType(p.mimeType),
        ),
      );
    }

    final res = await _edgeFunctions.invoke(
      'send_chat_attachments',
      body: <String, dynamic>{
        'conversation_id': cid,
        if (captionTrim != null && captionTrim.isNotEmpty) 'caption': captionTrim,
        if (replyTrim != null && replyTrim.isNotEmpty) 'reply_to': replyTrim,
      },
      files: multipartFiles,
    );

    final data = res.data;
    if (data is Map) {
      final id = data['message_id'];
      if (id is String && id.isNotEmpty) return id;
    }
    throw StateError('send_chat_attachments: unexpected response ${data.runtimeType}');
  }

  static MediaType _multipartContentType(String mimeType) {
    final raw = mimeType.trim();
    if (raw.isEmpty) return MediaType('application', 'octet-stream');
    try {
      return MediaType.parse(raw);
    } catch (_) {
      return MediaType('application', 'octet-stream');
    }
  }

  static String _attachmentFilenameForUpload(String filename) {
    final n = filename.trim();
    if (n.isEmpty) return 'file';
    final i = n.lastIndexOf('/');
    final j = n.lastIndexOf('\\');
    final k = i >= j ? i : j;
    final leaf = k >= 0 ? n.substring(k + 1) : n;
    return leaf.isEmpty ? 'file' : leaf;
  }

  @override
  Future<void> markRead({required String conversationId, String? lastMessageId}) async {
    await _client.rpc<void>(
      'mark_conversation_read',
      params: {
        'p_conversation_id': conversationId,
        'p_last_message_id': lastMessageId,
      },
    );
  }

  @override
  Future<List<({String conversationId, ChatMessageEnriched message})>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 50,
  }) async {
    final res = await _client.rpc<dynamic>(
      'search_messages',
      params: {
        'p_query': query,
        'p_conversation_id': conversationId,
        'p_limit': limit,
      },
    );
    if (res is! List) return const [];
    final out = <({String conversationId, ChatMessageEnriched message})>[];
    for (final row in res) {
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      final cid = (m['conversation_id'] as String?)?.trim();
      final msg = m['message'];
      final sender = m['sender'];
      if (cid == null || cid.isEmpty || msg is! Map || sender is! Map) continue;
      // adapt to ChatMessageEnriched.fromJson format
      out.add((
        conversationId: cid,
        message: ChatMessageEnriched.fromJson({
          'message': Map<String, dynamic>.from(msg),
          'sender': Map<String, dynamic>.from(sender),
          'reply_preview': null,
          'reactions': const [],
          'attachments': const [],
          'post_ref': null,
        }),
      ));
    }
    return out;
  }
}


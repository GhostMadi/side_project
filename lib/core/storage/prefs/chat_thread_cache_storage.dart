import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';

@lazySingleton
class ChatThreadCacheStorage {
  ChatThreadCacheStorage(this._store);

  final IsarKvStore _store;

  String _key(String userId, String conversationId) => 'chat_thread_v1_${userId}_$conversationId';

  Future<List<ChatMessageEnriched>?> read({
    required String userId,
    required String conversationId,
  }) async {
    final uid = userId.trim();
    final cid = conversationId.trim();
    if (uid.isEmpty || cid.isEmpty) return null;
    final raw = await _store.read(_key(uid, cid));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<Map>().map((e) => ChatMessageEnriched.fromJson(e.cast<String, dynamic>())).toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required String userId,
    required String conversationId,
    required List<ChatMessageEnriched> messages,
  }) async {
    final uid = userId.trim();
    final cid = conversationId.trim();
    if (uid.isEmpty || cid.isEmpty) return;
    await _store.write(
      _key(uid, cid),
      jsonEncode(messages.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<void> clear({
    required String userId,
    required String conversationId,
  }) async {
    final uid = userId.trim();
    final cid = conversationId.trim();
    if (uid.isEmpty || cid.isEmpty) return;
    await _store.delete(_key(uid, cid));
  }
}


import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';

@lazySingleton
class ChatThreadCacheStorage {
  ChatThreadCacheStorage(this._store);

  final IsarKvStore _store;

  String _key(String userId, String conversationId) => 'chat_thread_v1_${userId}_$conversationId';

  /// Свежесть snapshot для списка сообщений: дольше — выше риск «фантомного» UI.
  static const maxAge = Duration(seconds: 6);

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
      if (decoded is Map) {
        final v = decoded['v'];
        if (v == 2) {
          final savedAtRaw = decoded['savedAt'];
          final savedAt = savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw.toString())?.toUtc();
          if (savedAt != null && DateTime.now().toUtc().difference(savedAt) > maxAge) {
            return null;
          }
          final list = decoded['messages'];
          if (list is! List) return null;
          return list.whereType<Map>().map((e) => ChatMessageEnriched.fromJson(e.cast<String, dynamic>())).toList(growable: false);
        }
        return null;
      }
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) => ChatMessageEnriched.fromJson(e.cast<String, dynamic>())).toList(growable: false);
      }
      return null;
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
      jsonEncode(<String, dynamic>{
        'v': 2,
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'messages': messages.map((e) => e.toJson()).toList(growable: false),
      }),
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


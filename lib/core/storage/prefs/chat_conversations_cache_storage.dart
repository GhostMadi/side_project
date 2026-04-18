import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';

@lazySingleton
class ChatConversationsCacheStorage {
  ChatConversationsCacheStorage(this._store);

  final IsarKvStore _store;

  String _key(String userId) => 'chat_conv_list_v1_$userId';

  Future<List<ChatConversationEnriched>?> read(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) return null;
    final raw = await _store.read(_key(uid));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => ChatConversationEnriched.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String userId, List<ChatConversationEnriched> items) async {
    final uid = userId.trim();
    if (uid.isEmpty) return;
    await _store.write(
      _key(uid),
      jsonEncode(items.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<void> clear(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) return;
    await _store.delete(_key(uid));
  }
}


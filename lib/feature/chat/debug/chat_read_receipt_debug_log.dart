import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Диагностика галочек «прочитано»: Realtime `chat_participants`, при [load] — REST-курсоры, локальный патч.
///
/// В релизе по умолчанию выключено. Чтобы отключить шум в debug: [enabled] = false.
/// В DevTools / консоли фильтр по имени: `ChatRead`.
/// Ещё подробнее (хвост, cmp с курсором): [verbose].
abstract final class ChatReadReceiptDebugLog {
  static bool enabled = kDebugMode;

  /// Доп. строки про newestMine vs peer cursor и send-tail (шумнее).
  static bool verbose = true;

  static void d(String message) {
    if (!enabled) return;
    developer.log(message, name: 'ChatRead');
  }

  static void e(String message, [Object? error, StackTrace? st]) {
    if (!enabled) return;
    if (error != null) {
      developer.log(message, name: 'ChatRead', error: error, stackTrace: st, level: 1000);
    } else {
      developer.log(message, name: 'ChatRead', level: 1000);
    }
  }

  /// Все Postgres Realtime-события по `chat_participants` до фильтрации по диалогу (фильтр `ChatRead`).
  static void wsParticipantsRaw(PostgresChangePayload p, {required String expectedCid}) {
    if (!enabled) return;
    String? pick(Map<String, dynamic> m, String snake) {
      final s = snake.toLowerCase();
      for (final e in m.entries) {
        if (e.key.toString().toLowerCase() == s) return e.value?.toString();
      }
      return null;
    }

    final ok = p.oldRecord.keys.map((k) => k.toString()).join(',');
    final nk = p.newRecord.keys.map((k) => k.toString()).join(',');
    final convOld = pick(p.oldRecord, 'conversation_id');
    final convNew = pick(p.newRecord, 'conversation_id');
    final lrOld = pick(p.oldRecord, 'last_read_message_id');
    final lrNew = pick(p.newRecord, 'last_read_message_id');
    final uidOld = pick(p.oldRecord, 'user_id');
    final uidNew = pick(p.newRecord, 'user_id');

    d(
      'ws.participants RAW evt=${p.eventType.name} expected=$expectedCid '
      'oldKeys=[$ok] newKeys=[$nk] conv_old=$convOld conv_new=$convNew '
      'uid_old=$uidOld uid_new=$uidNew lr_old=$lrOld lr_new=$lrNew',
    );
  }
}

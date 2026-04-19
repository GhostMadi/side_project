import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Диагностика галочек «прочитано»: Realtime `chat_participants`, при [load] — REST-курсоры, локальный патч.
///
/// В релизе по умолчанию выключено. Чтобы отключить шум в debug: [enabled] = false.
/// В DevTools / консоли фильтр по имени: `ChatRead`.
abstract final class ChatReadReceiptDebugLog {
  static bool enabled = kDebugMode;

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
}

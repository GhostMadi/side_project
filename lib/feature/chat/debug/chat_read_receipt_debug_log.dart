import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Диагностика галочек «прочитано»: Realtime `chat_participants`, при [load] — REST-курсоры, локальный патч.
///
/// В релизе по умолчанию выключено. Чтобы отключить шум в debug: [enabled] = false.
abstract final class ChatReadReceiptDebugLog {
  static bool enabled = kDebugMode;

  static void d(String message) {
    if (!enabled) return;
    developer.log(message, name: 'ChatRead');
  }
}

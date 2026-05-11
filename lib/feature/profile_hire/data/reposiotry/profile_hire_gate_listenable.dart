import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Уведомление подписчиков (настройки и др.), что локальный кэш profile_hires обновился.
@lazySingleton
class ProfileHireGateListenable extends ChangeNotifier {
  void notifyGateChanged() => notifyListeners();
}

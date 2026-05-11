import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Уведомление подписчиков (настройки и др.), что локальный кэш business_profiles обновился.
@lazySingleton
class BusinessProfileGateListenable extends ChangeNotifier {
  void notifyGateChanged() => notifyListeners();
}

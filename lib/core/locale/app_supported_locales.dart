import 'package:flutter/material.dart';

/// Языки, для которых есть ARB и переводы в `lib/l10n/`.
abstract final class AppSupportedLocales {
  static const List<Locale> locales = [Locale('en'), Locale('ru')];

  static List<Locale> get supportedLocales => locales;

  static bool contains(Locale locale) {
    return locales.any((l) => l.languageCode == locale.languageCode);
  }

  /// Совпадение с языком устройства или запасной вариант.
  static Locale matchDeviceOrFallback(Locale? device) {
    if (device != null) {
      final lang = device.languageCode.toLowerCase();
      for (final l in locales) {
        if (l.languageCode == lang) return l;
      }
    }
    return const Locale('ru');
  }
}

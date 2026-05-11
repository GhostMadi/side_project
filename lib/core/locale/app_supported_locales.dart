import 'package:flutter/material.dart';

/// Языки, для которых есть ARB и переводы в `lib/l10n/`.
abstract final class AppSupportedLocales {
  static const List<Locale> locales = [Locale('en'), Locale('ru')];

  static Locale normalize(Locale locale) => Locale(locale.languageCode.toLowerCase());

  static List<Locale> get supportedLocales => locales;

  static bool contains(Locale locale) {
    final normalized = normalize(locale);
    return locales.any((l) => l.languageCode == normalized.languageCode);
  }

  /// Совпадение с языком устройства или запасной вариант.
  static Locale matchDeviceOrFallback(Locale? device) {
    if (device != null) {
      final lang = normalize(device).languageCode;
      for (final l in locales) {
        if (l.languageCode == lang) return l;
      }
    }
    return const Locale('ru');
  }
}

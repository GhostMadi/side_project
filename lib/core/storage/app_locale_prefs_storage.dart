import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_project/core/storage/base_storage.dart';

/// Код языка UI (`ru`, `en`) в SharedPreferences через [BaseStorage].
@lazySingleton
class AppLocalePrefsStorage {
  AppLocalePrefsStorage(SharedPreferences prefs)
      : _code = BaseStorage<String>(prefs, key: _key);

  static const _key = 'app_locale_code';
  final BaseStorage<String> _code;

  String? readCode() => _code.read();

  Future<void> writeCode(String languageCode) =>
      _code.save(languageCode.trim().toLowerCase());

  /// Код вида `ru`, `en` или `en_US`.
  static Locale? localeFromCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    final parts = code.trim().split(RegExp(r'[-_]'));
    if (parts.length >= 2) {
      return Locale(parts[0].toLowerCase(), parts[1].toUpperCase());
    }
    return Locale(parts[0].toLowerCase());
  }
}

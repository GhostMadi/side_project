import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/base_storage.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

/// Код языка UI (`ru`, `en`) в Isar KV через [BaseStorage].
@lazySingleton
class AppLocalePrefsStorage {
  AppLocalePrefsStorage(IsarKvStore store)
    : _code = BaseStorage<String>(key: _key, read: store.read, write: store.write, delete: store.delete);

  static const _key = 'app_locale_code';
  final BaseStorage<String> _code;

  Future<String?> readCode() => _code.read();

  Future<void> writeCode(String languageCode) => _code.save(languageCode.trim().toLowerCase());

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

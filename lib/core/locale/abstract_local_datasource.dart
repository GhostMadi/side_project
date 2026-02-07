import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Родительский класс для всех локальных источников данных.
/// Он берет на себя грязную работу с JSON-строками.
abstract class AbstractLocalDataSource {
  final SharedPreferences prefs;

  AbstractLocalDataSource(this.prefs);

  /// Эти ключи наследник обязан определить
  String get versionKey; // Например 'categories_version'
  String get dataKey; // Например 'categories_data'

  // --- Логика Версии ---
  String getVersion() {
    return prefs.getString(versionKey) ?? '0';
  }

  Future<void> setVersion(String version) async {
    await prefs.setString(versionKey, version);
  }

  // --- Логика Данных (Сохраняем как JSON List) ---

  /// Сохраняет список Map (JSON) в виде списка строк
  Future<void> saveJsonList(List<Map<String, dynamic>> jsonList) async {
    final List<String> stringList = jsonList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(dataKey, stringList);
  }

  /// Достает список Map (JSON)
  List<Map<String, dynamic>> getJsonList() {
    final List<String> stringList = prefs.getStringList(dataKey) ?? [];
    return stringList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  /// Полная очистка (если нужно сбросить кэш)
  Future<void> clear() async {
    await prefs.remove(versionKey);
    await prefs.remove(dataKey);
  }
}

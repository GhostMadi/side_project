import 'package:shared_preferences/shared_preferences.dart';

class BaseStorage<T> {
  final SharedPreferences prefs;
  final String key;

  BaseStorage(this.prefs, {required this.key});

  // Сохранение данных
  Future<bool> save(T value) async {
    if (value is String) return await prefs.setString(key, value);
    if (value is int) return await prefs.setInt(key, value);
    if (value is bool) return await prefs.setBool(key, value);
    if (value is double) return await prefs.setDouble(key, value);
    if (value is List<String>) return await prefs.setStringList(key, value);
    throw Exception("Type ${value.runtimeType} is not supported by SharedPreferences");
  }

  // Чтение данных (не называть метод `get` — конфликт с синтаксисом getter в Dart).
  T? read() {
    return prefs.get(key) as T?;
  }

  // Удаление конкретного ключа
  Future<bool> delete() async {
    return await prefs.remove(key);
  }

  // Проверка на наличие
  bool get exists => prefs.containsKey(key);
}

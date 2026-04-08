import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IStorage<T> {
  Future<void> save(T value);
  Future<T?> get();
  Future<void> delete();
  Future<bool> containsKey();
}

class BaseSecureStorage<T> implements IStorage<T> {
  final FlutterSecureStorage storage;
  final String key;

  // Добавляем опциональный колбэк для парсинга сложных объектов
  final T Function(Map<String, dynamic> json)? fromJson;

  BaseSecureStorage(
    this.storage, {
    required this.key,
    this.fromJson,
  });

  @override
  Future<void> save(T value) async {
    String stringValue;

    // Обрабатываем базовые типы и сложные объекты
    if (value is String) {
      stringValue = value;
    } else if (value is bool || value is int || value is double) {
      stringValue = value.toString();
    } else {
      // Для LoginModel и других классов
      stringValue = json.encode(value);
    }

    await storage.write(key: key, value: stringValue);
  }

  @override
  Future<T?> get() async {
    final String? value = await storage.read(key: key);
    if (value == null) return null;

    try {
      // 1. Если ожидаем строку
      if (T == String) return value as T;

      // 2. Если ожидаем bool (хранится как "true"/"false")
      if (T == bool) return (value == 'true') as T;

      // 3. Если ожидаем число
      if (T == int) return int.tryParse(value) as T?;
      if (T == double) return double.tryParse(value) as T?;

      // 4. Парсим JSON для сложных объектов (LoginModel)
      final decoded = json.decode(value);

      if (fromJson != null && decoded is Map<String, dynamic>) {
        return fromJson!(decoded);
      }

      return decoded as T?;
    } catch (e) {
      // Можно добавить логирование ошибки парсинга
      return null;
    }
  }

  @override
  Future<void> delete() async => await storage.delete(key: key);

  @override
  Future<bool> containsKey() async => await storage.containsKey(key: key);
}

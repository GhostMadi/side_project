class BaseStorage<T> {
  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key, String? value) _write;
  final Future<void> Function(String key) _delete;
  final String key;

  BaseStorage({
    required this.key,
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String? value) write,
    required Future<void> Function(String key) delete,
  })  : _read = read,
        _write = write,
        _delete = delete;

  // Сохранение данных
  Future<void> save(T value) async {
    if (value is String) return _write(key, value);
    if (value is int) return _write(key, value.toString());
    if (value is bool) return _write(key, value.toString());
    if (value is double) return _write(key, value.toString());
    if (value is List<String>) return _write(key, value.join('\u0001'));
    throw Exception("Type ${value.runtimeType} is not supported by BaseStorage");
  }

  // Чтение данных (не называть метод `get` — конфликт с синтаксисом getter в Dart).
  Future<T?> read() async {
    final raw = await _read(key);
    if (raw == null) return null;
    if (T == String) return raw as T;
    if (T == int) return int.tryParse(raw) as T?;
    if (T == bool) return (raw == 'true') as T;
    if (T == double) return double.tryParse(raw) as T?;
    if (T == List<String>) return raw.split('\u0001') as T;
    throw Exception("Type $T is not supported by BaseStorage.read()");
  }

  // Удаление конкретного ключа
  Future<void> delete() async {
    await _delete(key);
  }
}

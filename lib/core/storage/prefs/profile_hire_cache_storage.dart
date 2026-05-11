import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

/// Снимок настроек найма из таблицы [profiles] в KV.
class ProfileHireStoredGate {
  const ProfileHireStoredGate({required this.hiringEnabled, required this.openForMemberships});

  final bool hiringEnabled;
  final bool openForMemberships;
}

/// Данные для UI настроек найма без прямого сетевого запроса.
class ProfileHireGatePeek {
  const ProfileHireGatePeek._({required this.cacheKnown, this.stored});

  /// Данных в кэше еще нет (нужна гидрация).
  factory ProfileHireGatePeek.unknown() => const ProfileHireGatePeek._(cacheKnown: false);

  /// Данные успешно считаны из кэша.
  factory ProfileHireGatePeek.known(ProfileHireStoredGate stored) =>
      ProfileHireGatePeek._(cacheKnown: true, stored: stored);

  final bool cacheKnown;
  final ProfileHireStoredGate? stored;
}

/// Локальное хранилище (Isar KV) для флагов найма пользователя.
@lazySingleton
class ProfileHireCacheStorage {
  ProfileHireCacheStorage(this._store);

  final IsarKvStore _store;

  static const _v = 1;

  /// Ключ включает версию, чтобы при изменении структуры данных не было крэшей.
  String _key(String userId) => 'profile_hire_cache_v${_v}_$userId';

  /// Чтение состояния из локального кэша.
  Future<ProfileHireGatePeek> readPeek(String userId) async {
    if (userId.trim().isEmpty) return ProfileHireGatePeek.unknown();

    final raw = await _store.read(_key(userId));
    if (raw == null || raw.trim().isEmpty) return ProfileHireGatePeek.unknown();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return ProfileHireGatePeek.unknown();

      final m = decoded.cast<String, dynamic>();
      return ProfileHireGatePeek.known(
        ProfileHireStoredGate(
          hiringEnabled: m['hiring_enabled'] == true,
          openForMemberships: m['open_for_memberships'] == true,
        ),
      );
    } catch (_) {
      return ProfileHireGatePeek.unknown();
    }
  }

  /// Запись актуальных флагов в кэш.
  Future<void> write(String userId, {required bool hiringEnabled, required bool openForMemberships}) async {
    if (userId.trim().isEmpty) return;

    await _store.write(
      _key(userId),
      jsonEncode({'v': _v, 'hiring_enabled': hiringEnabled, 'open_for_memberships': openForMemberships}),
    );
  }

  /// Очистка кэша (например, при логауте).
  Future<void> clear(String userId) async {
    if (userId.trim().isEmpty) return;
    await _store.delete(_key(userId));
  }
}

import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/kv/isar_kv_store.dart';

/// Снимок [business_profiles] в KV по user_id (`null` в ответе = строки на бэке нет).
class BusinessStoredProfileGate {
  const BusinessStoredProfileGate({required this.hasProfile, required this.categoryId, required this.statusJson});

  final bool hasProfile;
  final int categoryId;
  final String statusJson;
}

/// Данные для UI «ворот» без сетевого запроса.
class BusinessProfileGatePeek {
  const BusinessProfileGatePeek._({required this.cacheKnown, required this.stored});

  /// Ключа в KV ещё не было → UI может показывать шиммер до гидрации.
  factory BusinessProfileGatePeek.unknown() => const BusinessProfileGatePeek._(cacheKnown: false, stored: null);

  factory BusinessProfileGatePeek.known(BusinessStoredProfileGate stored) =>
      BusinessProfileGatePeek._(cacheKnown: true, stored: stored);

  /// Есть сохранённые данные после гидрации.
  final bool cacheKnown;

  final BusinessStoredProfileGate? stored;
}

/// Кэш `business_profiles` по пользователю (Isar KV).
@lazySingleton
class BusinessProfileCacheStorage {
  BusinessProfileCacheStorage(this._store);

  final IsarKvStore _store;

  static const _v = 1;

  String _key(String userId) => 'business_profile_cache_v${_v}_$userId';

  Future<BusinessProfileGatePeek> readPeek(String userId) async {
    if (userId.trim().isEmpty) return BusinessProfileGatePeek.unknown();
    final raw = await _store.read(_key(userId));
    if (raw == null || raw.trim().isEmpty) return BusinessProfileGatePeek.unknown();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return BusinessProfileGatePeek.unknown();
      final m = decoded.cast<String, dynamic>();
      final has = m['has_profile'] == true;
      final cid = (m['category_id'] as num?)?.toInt() ?? 0;
      final st = (m['status'] as String?)?.trim() ?? 'deactive';
      return BusinessProfileGatePeek.known(
        BusinessStoredProfileGate(hasProfile: has, categoryId: cid, statusJson: st),
      );
    } catch (_) {
      return BusinessProfileGatePeek.unknown();
    }
  }

  Future<void> writeAbsent(String userId) async {
    if (userId.trim().isEmpty) return;
    await _store.write(
      _key(userId),
      jsonEncode({'v': _v, 'has_profile': false}),
    );
  }

  Future<void> writePresent(String userId, {required int categoryId, required String status}) async {
    if (userId.trim().isEmpty) return;
    await _store.write(
      _key(userId),
      jsonEncode({
        'v': _v,
        'has_profile': true,
        'category_id': categoryId,
        'status': status,
      }),
    );
  }

  Future<void> clear(String userId) async {
    if (userId.trim().isEmpty) return;
    await _store.delete(_key(userId));
  }
}

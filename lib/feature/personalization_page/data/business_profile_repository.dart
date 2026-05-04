import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/business_profile_cache_storage.dart';
import 'package:side_project/feature/personalization_page/data/business_profile_gate_listenable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum BusinessProfileStatus {
  active,
  deactive,
}

BusinessProfileStatus businessProfileStatusFromDb(String raw) {
  if (raw == 'active') return BusinessProfileStatus.active;
  return BusinessProfileStatus.deactive;
}

String businessProfileStatusToDb(BusinessProfileStatus status) {
  switch (status) {
    case BusinessProfileStatus.active:
      return 'active';
    case BusinessProfileStatus.deactive:
      return 'deactive';
  }
}

/// Строка [business_profiles] для текущего пользователя (RLS — только свой user_id).
class BusinessProfileMine {
  const BusinessProfileMine({required this.userId, required this.categoryId, required this.status});

  final String userId;
  final int categoryId;
  final BusinessProfileStatus status;

  bool get isActive => status == BusinessProfileStatus.active;
}

/// По кэшу: есть строка business_profiles и статус `active` (секция настроек + свитч).
bool businessProfileIsActiveFromPeek(BusinessProfileGatePeek peek) {
  if (!peek.cacheKnown || peek.stored == null) return false;
  final s = peek.stored!;
  if (!s.hasProfile) return false;
  return businessProfileStatusFromDb(s.statusJson) == BusinessProfileStatus.active;
}


abstract class BusinessProfileRepository {
  /// Только локальный KV: `cacheKnown == false` — ключей не было (ждём гидрацию или pull-to-refresh).
  Future<BusinessProfileGatePeek> peekGate();

  /// Сеть + запись кэша + оповещение подписчиков.
  Future<BusinessProfileMine?> refreshRemoteAndCache();

  Future<void> upsertMyStatus(BusinessProfileStatus status);

  /// Однократная гидрация при старте приложения; ошибки не пробрасываются.
  Future<void> warmCacheFromRemoteBestEffort();
}

@LazySingleton(as: BusinessProfileRepository)
class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  BusinessProfileRepositoryImpl(this._client, this._cache, this._gate);

  final SupabaseClient _client;
  final BusinessProfileCacheStorage _cache;
  final BusinessProfileGateListenable _gate;

  String? _currentUidOrNull() {
    final uid = _client.auth.currentUser?.id.trim();
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  String _requireUid() {
    final uid = _currentUidOrNull();
    if (uid == null) throw StateError('not_authenticated');
    return uid;
  }

  @override
  Future<BusinessProfileGatePeek> peekGate() async {
    final uid = _currentUidOrNull();
    if (uid == null) return BusinessProfileGatePeek.unknown();
    return _cache.readPeek(uid);
  }

  Future<BusinessProfileMine?> _fetchRemoteMineForUid(String uid) async {
    final row = await _client.from('business_profiles').select().eq('user_id', uid).maybeSingle();
    if (row == null) return null;

    final id = row['category_id'];
    final st = row['status']?.toString() ?? 'deactive';
    final categoryId = id is int ? id : int.tryParse('$id') ?? 0;
    return BusinessProfileMine(
      userId: uid,
      categoryId: categoryId,
      status: businessProfileStatusFromDb(st),
    );
  }

  Future<BusinessProfileMine?> _fetchRemoteMine() => _fetchRemoteMineForUid(_requireUid());

  Future<void> _persistMine(String uid, BusinessProfileMine? mine) async {
    if (mine == null) {
      await _cache.writeAbsent(uid);
    } else {
      await _cache.writePresent(
        uid,
        categoryId: mine.categoryId,
        status: businessProfileStatusToDb(mine.status),
      );
    }
    _gate.notifyGateChanged();
  }

  @override
  Future<BusinessProfileMine?> refreshRemoteAndCache() async {
    final uid = _requireUid();
    final mine = await _fetchRemoteMine();
    await _persistMine(uid, mine);
    return mine;
  }

  @override
  Future<void> warmCacheFromRemoteBestEffort() async {
    final uid = _currentUidOrNull();
    if (uid == null) return;
    try {
      final mine = await _fetchRemoteMineForUid(uid);
      await _persistMine(uid, mine);
    } catch (_) {
      /// Оставляем KV как есть или пустым — без падения холодного старта.
    }
  }

  @override
  Future<void> upsertMyStatus(BusinessProfileStatus status) async {
    final uid = _requireUid();
    await _client.from('business_profiles').upsert(<String, dynamic>{
      'user_id': uid,
      'status': businessProfileStatusToDb(status),
    }, onConflict: 'user_id');
    await refreshRemoteAndCache();
  }
}

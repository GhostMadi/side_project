import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/profile_hire_cache_storage.dart';
import 'package:side_project/feature/business_profile/data/business_profile_gate_listenable.dart'; // Используем тот же Gate для синхронизации UI
import 'package:side_project/feature/profile_hire/data/reposiotry/profile_hire_gate_listenable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Данные из таблицы [profiles], отвечающие за найм и команды.
class ProfileHireMine {
  const ProfileHireMine({required this.hiringEnabled, required this.openForMemberships});

  final bool hiringEnabled;
  final bool openForMemberships;
}

abstract class ProfileHireRepository {
  /// Получение данных из локального Isar KV.
  Future<ProfileHireGatePeek> peekGate();

  /// Обновление флагов из Supabase (таблица profiles) и запись в кэш.
  Future<ProfileHireMine> refreshRemoteAndCache();

  /// Изменение статуса найма (hiring_enabled).
  Future<void> updateHiringStatus(bool enabled);

  /// Изменение статуса вступления в команду (open_for_memberships).
  Future<void> updateMembershipsStatus(bool enabled);

  /// Холодный старт: подгрузка данных без прерывания работы приложения.
  Future<void> warmCacheFromRemoteBestEffort();
}

@LazySingleton(as: ProfileHireRepository)
class ProfileHireRepositoryImpl implements ProfileHireRepository {
  ProfileHireRepositoryImpl(this._client, this._cache, this._gate, this._profileHireGateListen);

  final SupabaseClient _client;
  final ProfileHireCacheStorage _cache;
  final BusinessProfileGateListenable _gate; // Тот же листенер, чтобы шторка настроек знала об изменениях
  final ProfileHireGateListenable _profileHireGateListen; // Новый листенер для синхронизации UI настроек найма
  

  String? _currentUidOrNull() {
    final uid = _client.auth.currentUser?.id.trim();
    return (uid == null || uid.isEmpty) ? null : uid;
  }

  String _requireUid() {
    final uid = _currentUidOrNull();
    if (uid == null) throw StateError('not_authenticated');
    return uid;
  }

  @override
  Future<ProfileHireGatePeek> peekGate() async {
    final uid = _currentUidOrNull();
    if (uid == null) return ProfileHireGatePeek.unknown();
    return _cache.readPeek(uid);
  }

  /// Запрос напрямую в таблицу profiles.
  Future<ProfileHireMine> _fetchRemoteMineForUid(String uid) async {
    final row = await _client
        .from('profiles')
        .select('hiring_enabled, open_for_memberships')
        .eq('id', uid)
        .single();

    return ProfileHireMine(
      hiringEnabled: row['hiring_enabled'] == true,
      openForMemberships: row['open_for_memberships'] == true,
    );
  }

  Future<void> _persistMine(String uid, ProfileHireMine mine) async {
    await _cache.write(uid, hiringEnabled: mine.hiringEnabled, openForMemberships: mine.openForMemberships);
    _gate.notifyGateChanged(); // Уведомляем UI (например, Cubit-ы), что данные в кэше изменились
    _profileHireGateListen.notifyGateChanged(); // Уведомляем UI настроек найма, что данные изменились
  }

  @override
  Future<ProfileHireMine> refreshRemoteAndCache() async {
    final uid = _requireUid();
    final mine = await _fetchRemoteMineForUid(uid);
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
    } catch (_) {}
  }

  @override
  Future<void> updateHiringStatus(bool enabled) async {
    final uid = _requireUid();
    final peek = await peekGate();
    final ProfileHireMine baseline;
    if (peek.cacheKnown && peek.stored != null) {
      baseline = ProfileHireMine(
        hiringEnabled: peek.stored!.hiringEnabled,
        openForMemberships: peek.stored!.openForMemberships,
      );
    } else {
      baseline = await _fetchRemoteMineForUid(uid);
    }

    await _persistMine(
      uid,
      ProfileHireMine(hiringEnabled: enabled, openForMemberships: baseline.openForMemberships),
    );
    try {
      await _client.from('profiles').update({'hiring_enabled': enabled}).eq('id', uid);
      final mine = await _fetchRemoteMineForUid(uid);
      await _persistMine(uid, mine);
    } catch (_) {
      await _persistMine(uid, baseline);
      rethrow;
    }
  }

  @override
  Future<void> updateMembershipsStatus(bool enabled) async {
    final uid = _requireUid();
    final peek = await peekGate();
    final ProfileHireMine baseline;
    if (peek.cacheKnown && peek.stored != null) {
      baseline = ProfileHireMine(
        hiringEnabled: peek.stored!.hiringEnabled,
        openForMemberships: peek.stored!.openForMemberships,
      );
    } else {
      baseline = await _fetchRemoteMineForUid(uid);
    }

    await _persistMine(
      uid,
      ProfileHireMine(hiringEnabled: baseline.hiringEnabled, openForMemberships: enabled),
    );
    try {
      await _client.from('profiles').update({'open_for_memberships': enabled}).eq('id', uid);
      final mine = await _fetchRemoteMineForUid(uid);
      await _persistMine(uid, mine);
    } catch (_) {
      await _persistMine(uid, baseline);
      rethrow;
    }
  }
}

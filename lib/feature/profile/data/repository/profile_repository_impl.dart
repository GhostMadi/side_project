import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';
import 'package:side_project/feature/profile/data/profile_image_compress.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileModel?> getById(String id) async {
    final data = await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<ProfileModel?> getCurrentUserProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    return getById(uid);
  }

  @override
  Future<ProfileModel?> updateCurrentUserProfile({
    required String fullName,
    required String username,
    required String bio,
    required String categoryCode,
    required String cityCode,
    required String countryCode,
    required String phone,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    String? norm(String v) {
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    /// Как в `public.countries.code` — нижний регистр (`kz`, `ru`).
    String? normCountry(String v) {
      final t = v.trim();
      if (t.isEmpty) return null;
      return t.toLowerCase();
    }

    /// Как в `public.cities.city_code` — регистр как в справочнике (`saintPetersburg` и т.д.).
    String? normCity(String v) {
      final t = v.trim();
      if (t.isEmpty) return null;
      return t;
    }

    final row = <String, dynamic>{
      'full_name': norm(fullName),
      'username': norm(username),
      'bio': norm(bio),
      'category_code': norm(categoryCode),
      'city_code': normCity(cityCode),
      'country_code': normCountry(countryCode),
      'phone': norm(phone),
    };

    try {
      final data = await _client.from('profiles').update(row).eq('id', uid).select().maybeSingle();
      if (data == null) {
        developer.log('updateCurrentUserProfile: empty response, refetch', name: 'ProfileRepository');
        return getById(uid);
      }
      developer.log('updateCurrentUserProfile: ok', name: 'ProfileRepository');
      return ProfileModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e, st) {
      developer.log(
        'PostgREST: code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
        name: 'ProfileRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      developer.log('updateCurrentUserProfile: $e', name: 'ProfileRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  static const _bucketAvatar = 'avatars';
  static const _bucketBackground = 'profile_backgrounds';

  String _publicUrlWithVersion({
    required String bucket,
    required String path,
  }) {
    final base = _client.storage.from(bucket).getPublicUrl(path);
    final v = DateTime.now().millisecondsSinceEpoch;
    return '$base?v=$v';
  }

  @override
  Future<ProfileModel?> uploadAvatarImage(Uint8List imageBytes) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final compressed = await compressProfileImageToMaxBytes(imageBytes);
    final path = '$uid/avatar.jpg';
    await _client.storage
        .from(_bucketAvatar)
        .uploadBinary(
          path,
          compressed,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    final publicUrl = _publicUrlWithVersion(bucket: _bucketAvatar, path: path);
    return _patchProfileUrls(avatarUrl: publicUrl);
  }

  @override
  Future<ProfileModel?> uploadBackgroundImage(Uint8List imageBytes) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final compressed = await compressProfileImageToMaxBytes(imageBytes);
    final path = '$uid/background.jpg';
    await _client.storage
        .from(_bucketBackground)
        .uploadBinary(
          path,
          compressed,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    final publicUrl = _publicUrlWithVersion(bucket: _bucketBackground, path: path);
    return _patchProfileUrls(backgroundUrl: publicUrl);
  }

  @override
  Future<ProfileModel?> deleteAvatarImage() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final path = '$uid/avatar.jpg';
    try {
      await _client.storage.from(_bucketAvatar).remove([path]);
    } catch (e, st) {
      developer.log('deleteAvatarImage storage: $e', name: 'ProfileRepository', error: e, stackTrace: st);
    }
    return _clearUrls(clearAvatar: true);
  }

  @override
  Future<ProfileModel?> deleteBackgroundImage() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final path = '$uid/background.jpg';
    try {
      await _client.storage.from(_bucketBackground).remove([path]);
    } catch (e, st) {
      developer.log('deleteBackgroundImage storage: $e', name: 'ProfileRepository', error: e, stackTrace: st);
    }
    return _clearUrls(clearBackground: true);
  }

  Future<ProfileModel?> _clearUrls({bool clearAvatar = false, bool clearBackground = false}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = <String, dynamic>{};
    if (clearAvatar) row['avatar_url'] = null;
    if (clearBackground) row['background_url'] = null;
    if (row.isEmpty) return getById(uid);
    try {
      final data = await _client.from('profiles').update(row).eq('id', uid).select().maybeSingle();
      if (data == null) return getById(uid);
      return ProfileModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e, st) {
      developer.log('clearUrls: $e', name: 'ProfileRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<ProfileModel?> _patchProfileUrls({String? avatarUrl, String? backgroundUrl}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = <String, dynamic>{};
    if (avatarUrl != null) row['avatar_url'] = avatarUrl;
    if (backgroundUrl != null) row['background_url'] = backgroundUrl;
    if (row.isEmpty) return getById(uid);
    try {
      final data = await _client.from('profiles').update(row).eq('id', uid).select().maybeSingle();
      if (data == null) return getById(uid);
      return ProfileModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e, st) {
      developer.log('patchProfileUrls: $e', name: 'ProfileRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  static String _sanitizeSearchQuery(String query) {
    final t = query.trim();
    if (t.isEmpty) return '';
    return t.replaceAll(RegExp(r'[%_,]'), '');
  }

  static List<Map<String, dynamic>> _rows(dynamic response) {
    if (response == null) return [];
    final list = response as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<List<ProfileSearchHit>> searchProfilesForTagging({
    required String query,
    int limit = 24,
  }) async {
    final safe = _sanitizeSearchQuery(query);
    if (safe.isEmpty) {
      return [];
    }
    final pattern = '%$safe%';
    try {
      final byUser = await _client
          .from('profiles')
          .select('id, username, full_name, avatar_url')
          .ilike('username', pattern)
          .limit(limit);

      final byName = await _client
          .from('profiles')
          .select('id, username, full_name, avatar_url')
          .ilike('full_name', pattern)
          .limit(limit);

      final merged = <String, Map<String, dynamic>>{};
      for (final row in _rows(byUser)) {
        final id = row['id'] as String?;
        if (id != null) merged[id] = row;
      }
      for (final row in _rows(byName)) {
        final id = row['id'] as String?;
        if (id != null) merged[id] = row;
      }

      final hits = merged.values.map(ProfileSearchHit.fromRow).toList();
      hits.sort((a, b) {
        final au = (a.username ?? a.id).toLowerCase();
        final bu = (b.username ?? b.id).toLowerCase();
        return au.compareTo(bu);
      });
      if (hits.length <= limit) {
        return hits;
      }
      return hits.sublist(0, limit);
    } on PostgrestException catch (e, st) {
      developer.log(
        'searchProfilesForTagging: ${e.message}',
        name: 'ProfileRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

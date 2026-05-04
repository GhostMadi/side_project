import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileMarkersRepository {
  Future<List<ProfileMarkerModel>> listOwnerMarkers({
    required String ownerId,
    int limit,
    int offset,
  });

  /// Window [event_time, end_time] for validation when creating a post for this marker.
  Future<ProfileMarkerModel?> getMarkerByIdForCurrentUser(String markerId);

  Future<void> setMarkerArchived({required String markerId, required bool archived});

  Future<void> deleteMarker(String markerId);
}

@LazySingleton(as: ProfileMarkersRepository)
class ProfileMarkersRepositoryImpl implements ProfileMarkersRepository {
  ProfileMarkersRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ProfileMarkerModel>> listOwnerMarkers({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _client
        .from('markers')
        .select('id, owner_id, text_emoji, address_text, event_time, end_time, status, post_id')
        .eq('owner_id', ownerId)
        .eq('is_archived', false)
        .order('event_time', ascending: false)
        .range(offset, offset + limit - 1);

    final out = <ProfileMarkerModel>[];
    for (final raw in res) {
      out.add(ProfileMarkerModel.fromJson(Map<String, dynamic>.from(raw)));
    }
    return out;
  }

  @override
  Future<ProfileMarkerModel?> getMarkerByIdForCurrentUser(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return null;
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return null;
    final row = await _client
        .from('markers')
        .select('id, owner_id, text_emoji, address_text, event_time, end_time, status, post_id')
        .eq('id', id)
        .eq('owner_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return ProfileMarkerModel.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> setMarkerArchived({required String markerId, required bool archived}) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    await _client.from('markers').update({'is_archived': archived}).eq('id', id).eq('owner_id', uid);
  }

  @override
  Future<void> deleteMarker(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    await _client.from('markers').delete().eq('id', id);
  }
}


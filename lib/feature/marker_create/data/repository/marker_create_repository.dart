import 'package:injectable/injectable.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MarkerCreateRepository {
  Future<String> createMarker({
    required String emoji,
    required double lat,
    required double lng,
    required String address,
    required List<MarkerTagModel> allTags,
    required Set<String> selectedTagKeys,
    DateTime? eventTime,
    Duration? duration,
  });
}

@LazySingleton(as: MarkerCreateRepository)
class MarkerCreateRepositoryImpl implements MarkerCreateRepository {
  MarkerCreateRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createMarker({
    required String emoji,
    required double lat,
    required double lng,
    required String address,
    required List<MarkerTagModel> allTags,
    required Set<String> selectedTagKeys,
    DateTime? eventTime,
    Duration? duration,
  }) async {
    final session = _client.auth.currentSession;
    final uid = session?.user.id;
    if (uid == null || uid.isEmpty) {
      throw const AuthException('Not authenticated');
    }

    // Sometimes (especially on iOS simulators / after long idle) the access token can be stale.
    // Refreshing makes sure PostgREST sees role=authenticated, otherwise RLS will return 403.
    final expiresAt = session?.expiresAt;
    if (expiresAt != null) {
      final exp = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      if (DateTime.now().isAfter(exp.subtract(const Duration(minutes: 1)))) {
        await _client.auth.refreshSession();
      }
    }

    final et = eventTime ?? DateTime.now();
    final d = duration ?? const Duration(hours: 2);

    // PostGIS geography input: EWKT-like string. PostgREST passes it through to Postgres.
    final loc = 'SRID=4326;POINT($lng $lat)';

    final inserted = await _client
        .from('markers')
        .insert({
          'owner_id': uid,
          'text_emoji': emoji,
          'address_text': address.trim(),
          'event_time': et.toIso8601String(),
          'duration': '${d.inMinutes} minutes',
          'status': 'upcoming',
          'location': loc,
        })
        .select('id')
        .single();

    final markerId = (inserted['id'] as String?)?.trim();
    if (markerId == null || markerId.isEmpty) {
      throw Exception('Marker not created: id is missing');
    }

    if (selectedTagKeys.isEmpty) return markerId;

    final tagIdByKey = <String, String>{};
    for (final t in allTags) {
      tagIdByKey[t.key] = t.id;
    }

    final rows = <Map<String, dynamic>>[];
    for (final k in selectedTagKeys) {
      final tagId = tagIdByKey[k];
      if (tagId == null) continue;
      rows.add({'marker_id': markerId, 'tag_id': tagId});
    }
    if (rows.isNotEmpty) {
      await _client.from('marker_tag_links').insert(rows);
    }

    return markerId;
  }
}


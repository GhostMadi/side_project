import 'package:injectable/injectable.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

abstract class MarkerTagRepository {
  Future<List<MarkerTagModel>> listTags();

  Future<List<MarkerMapItemModel>> listMarkersMap({
    required double lat,
    required double lng,
    required double radiusM,
    DateTime? atTime,
    String? emoji,
    List<String>? tagKeys,
    int limit,
    int offset,
  });
}

@LazySingleton(as: MarkerTagRepository)
class MarkerTagRepositoryImpl implements MarkerTagRepository {
  MarkerTagRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<MarkerTagModel>> listTags() async {
    final res = await _client.from('marker_tags').select('id, key, group_key').order('group_key').order('key');
    final out = <MarkerTagModel>[];
    for (final raw in res) {
      out.add(MarkerTagModel.fromJson(Map<String, dynamic>.from(raw)));
    }
    return out;
  }

  @override
  Future<List<MarkerMapItemModel>> listMarkersMap({
    required double lat,
    required double lng,
    required double radiusM,
    DateTime? atTime,
    String? emoji,
    List<String>? tagKeys,
    int limit = 200,
    int offset = 0,
  }) async {
    final e = emoji?.trim();
    final keys = (tagKeys == null || tagKeys.isEmpty) ? null : tagKeys;
    final params = <String, dynamic>{
      'p_lat': lat,
      'p_lng': lng,
      'p_radius_m': radiusM,
      // Must be JSON-encodable for supabase_flutter RPC call.
      'p_at_time': (atTime ?? DateTime.now()).toUtc().toIso8601String(),
      'p_limit': limit,
      'p_offset': offset,
      // Always include optional args explicitly as null to avoid PostgREST ambiguity.
      'p_emoji': (e != null && e.isNotEmpty) ? e : null,
      'p_tag_keys': keys,
    };

    dynamic res;
    try {
      res = await _client.rpc('list_markers_map', params: params);
    } on PostgrestException catch (err) {
      developer.log(
        'list_markers_map failed: code=${err.code} message=${err.message} details=${err.details} hint=${err.hint} params=$params',
        name: 'MarkersMap',
      );
      rethrow;
    }
    final out = <MarkerMapItemModel>[];
    for (final raw in res) {
      if (raw is! Map) continue;
      out.add(MarkerMapItemModel.fromJson(Map<String, dynamic>.from(raw)));
    }
    return out;
  }
}


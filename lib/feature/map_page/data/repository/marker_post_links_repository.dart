import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Строки из RPC `list_marker_posts` (посты одного маркера / события).
class MarkerPostLink {
  const MarkerPostLink({
    required this.postId,
    required this.sortOrder,
    required this.isPrimary,
    required this.createdAt,
  });

  final String postId;
  final int sortOrder;
  final bool isPrimary;
  final DateTime createdAt;

  factory MarkerPostLink.fromRpcRow(Map<String, dynamic> raw) {
    return MarkerPostLink(
      postId: (raw['post_id'] as String).trim(),
      sortOrder: (raw['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: raw['is_primary'] as bool? ?? false,
      createdAt: DateTime.tryParse(raw['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

abstract class MarkerPostLinksRepository {
  Future<List<MarkerPostLink>> listPostsForMarker(String markerId, {int limit = 100, int offset = 0});
}

@LazySingleton(as: MarkerPostLinksRepository)
class MarkerPostLinksRepositoryImpl implements MarkerPostLinksRepository {
  MarkerPostLinksRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<MarkerPostLink>> listPostsForMarker(String markerId, {int limit = 100, int offset = 0}) async {
    final id = markerId.trim();
    if (id.isEmpty) return const [];
    final res = await _client.rpc(
      'list_marker_posts',
      params: <String, dynamic>{
        'p_marker_id': id,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    final out = <MarkerPostLink>[];
    if (res is List) {
      for (final raw in res) {
        if (raw is Map) {
          out.add(MarkerPostLink.fromRpcRow(Map<String, dynamic>.from(raw)));
        }
      }
    }
    return out;
  }
}

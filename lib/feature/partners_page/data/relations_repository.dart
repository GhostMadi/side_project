import 'package:injectable/injectable.dart';
import 'package:side_project/feature/partners_page/domain/relation_edge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String mapRelationsRpcError(Object e) {
  if (e is PostgrestException) {
    final m = e.message.toLowerCase();
    if (m.contains('not_authenticated')) return 'Войдите в аккаунт.';
    if (m.contains('hiring_disabled_for_you')) return 'Включите «Открыть найм» в настройках профиля.';
    if (m.contains('target_memberships_closed')) return 'Пользователь не принимает заявки в команду.';
    if (m.contains('relation_already_active_or_pending')) return 'Заявка уже есть или связь активна.';
    if (m.contains('cannot_self_request')) return 'Нельзя отправить заявку самому себе.';
    if (m.contains('only_receiver_can_accept') || m.contains('only_receiver_can_reject')) {
      return 'Ответить может только получатель заявки.';
    }
    if (m.contains('can_only_accept_pending') || m.contains('can_only_reject_pending')) {
      return 'Можно ответить только на ожидающую заявку.';
    }
    if (m.contains('can_only_terminate_active')) return 'Завершить можно только активную связь.';
    if (m.contains('relation_not_found')) return 'Связь не найдена.';
    return e.message;
  }
  return e.toString();
}

abstract class RelationsRepository {
  Future<List<RelationEdge>> listMyRelations();

  Future<RelationEdge?> getMyRelationWith(String otherUserId);

  Future<void> requestRelation({required String targetUserId, required String action});

  Future<void> updateRelationStatus({required String relationId, required String newStatus});
}

@LazySingleton(as: RelationsRepository)
class RelationsRepositoryImpl implements RelationsRepository {
  RelationsRepositoryImpl(this._client);

  final SupabaseClient _client;

  String? _uid() {
    final u = _client.auth.currentUser?.id.trim();
    if (u == null || u.isEmpty) return null;
    return u;
  }

  List<RelationEdge> _parseList(dynamic data) {
    if (data is! List) return const [];
    final out = <RelationEdge>[];
    for (final row in data) {
      if (row is! Map) continue;
      try {
        out.add(RelationEdge.fromRow(Map<String, dynamic>.from(row)));
      } catch (_) {}
    }
    return out;
  }

  @override
  Future<List<RelationEdge>> listMyRelations() async {
    final me = _uid();
    if (me == null) return const [];

    final data = await _client
        .from('relations')
        .select()
        .or('from_account_id.eq.$me,to_account_id.eq.$me')
        .order('updated_at', ascending: false);

    return _parseList(data);
  }

  @override
  Future<RelationEdge?> getMyRelationWith(String otherUserId) async {
    final me = _uid();
    if (me == null || otherUserId.trim().isEmpty) return null;
    if (me == otherUserId) return null;

    final raw = await _client.rpc<dynamic>('get_my_relation_with', params: {'p_other': otherUserId.trim()});
    if (raw == null) return null;
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      try {
        return RelationEdge.fromRow(Map<String, dynamic>.from(raw.first! as Map));
      } catch (_) {
        return null;
      }
    }
    if (raw is Map) {
      try {
        return RelationEdge.fromRow(Map<String, dynamic>.from(raw));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> requestRelation({required String targetUserId, required String action}) async {
    await _client.rpc<void>(
      'request_relation',
      params: {'p_target_id': targetUserId.trim(), 'p_action': action.trim()},
    );
  }

  @override
  Future<void> updateRelationStatus({required String relationId, required String newStatus}) async {
    await _client.rpc<void>(
      'update_relation_status',
      params: {'p_relation_id': relationId.trim(), 'p_new_status': newStatus.trim()},
    );
  }
}

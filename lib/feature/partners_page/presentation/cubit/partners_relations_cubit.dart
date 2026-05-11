import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/partners_page/data/relations_repository.dart';
import 'package:side_project/feature/partners_page/domain/relation_edge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'partners_relations_cubit.freezed.dart';

@freezed
sealed class PartnersRelationsState with _$PartnersRelationsState {
  const factory PartnersRelationsState.loading() = _PrLoading;

  const factory PartnersRelationsState.loaded({
    required String viewerId,
    required List<RelationEdge> hireIncoming,
    required List<RelationEdge> hireOutgoing,
    required List<RelationEdge> joinIncoming,
    required List<RelationEdge> joinOutgoing,
    required List<RelationEdge> active,
  }) = _PrLoaded;

  const factory PartnersRelationsState.error(String message) = _PrError;
}

@injectable
class PartnersRelationsCubit extends Cubit<PartnersRelationsState> {
  PartnersRelationsCubit(this._repository) : super(const PartnersRelationsState.loading());

  final RelationsRepository _repository;

  String? get _me => Supabase.instance.client.auth.currentUser?.id.trim();

  PartnersRelationsState _partition(List<RelationEdge> all, String me) {
    final hireIncoming = <RelationEdge>[];
    final hireOutgoing = <RelationEdge>[];
    final joinIncoming = <RelationEdge>[];
    final joinOutgoing = <RelationEdge>[];
    final active = <RelationEdge>[];

    for (final r in all) {
      if (r.status == 'active') {
        active.add(r);
        continue;
      }
      if (r.status != 'pending') continue;

      final hire = r.relationType == 'hire';
      if (hire) {
        if (r.isPendingReceiver(me)) {
          hireIncoming.add(r);
        } else if (r.isPendingInitiator(me)) {
          hireOutgoing.add(r);
        }
      } else {
        if (r.isPendingReceiver(me)) {
          joinIncoming.add(r);
        } else if (r.isPendingInitiator(me)) {
          joinOutgoing.add(r);
        }
      }
    }

    return PartnersRelationsState.loaded(
      viewerId: me,
      hireIncoming: hireIncoming,
      hireOutgoing: hireOutgoing,
      joinIncoming: joinIncoming,
      joinOutgoing: joinOutgoing,
      active: active,
    );
  }

  Future<void> load() async {
    emit(const PartnersRelationsState.loading());
    final me = _me;
    if (me == null) {
      emit(const PartnersRelationsState.error('Войдите в аккаунт.'));
      return;
    }
    try {
      final all = await _repository.listMyRelations();
      if (isClosed) return;
      emit(_partition(all, me));
    } catch (e) {
      if (!isClosed) emit(PartnersRelationsState.error(mapRelationsRpcError(e)));
    }
  }

  Future<String?> accept(String relationId) => _setStatus(relationId, 'active');

  Future<String?> reject(String relationId) => _setStatus(relationId, 'rejected');

  Future<String?> terminate(String relationId) => _setStatus(relationId, 'terminated');

  Future<String?> _setStatus(String relationId, String status) async {
    try {
      await _repository.updateRelationStatus(relationId: relationId, newStatus: status);
      await load();
      return null;
    } catch (e) {
      return mapRelationsRpcError(e);
    }
  }
}

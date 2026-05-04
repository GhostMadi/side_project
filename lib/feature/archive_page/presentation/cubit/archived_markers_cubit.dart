import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'archived_markers_cubit.freezed.dart';

@injectable
class ArchivedMarkersCubit extends Cubit<ArchivedMarkersState> {
  ArchivedMarkersCubit(this._client) : super(const ArchivedMarkersState.initial());

  final SupabaseClient _client;
  static const _pageSize = 50;

  Future<void> load() async {
    if (isClosed) return;
    emit(const ArchivedMarkersState.loading());
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) {
        emit(const ArchivedMarkersState.error('Нужно войти в аккаунт'));
        return;
      }
      final items = await _list(uid, limit: _pageSize, offset: 0);
      if (isClosed) return;
      emit(
        ArchivedMarkersState.loaded(
          items: items,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ArchivedMarkersState.error('$e'));
    }
  }

  Future<void> refresh() => load();

  Future<void> unarchiveMarker(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    await _client.from('markers').update({'is_archived': false}).eq('id', id).eq('owner_id', uid);
    await load();
  }

  Future<void> deleteMarker(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    await _client.from('markers').delete().eq('id', id).eq('owner_id', uid);
    await load();
  }

  Future<void> loadMore() async {
    final cur = state;
    if (cur is! _Loaded) return;
    if (cur.isLoadingMore || !cur.hasMore) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    emit(cur.copyWith(isLoadingMore: true));
    try {
      final more = await _list(uid, limit: _pageSize, offset: cur.items.length);
      if (isClosed) return;
      if (more.isEmpty) {
        emit(cur.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }
      emit(
        cur.copyWith(
          items: [...cur.items, ...more],
          hasMore: more.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(cur.copyWith(isLoadingMore: false));
    }
  }

  Future<List<ProfileMarkerModel>> _list(String ownerId, {required int limit, required int offset}) async {
    final res = await _client
        .from('markers')
        .select('id, owner_id, text_emoji, address_text, event_time, end_time, status, post_id')
        .eq('owner_id', ownerId)
        .eq('is_archived', true)
        .order('event_time', ascending: false)
        .range(offset, offset + limit - 1);

    final out = <ProfileMarkerModel>[];
    for (final raw in res) {
      out.add(ProfileMarkerModel.fromJson(Map<String, dynamic>.from(raw)));
    }
    return out;
  }
}

@freezed
class ArchivedMarkersState with _$ArchivedMarkersState {
  const factory ArchivedMarkersState.initial() = _Initial;
  const factory ArchivedMarkersState.loading() = _Loading;
  const factory ArchivedMarkersState.loaded({
    required List<ProfileMarkerModel> items,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _Loaded;
  const factory ArchivedMarkersState.error(String message) = _Error;
}


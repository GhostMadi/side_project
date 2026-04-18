import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';

part 'profile_following_list_cubit.freezed.dart';

/// Список подписок профиля (на кого подписан пользователь).
@injectable
class ProfileFollowingListCubit extends Cubit<ProfileFollowingListState> {
  ProfileFollowingListCubit(this._repository) : super(const ProfileFollowingListState.initial());

  final FollowListRepository _repository;
  static const _pageSize = 50;

  String? _profileId;

  Future<void> load(String profileId) async {
    _profileId = profileId;
    if (isClosed) return;
    emit(const ProfileFollowingListState.loading());
    try {
      final items = await _repository.listFollowing(profileId, limit: _pageSize, offset: 0);
      if (isClosed) return;
      emit(
        ProfileFollowingListState.loaded(
          items: items,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProfileFollowingListState.error('$e'));
    }
  }

  Future<void> refresh() async {
    final id = _profileId;
    if (id == null) return;
    try {
      final items = await _repository.listFollowing(id, limit: _pageSize, offset: 0);
      if (isClosed) return;
      emit(
        ProfileFollowingListState.loaded(
          items: items,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final id = _profileId;
    if (id == null) return;
    final cur = state.mapOrNull(loaded: (s) => s);
    if (cur == null) return;
    if (cur.isLoadingMore || !cur.hasMore) return;

    emit(cur.copyWith(isLoadingMore: true));
    try {
      final more = await _repository.listFollowing(
        id,
        limit: _pageSize,
        offset: cur.items.length,
      );
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
}

@freezed
class ProfileFollowingListState with _$ProfileFollowingListState {
  const factory ProfileFollowingListState.initial() = _PfoInitial;
  const factory ProfileFollowingListState.loading() = _PfoLoading;
  const factory ProfileFollowingListState.loaded({
    required List<ProfileFollowRow> items,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _PfoLoaded;
  const factory ProfileFollowingListState.error(String message) = _PfoError;
}

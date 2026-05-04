import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'profile_marker_linked_posts_cubit.freezed.dart';

/// Посты профиля, у которых задан [PostModel.markerId] (вкладка «события / маркеры»).
@injectable
class ProfileMarkerLinkedPostsCubit extends Cubit<ProfileMarkerLinkedPostsState> {
  ProfileMarkerLinkedPostsCubit(this._repository) : super(const ProfileMarkerLinkedPostsState.initial());

  final PostsRepository _repository;
  String? _userId;
  static const _pageSize = 24;

  Future<void> load(String userId) async {
    if (isClosed) return;
    _userId = userId;
    emit(const ProfileMarkerLinkedPostsState.loading());
    try {
      final enriched = await _repository.listUserFeedEnrichedCursor(
        userId: userId,
        limit: _pageSize,
        onlyWithMarker: true,
      );
      if (isClosed) return;
      final items = enriched.map((e) => e.post).toList(growable: false);
      final saved = <String, bool>{for (final e in enriched) e.post.id: e.mySaved};
      emit(
        ProfileMarkerLinkedPostsState.loaded(
          items: items,
          savedByPostId: saved,
          hasMore: enriched.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      log('loadUserFeed: $e');

      if (isClosed) return;
      emit(ProfileMarkerLinkedPostsState.error('$e'));
    }
  }

  Future<void> reload() async {
    final u = _userId;
    if (u == null || u.isEmpty) return;
    return load(u);
  }

  Future<void> loadMore() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    await state.maybeWhen(
      loaded: (items, savedByPostId, hasMore, isLoadingMore) async {
        if (isLoadingMore || !hasMore || items.isEmpty) return;
        final cur = ProfileMarkerLinkedPostsState.loaded(
          items: items,
          savedByPostId: savedByPostId,
          hasMore: hasMore,
          isLoadingMore: true,
        );
        emit(cur);
        try {
          final last = items.last;
          final more = await _repository.listUserFeedEnrichedCursor(
            userId: userId,
            limit: _pageSize,
            cursorCreatedAt: last.createdAt,
            cursorPostId: last.id,
            onlyWithMarker: true,
          );
          if (isClosed) return;
          if (more.isEmpty) {
            emit(
              ProfileMarkerLinkedPostsState.loaded(
                items: items,
                savedByPostId: savedByPostId,
                hasMore: false,
                isLoadingMore: false,
              ),
            );
            return;
          }
          final merged = [...items, ...more.map((e) => e.post)];
          final saved = Map<String, bool>.from(savedByPostId);
          for (final e in more) {
            saved[e.post.id] = e.mySaved;
          }
          emit(
            ProfileMarkerLinkedPostsState.loaded(
              items: merged,
              savedByPostId: saved,
              hasMore: more.length == _pageSize,
              isLoadingMore: false,
            ),
          );
        } catch (_) {
          if (isClosed) return;
          emit(
            ProfileMarkerLinkedPostsState.loaded(
              items: items,
              savedByPostId: savedByPostId,
              hasMore: hasMore,
              isLoadingMore: false,
            ),
          );
        }
      },
      orElse: () async {},
    );
  }
}

@freezed
sealed class ProfileMarkerLinkedPostsState with _$ProfileMarkerLinkedPostsState {
  const factory ProfileMarkerLinkedPostsState.initial() = _Initial;
  const factory ProfileMarkerLinkedPostsState.loading() = _Loading;
  const factory ProfileMarkerLinkedPostsState.loaded({
    required List<PostModel> items,
    required Map<String, bool> savedByPostId,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _Loaded;
  const factory ProfileMarkerLinkedPostsState.error(String message) = _Error;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'archived_posts_cubit.freezed.dart';

@injectable
class ArchivedPostsCubit extends Cubit<ArchivedPostsState> {
  ArchivedPostsCubit(this._repository) : super(const ArchivedPostsState.initial());

  final PostsRepository _repository;
  static const _pageSize = 24;

  Future<void> load() async {
    if (isClosed) return;
    emit(const ArchivedPostsState.loading());
    try {
      final items = await _repository.listMyArchivedPosts(limit: _pageSize, offset: 0);
      if (isClosed) return;
      emit(
        ArchivedPostsState.loaded(
          items: items,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ArchivedPostsState.error('$e'));
    }
  }

  Future<void> refresh() async {
    if (isClosed) return;
    try {
      final items = await _repository.listMyArchivedPosts(limit: _pageSize, offset: 0);
      if (isClosed) return;
      emit(
        ArchivedPostsState.loaded(
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
    final cur = state;
    if (cur is! _Loaded) return;
    if (cur.isLoadingMore || !cur.hasMore) return;
    if (cur.items.isEmpty) return;

    emit(cur.copyWith(isLoadingMore: true));
    try {
      final more = await _repository.listMyArchivedPosts(
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

  void removePostLocally(String postId) {
    final cur = state;
    if (cur is! _Loaded) return;
    final next = cur.items.where((p) => p.id != postId).toList(growable: false);
    emit(cur.copyWith(items: next, hasMore: cur.hasMore && next.isNotEmpty));
  }
}

@freezed
class ArchivedPostsState with _$ArchivedPostsState {
  const factory ArchivedPostsState.initial() = _Initial;
  const factory ArchivedPostsState.loading() = _Loading;
  const factory ArchivedPostsState.loaded({
    required List<PostModel> items,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _Loaded;
  const factory ArchivedPostsState.error(String message) = _Error;
}

import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_feed_item.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'posts_list_cubit.freezed.dart';

enum PostListReaction { none, like, dislike }

@injectable
class PostsListCubit extends Cubit<PostsListState> {
  PostsListCubit(this._repository) : super(const PostsListState.initial());

  final PostsRepository _repository;
  String? _userId;
  String? _feedClusterId;
  bool _feedOnlyWithoutCluster = false;

  /// Посты, привязанные к маркеру, не показываем в сетке «публикации» (есть отдельная вкладка).
  final bool _excludeWithMarker = true;
  static const _pageSize = 24;

  void _setFeedFilterAll() {
    _feedClusterId = null;
    _feedOnlyWithoutCluster = false;
  }

  void _setFeedFilterCluster(String clusterId) {
    _feedClusterId = clusterId;
    _feedOnlyWithoutCluster = false;
  }

  void _setFeedFilterWithoutCluster() {
    _feedClusterId = null;
    _feedOnlyWithoutCluster = true;
  }

  Map<String, PostListReaction> _reactionsFromEnriched(List<PostFeedItem> rows) {
    final reactions = <String, PostListReaction>{};
    for (final e in rows) {
      reactions[e.post.id] = switch (e.myReactionKind) {
        'like' => PostListReaction.like,
        'dislike' => PostListReaction.dislike,
        _ => PostListReaction.none,
      };
    }
    return reactions;
  }

  Map<String, bool> _savedFromEnriched(List<PostFeedItem> rows) {
    final saved = <String, bool>{};
    for (final e in rows) {
      saved[e.post.id] = e.mySaved;
    }
    return saved;
  }

  Future<void> loadUserFeed(String userId) async {
    if (isClosed) return;
    _userId = userId;
    _setFeedFilterAll();
    emit(const PostsListState.loading());
    try {
      final enriched = await _repository.listUserFeedEnrichedCursor(
        userId: userId,
        limit: _pageSize,
        excludeWithMarker: _excludeWithMarker,
      );
      if (isClosed) return;
      final items = enriched.map((e) => e.post).toList(growable: false);
      final reactions = _reactionsFromEnriched(enriched);
      final savedByPostId = _savedFromEnriched(enriched);
      emit(
        PostsListState.loaded(
          items: items,
          reactions: reactions,
          savedByPostId: savedByPostId,
          feedClusterId: null,
          feedWithoutCluster: false,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      log('loadUserFeed: $e');
      emit(PostsListState.error('$e'));
    }
  }

  /// Лента только постов выбранного кластера.
  Future<void> loadUserFeedForCluster(String userId, String clusterId) async {
    if (isClosed) return;
    _userId = userId;
    _setFeedFilterCluster(clusterId);
    emit(PostsListState.loading(feedClusterId: clusterId));
    try {
      final enriched = await _repository.listUserFeedEnrichedCursor(
        userId: userId,
        limit: _pageSize,
        clusterId: clusterId,
        excludeWithMarker: _excludeWithMarker,
      );
      if (isClosed) return;
      final items = enriched.map((e) => e.post).toList(growable: false);
      final reactions = _reactionsFromEnriched(enriched);
      final savedByPostId = _savedFromEnriched(enriched);
      emit(
        PostsListState.loaded(
          items: items,
          reactions: reactions,
          savedByPostId: savedByPostId,
          feedClusterId: clusterId,
          feedWithoutCluster: false,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostsListState.error('$e'));
    }
  }

  /// Посты без кластера («Остальное»).
  /// Повторная загрузка ленты с тем же фильтром (например после удаления поста).
  Future<void> reloadKeepingFilter() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    if (_feedOnlyWithoutCluster) {
      return loadUserFeedWithoutCluster(userId);
    }
    final id = _feedClusterId;
    if (id != null && id.isNotEmpty) {
      return loadUserFeedForCluster(userId, id);
    }
    return loadUserFeed(userId);
  }

  Future<void> loadUserFeedWithoutCluster(String userId) async {
    if (isClosed) return;
    _userId = userId;
    _setFeedFilterWithoutCluster();
    emit(const PostsListState.loading(feedWithoutCluster: true));
    try {
      final enriched = await _repository.listUserFeedEnrichedCursor(
        userId: userId,
        limit: _pageSize,
        onlyWithoutCluster: true,
        excludeWithMarker: _excludeWithMarker,
      );
      if (isClosed) return;
      final items = enriched.map((e) => e.post).toList(growable: false);
      final reactions = _reactionsFromEnriched(enriched);
      final savedByPostId = _savedFromEnriched(enriched);
      emit(
        PostsListState.loaded(
          items: items,
          reactions: reactions,
          savedByPostId: savedByPostId,
          feedClusterId: null,
          feedWithoutCluster: true,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostsListState.error('$e'));
    }
  }

  Future<void> loadMore() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    final cur = state;
    if (cur is! _Loaded) return;
    if (cur.isLoadingMore || !cur.hasMore) return;
    if (cur.items.isEmpty) return;

    emit(cur.copyWith(isLoadingMore: true));
    try {
      final last = cur.items.last;
      final moreEnriched = await _repository.listUserFeedEnrichedCursor(
        userId: userId,
        limit: _pageSize,
        cursorCreatedAt: last.createdAt,
        cursorPostId: last.id,
        clusterId: _feedClusterId,
        onlyWithoutCluster: _feedOnlyWithoutCluster,
        excludeWithMarker: _excludeWithMarker,
      );
      if (isClosed) return;
      if (moreEnriched.isEmpty) {
        emit(cur.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }

      final morePosts = moreEnriched.map((e) => e.post).toList(growable: false);
      final mergedItems = [...cur.items, ...morePosts];
      final hasMore = moreEnriched.length == _pageSize;

      final mergedReactions = Map<String, PostListReaction>.from(cur.reactions);
      final mergedSaved = Map<String, bool>.from(cur.savedByPostId);
      for (final e in moreEnriched) {
        mergedReactions[e.post.id] = switch (e.myReactionKind) {
          'like' => PostListReaction.like,
          'dislike' => PostListReaction.dislike,
          _ => PostListReaction.none,
        };
        mergedSaved[e.post.id] = e.mySaved;
      }

      emit(
        cur.copyWith(
          items: mergedItems,
          reactions: mergedReactions,
          savedByPostId: mergedSaved,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(cur.copyWith(isLoadingMore: false));
    }
  }
}

@freezed
class PostsListState with _$PostsListState {
  const factory PostsListState.initial() = _Initial;

  /// Загрузка ленты; [feedClusterId] / [feedWithoutCluster] — оптимистичный фильтр для UI до ответа API.
  const factory PostsListState.loading({String? feedClusterId, @Default(false) bool feedWithoutCluster}) =
      _Loading;
  const factory PostsListState.loaded({
    required List<PostModel> items,
    required Map<String, PostListReaction> reactions,
    required Map<String, bool> savedByPostId,

    /// Активный фильтр ленты: `null` и [feedWithoutCluster]==false — вся лента.
    String? feedClusterId,
    @Default(false) bool feedWithoutCluster,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _Loaded;
  const factory PostsListState.error(String message) = _Error;
}

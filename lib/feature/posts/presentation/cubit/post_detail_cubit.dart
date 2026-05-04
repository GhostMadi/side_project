import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';

part 'post_detail_cubit.freezed.dart';

enum PostReaction { none, like, dislike }

@injectable
class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._repository, this._profileCache) : super(const PostDetailState.initial());

  final PostsRepository _repository;
  final ProfileMiniCacheStorage _profileCache;
  String? _postId;

  /// Последний kind для RPC (`like` / `dislike`); дренаж шлёт подряд, пока очередь не опустеет.
  String? _queuedReactionKind;

  Future<void>? _reactionDrainFuture;

  /// Растёт на каждый тап по реакции — отменяет отложенную сверку, если пользователь снова нажал.
  int _reactionInteractionGeneration = 0;

  Future<void> load(String postId, {bool emitLoading = true}) async {
    if (isClosed) return;
    _postId = postId;
    if (emitLoading) {
      emit(const PostDetailState.loading());
    }
    try {
      // Быстрый слой: пост + media + мини-данные автора.
      // Маркерные данные (event card) догружаем отдельным запросом только если marker_id есть.
      final base = await _repository.getByIdWithAuthorMini(postId);
      if (isClosed) return;
      if (base == null) {
        emit(const PostDetailState.notFound());
        return;
      }
      final post = base.post;
      final k = await _repository.getCachedMyReactionKind(postId);
      final reaction = switch (k) {
        'like' => PostReaction.like,
        'dislike' => PostReaction.dislike,
        _ => PostReaction.none,
      };
      final isSaved = (await _repository.getCachedIsPostSaved(postId)) ?? false;
      emit(
        PostDetailState.loaded(
          post: post,
          reaction: reaction,
          authorUsername: base.username,
          authorAvatarUrl: base.avatarUrl,
          isSaved: isSaved,
        ),
      );
      unawaited(
        _profileCache.write(
          post.userId,
          username: base.username,
          avatarUrl: base.avatarUrl,
        ),
      );
      unawaited(_repository.syncPendingReactions());

      final markerId = post.markerId?.trim();
      if (markerId == null || markerId.isEmpty) return;
      if (post.marker != null) return;

      // Догружаем маркер (event card) только для постов с marker_id.
      unawaited(() async {
        try {
          final item = await _repository.getPostEnriched(postId);
          if (isClosed) return;
          final cur = state;
          if (cur is! _Loaded || cur.post.id != postId) return;
          if (item == null) return;
          emit(
            PostDetailState.loaded(
              post: item.post,
              reaction: cur.reaction,
              authorUsername: item.authorUsername ?? cur.authorUsername,
              authorAvatarUrl: item.authorAvatarUrl ?? cur.authorAvatarUrl,
              isSaved: cur.isSaved,
            ),
          );
        } catch (_) {
          // best-effort: keep base UI
        }
      }());
    } catch (e) {
      if (isClosed) return;
      emit(PostDetailState.error('$e'));
    }
  }

  void _scheduleReactionDrain(String postId) {
    if (_reactionDrainFuture != null) return;
    _reactionDrainFuture = _drainReactionQueue(postId);
    _reactionDrainFuture!.whenComplete(() {
      _reactionDrainFuture = null;
      if (_queuedReactionKind != null) {
        _scheduleReactionDrain(postId);
      } else {
        _scheduleSoftReconcile(postId);
      }
    });
  }

  Future<void> _drainReactionQueue(String postId) async {
    while (true) {
      final kind = _queuedReactionKind;
      if (kind == null) break;
      _queuedReactionKind = null;
      try {
        await _repository.setMyReaction(postId, kind);
      } catch (e) {
        if (isClosed) return;
        emit(PostDetailState.error('$e'));
        await load(postId, emitLoading: false);
        return;
      }
    }
  }

  void _scheduleSoftReconcile(String postId) {
    final genAtSchedule = _reactionInteractionGeneration;
    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (isClosed || genAtSchedule != _reactionInteractionGeneration) return;
      if (_queuedReactionKind != null || _reactionDrainFuture != null) return;
      final cur = state;
      if (cur is! _Loaded || cur.post.id != postId) return;
      final authorUsername = cur.authorUsername;
      final authorAvatarUrl = cur.authorAvatarUrl;
      try {
        final item = await _repository.getPostEnriched(postId);
        if (isClosed || genAtSchedule != _reactionInteractionGeneration) return;
        if (_queuedReactionKind != null || _reactionDrainFuture != null) return;
        final s = state;
        if (s is! _Loaded || s.post.id != postId) return;
        if (item == null) return;
        final reaction = switch (item.myReactionKind) {
          'like' => PostReaction.like,
          'dislike' => PostReaction.dislike,
          _ => PostReaction.none,
        };
        emit(
          PostDetailState.loaded(
            post: item.post,
            reaction: reaction,
            authorUsername: item.authorUsername ?? authorUsername,
            authorAvatarUrl: item.authorAvatarUrl ?? authorAvatarUrl,
            isSaved: item.mySaved,
          ),
        );
      } catch (_) {
        // оставляем оптимистичный UI
      }
    }());
  }

  Future<void> toggleLike() async {
    final postId = _postId;
    if (postId == null) return;
    // Optimistic: update reaction + counters immediately (no "unlike" on repeated like).
    final cur = state;
    if (cur case _Loaded(:final post, :final reaction, :final authorUsername, :final authorAvatarUrl, :final isSaved)) {
      if (reaction == PostReaction.like) return;
      final next = post.copyWith(
        likesCount: post.likesCount + 1,
        dislikesCount: reaction == PostReaction.dislike
            ? (post.dislikesCount - 1).clamp(0, 1 << 30)
            : post.dislikesCount,
      );
      emit(
        PostDetailState.loaded(
          post: next,
          reaction: PostReaction.like,
          authorUsername: authorUsername,
          authorAvatarUrl: authorAvatarUrl,
          isSaved: isSaved,
        ),
      );
    }
    _reactionInteractionGeneration++;
    _queuedReactionKind = 'like';
    _scheduleReactionDrain(postId);
  }

  Future<void> toggleDislike() async {
    final postId = _postId;
    if (postId == null) return;
    // Optimistic: update reaction + counters immediately (no "undislike" on repeated dislike).
    final cur = state;
    if (cur case _Loaded(:final post, :final reaction, :final authorUsername, :final authorAvatarUrl, :final isSaved)) {
      if (reaction == PostReaction.dislike) return;
      final next = post.copyWith(
        dislikesCount: post.dislikesCount + 1,
        likesCount: reaction == PostReaction.like ? (post.likesCount - 1).clamp(0, 1 << 30) : post.likesCount,
      );
      emit(
        PostDetailState.loaded(
          post: next,
          reaction: PostReaction.dislike,
          authorUsername: authorUsername,
          authorAvatarUrl: authorAvatarUrl,
          isSaved: isSaved,
        ),
      );
    }
    _reactionInteractionGeneration++;
    _queuedReactionKind = 'dislike';
    _scheduleReactionDrain(postId);
  }

  Future<void> delete() async {
    final postId = _postId;
    if (postId == null) return;
    try {
      await _repository.deletePost(postId);
      if (isClosed) return;
      emit(const PostDetailState.notFound());
    } catch (e) {
      if (isClosed) return;
      emit(PostDetailState.error('$e'));
    }
  }

  Future<void> setArchived(bool archived) async {
    final postId = _postId;
    if (postId == null) return;
    final cur = state;
    if (cur is! _Loaded) return;
    try {
      final markerId = cur.post.markerId?.trim();
      if (markerId != null && markerId.isNotEmpty) {
        await _repository.setMarkerArchived(markerId, archived);
        if (isClosed) return;
        final m = cur.post.marker;
        emit(
          PostDetailState.loaded(
            post: cur.post.copyWith(marker: m == null ? null : m.copyWith(isArchived: archived)),
            reaction: cur.reaction,
            authorUsername: cur.authorUsername,
            authorAvatarUrl: cur.authorAvatarUrl,
            isSaved: cur.isSaved,
          ),
        );
        return;
      }

      await _repository.setPostArchived(postId, archived);
      if (isClosed) return;
      emit(
        PostDetailState.loaded(
          post: cur.post.copyWith(isArchived: archived),
          reaction: cur.reaction,
          authorUsername: cur.authorUsername,
          authorAvatarUrl: cur.authorAvatarUrl,
          isSaved: cur.isSaved,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostDetailState.error('$e'));
    }
  }

  Future<void> setPostCluster(String? clusterId) async {
    final postId = _postId;
    if (postId == null) return;
    final cur = state;
    if (cur is! _Loaded) return;
    try {
      await _repository.setPostClusterId(postId, clusterId);
      if (isClosed) return;
      emit(
        PostDetailState.loaded(
          post: cur.post.copyWith(clusterId: clusterId),
          reaction: cur.reaction,
          authorUsername: cur.authorUsername,
          authorAvatarUrl: cur.authorAvatarUrl,
          isSaved: cur.isSaved,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostDetailState.error('$e'));
    }
  }

  Future<void> toggleSave() async {
    final postId = _postId;
    if (postId == null) return;
    final cur = state;
    if (cur is! _Loaded) return;
    final wasSaved = cur.isSaved;
    final post = cur.post;
    final nextSaved = !wasSaved;
    final nextCount = (post.savesCount + (nextSaved ? 1 : -1)).clamp(0, 1 << 30);
    emit(
      PostDetailState.loaded(
        post: post.copyWith(savesCount: nextCount),
        reaction: cur.reaction,
        authorUsername: cur.authorUsername,
        authorAvatarUrl: cur.authorAvatarUrl,
        isSaved: nextSaved,
      ),
    );
    try {
      if (nextSaved) {
        await _repository.savePost(postId);
      } else {
        await _repository.unsavePost(postId);
      }
    } catch (_) {
      if (isClosed) return;
      emit(
        PostDetailState.loaded(
          post: post,
          reaction: cur.reaction,
          authorUsername: cur.authorUsername,
          authorAvatarUrl: cur.authorAvatarUrl,
          isSaved: wasSaved,
        ),
      );
    }
  }
}

@freezed
class PostDetailState with _$PostDetailState {
  const factory PostDetailState.initial() = _Initial;
  const factory PostDetailState.loading() = _Loading;
  const factory PostDetailState.notFound() = _NotFound;
  const factory PostDetailState.loaded({
    required PostModel post,
    required PostReaction reaction,
    String? authorUsername,
    String? authorAvatarUrl,
    @Default(false) bool isSaved,
  }) = _Loaded;
  const factory PostDetailState.error(String message) = _Error;
}

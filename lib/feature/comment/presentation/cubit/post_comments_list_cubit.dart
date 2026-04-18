import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/comment/data/models/comment_model.dart';
import 'package:side_project/feature/comment/data/repository/comments_repository.dart';

part 'post_comments_list_cubit.freezed.dart';

/// Список корневых комментариев к посту + пагинация (без отправки текста).
class PostCommentsListCubit extends Cubit<PostCommentsListState> {
  PostCommentsListCubit(this._repository, this.postId) : super(const PostCommentsListState.initial());

  final CommentsRepository _repository;
  final String postId;

  static const _pageSize = 24;

  static Set<String> _allCommentIds(_Loaded s) {
    final out = <String>{};
    for (final c in s.items) {
      out.add(c.id);
    }
    for (final list in s.replyThreads.values) {
      for (final c in list) {
        out.add(c.id);
      }
    }
    return out;
  }

  static CommentModel _patchCommentCounts(CommentModel c, String targetId, String? prevKind, String nextKind) {
    if (c.id != targetId) return c;
    var lc = c.likesCount;
    var dc = c.dislikesCount;
    if (prevKind == 'like') lc--;
    if (prevKind == 'dislike') dc--;
    if (nextKind == 'like') lc++;
    if (nextKind == 'dislike') dc++;
    return c.copyWith(
      likesCount: lc.clamp(0, 1 << 30),
      dislikesCount: dc.clamp(0, 1 << 30),
    );
  }

  _Loaded _applyReactionOptimistic(_Loaded cur, String commentId, String? prevKind, String nextKind) {
    CommentModel patch(CommentModel c) => _patchCommentCounts(c, commentId, prevKind, nextKind);
    final threads = <String, List<CommentModel>>{};
    for (final e in cur.replyThreads.entries) {
      threads[e.key] = e.value.map(patch).toList();
    }
    final nextMap = Map<String, String>.from(cur.myReactionByCommentId);
    nextMap[commentId] = nextKind;
    return cur.copyWith(
      items: cur.items.map(patch).toList(),
      replyThreads: threads,
      myReactionByCommentId: nextMap,
    );
  }

  _Loaded _replaceComment(_Loaded cur, CommentModel fresh) {
    final id = fresh.id;
    CommentModel rep(CommentModel c) => c.id == id ? fresh : c;
    final threads = <String, List<CommentModel>>{};
    for (final e in cur.replyThreads.entries) {
      threads[e.key] = e.value.map(rep).toList();
    }
    return cur.copyWith(
      items: cur.items.map(rep).toList(),
      replyThreads: threads,
    );
  }

  Future<void> _syncMyReactions() async {
    final cur = state;
    if (cur is! _Loaded) return;
    final ids = _allCommentIds(cur).toList();
    if (ids.isEmpty) return;
    try {
      final fresh = await _repository.getMyCommentReactionsBatch(ids);
      if (isClosed) return;
      final s = state;
      if (s is! _Loaded) return;
      final merged = Map<String, String>.from(s.myReactionByCommentId);
      for (final id in ids) {
        final k = fresh[id];
        if (k != null && k.isNotEmpty) {
          merged[id] = k;
        } else {
          merged.remove(id);
        }
      }
      emit(s.copyWith(myReactionByCommentId: merged));
    } catch (_) {}
  }

  Future<void> _reconcileCommentRow(String commentId) async {
    try {
      final row = await _repository.fetchCommentById(commentId);
      if (isClosed || row == null) return;
      final s = state;
      if (s is! _Loaded) return;
      emit(_replaceComment(s, row));
    } catch (_) {}
  }

  /// Как у поста: повторный тап по лайку не снимает его.
  Future<void> toggleCommentLike(String commentId) async {
    final id = commentId.trim();
    if (id.isEmpty) return;
    final cur = state;
    if (cur is! _Loaded) return;
    final prev = cur.myReactionByCommentId[id];
    if (prev == 'like') return;

    final next = _applyReactionOptimistic(cur, id, prev, 'like');
    emit(next);
    try {
      await _repository.setMyCommentReaction(id, 'like');
    } catch (_) {
      await _reconcileCommentRow(id);
      await _syncMyReactions();
    }
  }

  Future<void> toggleCommentDislike(String commentId) async {
    final id = commentId.trim();
    if (id.isEmpty) return;
    final cur = state;
    if (cur is! _Loaded) return;
    final prev = cur.myReactionByCommentId[id];
    if (prev == 'dislike') return;

    final next = _applyReactionOptimistic(cur, id, prev, 'dislike');
    emit(next);
    try {
      await _repository.setMyCommentReaction(id, 'dislike');
    } catch (_) {
      await _reconcileCommentRow(id);
      await _syncMyReactions();
    }
  }

  Future<void> loadInitial() async {
    if (isClosed || postId.trim().isEmpty) return;
    emit(const PostCommentsListState.loading());
    try {
      final page = await _repository.fetchRootComments(postId, limit: _pageSize, offset: 0);
      if (isClosed) return;
      final items = page.comments;
      emit(
        PostCommentsListState.loaded(
          items: items,
          offset: items.length,
          hasMore: items.length == _pageSize,
          isLoadingMore: false,
          replyThreads: const {},
          loadingRepliesForParentId: null,
          myReactionByCommentId: page.myReactionsByCommentId,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostCommentsListState.error('$e'));
    }
  }

  Future<void> loadMore() async {
    if (isClosed || postId.trim().isEmpty) return;
    final cur = state;
    if (cur is! _Loaded) return;
    if (cur.isLoadingMore || !cur.hasMore) return;

    emit(cur.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.fetchRootComments(postId, limit: _pageSize, offset: cur.offset);
      if (isClosed) return;
      final more = page.comments;
      if (more.isEmpty) {
        emit(cur.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }
      final merged = [...cur.items, ...more];
      if (isClosed) return;
      emit(
        cur.copyWith(
          items: merged,
          offset: cur.offset + more.length,
          hasMore: more.length == _pageSize,
          isLoadingMore: false,
          myReactionByCommentId: {...cur.myReactionByCommentId, ...page.myReactionsByCommentId},
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(cur.copyWith(isLoadingMore: false));
    }
  }

  /// После успешной отправки комментария — вставить в начало списка (сервер уже вернул модель).
  void prependComment(CommentModel comment) {
    final cur = state;
    if (cur is! _Loaded) return;
    final parentId = comment.parentCommentId?.trim();
    if (parentId != null && parentId.isNotEmpty) {
      final map = Map<String, List<CommentModel>>.from(cur.replyThreads);
      final list = List<CommentModel>.from(map[parentId] ?? []);
      if (list.any((c) => c.id == comment.id)) return;
      list.add(comment);
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      map[parentId] = list;
      final bumped = _withBumpedParentRepliesCount(cur, parentId);
      emit(bumped.copyWith(replyThreads: map));
      return;
    }
    final exists = cur.items.any((c) => c.id == comment.id);
    if (exists) return;
    emit(cur.copyWith(items: [comment, ...cur.items]));
  }

  /// Подгрузить прямых ответов для любого комментария (корень или ответ).
  Future<void> loadReplies(String parentCommentId) async {
    if (isClosed || postId.trim().isEmpty) return;
    final id = parentCommentId.trim();
    if (id.isEmpty) return;
    final cur = state;
    if (cur is! _Loaded) return;
    if (cur.replyThreads.containsKey(id)) return;

    emit(cur.copyWith(loadingRepliesForParentId: id));
    try {
      final page = await _repository.fetchReplies(postId, id);
      if (isClosed) return;
      final s = state;
      if (s is! _Loaded) return;
      final replies = page.comments;
      final map = Map<String, List<CommentModel>>.from(s.replyThreads);
      map[id] = replies;
      if (isClosed) return;
      final s2 = state;
      if (s2 is! _Loaded) return;
      emit(
        s2.copyWith(
          replyThreads: map,
          loadingRepliesForParentId: null,
          myReactionByCommentId: {...s2.myReactionByCommentId, ...page.myReactionsByCommentId},
        ),
      );
    } catch (_) {
      if (isClosed) return;
      final s = state;
      if (s is! _Loaded) return;
      emit(s.copyWith(loadingRepliesForParentId: null));
    }
  }

  void onScrollNearEnd(double pixels, double maxScrollExtent) {
    if (maxScrollExtent <= 0) return;
    if (pixels >= maxScrollExtent - 280) {
      loadMore();
    }
  }

  /// Локально +1 к [replies_count] у родителя (триггер на сервере уже обновил строку; UI без рефетча родителя).
  _Loaded _withBumpedParentRepliesCount(_Loaded cur, String parentId) {
    CommentModel bump(CommentModel c) {
      if (c.id == parentId) {
        return c.copyWith(repliesCount: c.repliesCount + 1);
      }
      return c;
    }

    final threads = <String, List<CommentModel>>{};
    for (final e in cur.replyThreads.entries) {
      threads[e.key] = e.value.map(bump).toList();
    }
    return cur.copyWith(
      items: cur.items.map(bump).toList(),
      replyThreads: threads,
    );
  }
}

@freezed
abstract class PostCommentsListState with _$PostCommentsListState {
  const factory PostCommentsListState.initial() = _Initial;
  const factory PostCommentsListState.loading() = _Loading;
  const factory PostCommentsListState.loaded({
    required List<CommentModel> items,
    required int offset,
    required bool hasMore,
    required bool isLoadingMore,
    /// Ключ — id родительского комментария; значение — прямые ответы (после loadReplies).
    @Default({}) Map<String, List<CommentModel>> replyThreads,
    String? loadingRepliesForParentId,
    /// Текущий пользователь: comment_id → like | dislike (как get_my_post_reactions).
    @Default({}) Map<String, String> myReactionByCommentId,
  }) = _Loaded;
  const factory PostCommentsListState.error(String message) = _Error;
}

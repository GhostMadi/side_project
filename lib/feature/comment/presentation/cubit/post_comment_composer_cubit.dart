import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/comment/data/models/comment_model.dart';
import 'package:side_project/feature/comment/data/repository/comments_repository.dart';

part 'post_comment_composer_cubit.freezed.dart';

/// Ввод и отправка комментария: корень или ответ (отдельно от списка и пагинации).
class PostCommentComposerCubit extends Cubit<PostCommentComposerState> {
  PostCommentComposerCubit(
    this._repository,
    this.postId, {
    this.onPosted,
  }) : super(const PostCommentComposerState());

  final CommentsRepository _repository;
  final String postId;
  final void Function(CommentModel comment)? onPosted;

  static const maxLength = 2000;

  void setDraft(String value) {
    emit(state.copyWith(draft: value, errorMessage: null));
  }

  void startReply({required String parentCommentId, required String parentLabel}) {
    final id = parentCommentId.trim();
    if (id.isEmpty) return;
    emit(
      state.copyWith(
        replyParentCommentId: id,
        replyParentLabel: parentLabel.trim().isEmpty ? null : parentLabel.trim(),
        errorMessage: null,
      ),
    );
  }

  void clearReply() {
    emit(state.copyWith(replyParentCommentId: null, replyParentLabel: null, errorMessage: null));
  }

  Future<void> submit() async {
    if (isClosed || postId.trim().isEmpty) return;
    final t = state.draft.trim();
    if (t.isEmpty) return;
    if (t.length > maxLength) {
      emit(state.copyWith(errorMessage: 'Не больше $maxLength символов'));
      return;
    }
    if (state.isSending) return;

    final parentId = state.replyParentCommentId?.trim();

    emit(state.copyWith(isSending: true, errorMessage: null));
    try {
      final created = parentId != null && parentId.isNotEmpty
          ? await _repository.addComment(postId, t, parentCommentId: parentId)
          : await _repository.addRootComment(postId, t);
      if (isClosed) return;
      emit(const PostCommentComposerState());
      onPosted?.call(created);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isSending: false, errorMessage: '$e'));
    }
  }
}

@freezed
abstract class PostCommentComposerState with _$PostCommentComposerState {
  const factory PostCommentComposerState({
    @Default('') String draft,
    @Default(false) bool isSending,
    String? errorMessage,
    /// Ответ на комментарий; если null — публикуется корневой комментарий.
    String? replyParentCommentId,
    String? replyParentLabel,
  }) = _PostCommentComposerState;
}

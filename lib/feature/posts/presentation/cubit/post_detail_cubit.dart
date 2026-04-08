import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'post_detail_cubit.freezed.dart';

@injectable
class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._repository) : super(const PostDetailState.initial());

  final PostsRepository _repository;

  Future<void> load(String postId) async {
    if (isClosed) return;
    emit(const PostDetailState.loading());
    try {
      final post = await _repository.getById(postId);
      if (isClosed) return;
      if (post == null) {
        emit(const PostDetailState.notFound());
        return;
      }
      emit(PostDetailState.loaded(post));
    } catch (e) {
      if (isClosed) return;
      emit(PostDetailState.error('$e'));
    }
  }
}

@freezed
class PostDetailState with _$PostDetailState {
  const factory PostDetailState.initial() = _Initial;
  const factory PostDetailState.loading() = _Loading;
  const factory PostDetailState.notFound() = _NotFound;
  const factory PostDetailState.loaded(PostModel post) = _Loaded;
  const factory PostDetailState.error(String message) = _Error;
}


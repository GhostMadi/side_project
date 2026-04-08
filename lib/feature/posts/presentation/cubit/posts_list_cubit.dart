import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'posts_list_cubit.freezed.dart';

@injectable
class PostsListCubit extends Cubit<PostsListState> {
  PostsListCubit(this._repository) : super(const PostsListState.initial());

  final PostsRepository _repository;

  Future<void> loadUserFeed(String userId) async {
    if (isClosed) return;
    emit(const PostsListState.loading());
    try {
      final items = await _repository.listUserFeed(userId);
      if (isClosed) return;
      emit(PostsListState.loaded(items));
    } catch (e) {
      if (isClosed) return;
      emit(PostsListState.error('$e'));
    }
  }
}

@freezed
class PostsListState with _$PostsListState {
  const factory PostsListState.initial() = _Initial;
  const factory PostsListState.loading() = _Loading;
  const factory PostsListState.loaded(List<PostModel> items) = _Loaded;
  const factory PostsListState.error(String message) = _Error;
}


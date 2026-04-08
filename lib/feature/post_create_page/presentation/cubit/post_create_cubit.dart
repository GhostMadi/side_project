import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/shared/app_single_select.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_draft.dart';
import 'package:side_project/feature/post_create_page/data/repository/post_create_repository.dart';

part 'post_create_cubit.freezed.dart';

@injectable
class PostCreateCubit extends Cubit<PostCreateState> {
  PostCreateCubit(this._repository) : super(const PostCreateState.initial());

  final PostCreateRepository _repository;

  static List<AppSingleSelectOption<String>> _optionsForClusters(List<ClusterModel> clusters) {
    return [
      const AppSingleSelectOption<String>(value: '', label: 'Не привязывать'),
      ...clusters.map((c) => AppSingleSelectOption<String>(value: c.id, label: c.title)),
    ];
  }

  Future<void> load(String ownerId) async {
    if (isClosed) return;
    emit(const PostCreateState.loading());
    try {
      final clusters = await _repository.listMyClusters(ownerId);
      if (isClosed) return;
      emit(
        PostCreateState.ready(
          clusters: clusters,
          clusterSelectOptions: _optionsForClusters(clusters),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(PostCreateState.error(message: '$e'));
    }
  }

  /// Публикация поста. При ошибке сети/API возвращает `null`, детали — в [PostCreateState.ready.errorMessage].
  Future<CreatePostResponse?> submit(PostCreateDraft draft) async {
    return state.maybeWhen(
      ready: (clusters, options, _, __) async {
        emit(
          PostCreateState.ready(
            clusters: clusters,
            clusterSelectOptions: options,
            isSubmitting: true,
            errorMessage: null,
          ),
        );
        try {
          final res = await _repository.createPost(draft);
          if (isClosed) return res;
          emit(
            PostCreateState.ready(
              clusters: clusters,
              clusterSelectOptions: options,
              isSubmitting: false,
              errorMessage: null,
            ),
          );
          return res;
        } catch (e) {
          if (isClosed) return null;
          emit(
            PostCreateState.ready(
              clusters: clusters,
              clusterSelectOptions: options,
              isSubmitting: false,
              errorMessage: '$e',
            ),
          );
          return null;
        }
      },
      orElse: () async => null,
    );
  }
}

@freezed
abstract class PostCreateState with _$PostCreateState {
  const factory PostCreateState.initial() = _Initial;
  const factory PostCreateState.loading() = _Loading;
  const factory PostCreateState.ready({
    required List<ClusterModel> clusters,
    @Default(<AppSingleSelectOption<String>>[])
    List<AppSingleSelectOption<String>> clusterSelectOptions,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _Ready;
  const factory PostCreateState.error({required String message}) = _Error;
}

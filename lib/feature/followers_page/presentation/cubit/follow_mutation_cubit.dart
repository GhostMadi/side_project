import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';

part 'follow_mutation_cubit.freezed.dart';

/// Подписка / отписка на пользователя (RPC `follow_user` / `unfollow_user`).
@injectable
class FollowMutationCubit extends Cubit<FollowMutationState> {
  FollowMutationCubit(this._repository) : super(const FollowMutationState.idle());

  final FollowListRepository _repository;

  Future<void> follow(String targetUserId) async {
    if (isClosed) return;
    emit(const FollowMutationState.inProgress());
    try {
      await _repository.followUser(targetUserId);
      if (isClosed) return;
      emit(const FollowMutationState.success());
    } catch (e) {
      if (isClosed) return;
      emit(FollowMutationState.failure(mapFollowRpcError(e)));
    }
  }

  Future<void> unfollow(String targetUserId) async {
    if (isClosed) return;
    emit(const FollowMutationState.inProgress());
    try {
      await _repository.unfollowUser(targetUserId);
      if (isClosed) return;
      emit(const FollowMutationState.success());
    } catch (e) {
      if (isClosed) return;
      emit(FollowMutationState.failure(mapFollowRpcError(e)));
    }
  }

  void reset() {
    if (isClosed) return;
    emit(const FollowMutationState.idle());
  }
}

@freezed
class FollowMutationState with _$FollowMutationState {
  const factory FollowMutationState.idle() = _FmIdle;
  const factory FollowMutationState.inProgress() = _FmInProgress;
  const factory FollowMutationState.success() = _FmSuccess;
  const factory FollowMutationState.failure(String message) = _FmFailure;
}

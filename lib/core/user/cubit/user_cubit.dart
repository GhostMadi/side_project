import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/user/data/models/user_model.dart';
import 'package:side_project/core/user/domain/repository/user_repository.dart';

part 'user_cubit.freezed.dart';
part 'user_state.dart';

@singleton
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(const UserState.initial());

  Future<void> loadProfile() async {
    try {
      emit(const UserState.loading());
      final user = await _repository.getMyProfile();
      emit(UserState.loaded(user));
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  UserModel? get currentUser {
    return state.maybeWhen(loaded: (user) => user, orElse: () => null);
  }
}

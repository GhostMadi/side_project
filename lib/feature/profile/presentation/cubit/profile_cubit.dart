import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile/data/models/user_stats_model.dart';
import 'package:side_project/feature/profile/domain/repository/profile_repository.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  // Начальное состояние сразу loading, чтобы при открытии крутился спиннер
  ProfileCubit(this._profileRepository) : super(const ProfileState.loading());

  Future<void> loadMyStats() async {
    // 1. Эмитим состояние загрузки (если нужно обновить данные)
    emit(const ProfileState.loading());

    try {
      // 2. Получаем данные
      final stats = await _profileRepository.getMyStats();

      // 3. Эмитим состояние успеха
      emit(ProfileState.loaded(stats));
    } catch (e) {
      // 4. Эмитим состояние ошибки
      emit(ProfileState.error(e.toString()));
    }
  }
} 
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/profile/data/models/profile_model.dart';
import 'package:side_project/core/feature/profile/domain/repository/profile_repository.dart';

part 'profile_cubit.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded(ProfileModel profile) = _Loaded;
  const factory ProfileState.error(String message) = _Error;
}

@singleton
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileState.initial());
  ProfileModel? get currentUser {
    return state.maybeWhen(loaded: (user) => user, orElse: () => null);
  }

  /// Загрузка профиля текущего юзера
  Future<void> loadMyProfile() async {
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getMyProfile();
      emit(ProfileState.loaded(profile));
    } catch (e) {
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Обновление текстовых полей
  Future<void> updateProfileInfo(ProfileModel updatedProfile) async {
    // Оптимистичное обновление или через лоадинг:
    emit(const ProfileState.loading());
    try {
      await _repository.updateProfile(updatedProfile);
      // После успешного обновления эмитим новые данные
      emit(ProfileState.loaded(updatedProfile));
    } catch (e) {
      emit(ProfileState.error(e.toString()));
      // В идеале тут нужно перезагрузить старый профиль, чтобы сбросить UI
      loadMyProfile();
    }
  }

  /// Загрузка новой аватарки
  Future<void> updateAvatar(File imageFile) async {
    final currentState = state;
    if (currentState is! _Loaded) return; // Или загрузить профиль сначала

    emit(const ProfileState.loading());
    try {
      final currentProfile = currentState.profile;

      // 1. Грузим картинку в Storage
      final avatarUrl = await _repository.uploadAvatar(
        imageFile,
        currentProfile.id,
      );

      // 2. Обновляем ссылку в таблице profiles
      final updatedProfile = currentProfile.copyWith(avatarUrl: avatarUrl);
      await _repository.updateProfile(updatedProfile);

      emit(ProfileState.loaded(updatedProfile));
    } catch (e) {
      emit(ProfileState.error('Failed to update avatar: $e'));
    }
  }
}

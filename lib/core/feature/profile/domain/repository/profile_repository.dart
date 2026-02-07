import 'dart:io';

import 'package:side_project/core/feature/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  /// Получить профиль текущего пользователя
  Future<ProfileModel> getMyProfile();

  /// Получить профиль по ID (если нужно смотреть чужие)
  Future<ProfileModel> getProfileById(String userId);

  /// Обновить данные профиля
  Future<void> updateProfile(ProfileModel profile);

  /// Загрузить аватарку и получить публичную ссылку
  Future<String> uploadAvatar(File file, String userId);
}

import 'dart:io';

import 'package:side_project/core/user/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getMyProfile();

  // Мы убрали uploadAvatar, теперь все внутри updateProfile
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? website,
    File? avatarFile, // Сюда можно передать файл, если фото менялось
  });
}

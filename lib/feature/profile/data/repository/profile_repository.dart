import 'dart:typed_data';

import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';

abstract class ProfileRepository {
  /// Публичный профиль по id (совпадает с id пользователя в auth).
  Future<ProfileModel?> getById(String id);

  /// Профиль текущего пользователя.
  Future<ProfileModel?> getCurrentUserProfile();

  /// Частичное обновление полей: `full_name`, `username`, `bio`, `category_code`,
  /// `city_code`, `country_code`, `phone`. Пустые строки → `null`.
  /// Счётчик смены ника и дата паузы выставляются только на сервере.
  Future<ProfileModel?> updateCurrentUserProfile({
    required String fullName,
    required String username,
    required String bio,
    required String categoryCode,
    required String cityCode,
    required String countryCode,
    required String phone,
  });

  /// Сжимает при необходимости до ≤10 MiB, грузит в `avatars`, пишет `avatar_url`.
  Future<ProfileModel?> uploadAvatarImage(Uint8List imageBytes);

  /// Сжимает при необходимости до ≤10 MiB, грузит в `profile_backgrounds`, пишет `background_url`.
  Future<ProfileModel?> uploadBackgroundImage(Uint8List imageBytes);

  /// Удаляет файл в Storage и обнуляет `avatar_url`.
  Future<ProfileModel?> deleteAvatarImage();

  /// Удаляет файл в Storage и обнуляет `background_url`.
  Future<ProfileModel?> deleteBackgroundImage();

  /// Поиск профилей по `username` и `full_name` (ilike, регистр не важен).
  Future<List<ProfileSearchHit>> searchProfilesForTagging({
    required String query,
    int limit = 24,
  });
}

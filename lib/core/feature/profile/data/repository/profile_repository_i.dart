import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/feature/profile/data/models/profile_model.dart';
import 'package:side_project/core/feature/profile/domain/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl(this._supabase);

  @override
  Future<ProfileModel> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    return getProfileById(userId);
  }

  @override
  Future<ProfileModel> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single(); // single() вернет Map, а не List

      return ProfileModel.fromJson(response);
    } catch (e) {
      // Тут можно добавить логирование
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      // Превращаем в JSON, удаляем поля, которые нельзя менять вручную (например, created_at)
      // updated_at обновится триггером в БД
      final data = profile.toJson();
      data.remove('created_at');
      data.remove('updated_at');
      data.remove(
        'email',
      ); // Обычно email меняют через отдельный флоу auth.updateUser

      await _supabase.from('profiles').update(data).eq('id', profile.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Загрузка в бакет 'avatars' (согласно твоему SQL)
      await _supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      // Получение публичной ссылки
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }
}

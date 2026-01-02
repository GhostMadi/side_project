import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:side_project/core/user/data/models/user_model.dart';
import 'package:side_project/core/user/domain/repository/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: UserRepository)
class IUserRepository implements UserRepository {
  final SupabaseClient _supabase;

  IUserRepository(this._supabase);

  @override
  Future<UserModel> getMyProfile() async {
    // ... (ваш старый код получения профиля) ...
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? website,
    File? avatarFile,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      // 1. Готовим "карту" обновлений.
      // Ключ - название колонки в Supabase, Значение - то, что мы хотим записать.
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now()
            .toIso8601String(), // Всегда обновляем дату изменения
        'is_onboarded':
            true, // Если юзер что-то сохранил, считаем его прошедшим онбординг
      };

      // 2. Если передали ТЕКСТОВЫЕ поля, добавляем их в карту
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (website != null) updates['website'] = website;

      // 3. Если передали ФАЙЛ, сначала грузим его, потом добавляем ссылку в карту
      if (avatarFile != null) {
        final fileExt = avatarFile.path.split('.').last;
        final fileName =
            '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Загружаем в Storage
        await _supabase.storage
            .from('avatars')
            .upload(
              fileName,
              avatarFile,
              fileOptions: const FileOptions(upsert: true),
            );

        // Получаем ссылку
        final imageUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);

        // Добавляем ссылку в обновления базы
        updates['avatar_url'] = imageUrl;
      }

      // 4. Если обновлять нечего (все null и файла нет), выходим
      // (хотя у нас там 'updated_at', так что запрос уйдет в любом случае, это норм)

      // 5. Отправляем запрос в базу
      await _supabase.from('users').update(updates).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}

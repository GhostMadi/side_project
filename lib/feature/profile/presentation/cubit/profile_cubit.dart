import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/data/profile_image_compress.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';
import 'package:side_project/feature/profile/presentation/edit_profile_field_keys.dart';

part 'profile_cubit.freezed.dart';

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState.initial());

  final ProfileRepository _repository;

  /// Загрузить профиль текущего пользователя (по сессии Supabase).
  Future<void> loadMyProfile() async {
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getCurrentUserProfile();
      if (profile == null) {
        emit(const ProfileState.error('Профиль не найден'));
        return;
      }
      emit(ProfileState.loaded(profile));
    } catch (e) {
      emit(ProfileState.error('$e'));
    }
  }

  /// Обновить профиль с сервера без перехода в [loading] (актуальные данные на форме редактирования).
  Future<void> refreshMyProfile() async {
    try {
      final profile = await _repository.getCurrentUserProfile();
      if (profile == null) return;
      emit(ProfileState.loaded(profile));
    } catch (_) {
      // сохраняем предыдущий state при ошибке сети
    }
  }

  /// Загрузить любой публичный профиль по id (поиск / чужая карточка).
  Future<void> loadProfile(String userId) async {
    if (userId.isEmpty) {
      emit(const ProfileState.error('Пустой id'));
      return;
    }
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getById(userId);
      if (profile == null) {
        emit(const ProfileState.error('Пользователь не найден'));
        return;
      }
      emit(ProfileState.loaded(profile));
    } catch (e) {
      emit(ProfileState.error('$e'));
    }
  }

  /// Сохранить изменения формы «Редактировать профиль». `null` — успех, иначе текст ошибки.
  Future<String?> saveMyProfile({
    required String fullName,
    required String username,
    required String bio,
    required String categoryCode,
    required String cityCode,
    required String countryCode,
    required String phone,
  }) async {
    final snapshot = state.mapOrNull(loaded: (s) => s.profile);
    if (snapshot == null) {
      return 'Сначала загрузите профиль';
    }
    final nextUser = username.trim();
    final prevUser = snapshot.username?.trim() ?? '';
    if (nextUser != prevUser && !snapshot.canChangeUsername) {
      return 'Пока нельзя изменить ник.';
    }
    try {
      final updated = await _repository.updateCurrentUserProfile(
        fullName: fullName,
        username: username,
        bio: bio,
        categoryCode: categoryCode,
        cityCode: cityCode,
        countryCode: countryCode,
        phone: phone,
      );
      if (updated == null) {
        developer.log('saveMyProfile: repository returned null', name: 'ProfileCubit');
        return 'Не удалось сохранить профиль';
      }
      emit(ProfileState.loaded(updated));
      return null;
    } catch (e, st) {
      developer.log('saveMyProfile: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      return '$e';
    }
  }

  /// Сохранить одно поле (остальные берутся из текущего [ProfileState.loaded]).
  Future<String?> saveProfileField({required String fieldKey, required String value}) async {
    final p = state.mapOrNull(loaded: (s) => s.profile);
    if (p == null) {
      return 'Сначала загрузите профиль';
    }
    return saveMyProfile(
      fullName: fieldKey == EditProfileFieldKeys.fullName ? value : (p.fullName ?? ''),
      username: fieldKey == EditProfileFieldKeys.username ? value : (p.username ?? ''),
      bio: fieldKey == EditProfileFieldKeys.bio ? value : (p.bio ?? ''),
      categoryCode: fieldKey == EditProfileFieldKeys.category ? value : (p.categoryCode?.value ?? ''),
      cityCode: fieldKey == EditProfileFieldKeys.city ? value : (p.cityCode?.cityCode ?? p.citySlug ?? ''),
      countryCode: fieldKey == EditProfileFieldKeys.country ? value : (p.countryCode?.code ?? ''),
      phone: fieldKey == EditProfileFieldKeys.phone ? value : (p.phone ?? ''),
    );
  }

  /// Загрузка аватара в Storage и обновление профиля. `null` — успех, иначе текст ошибки.
  Future<String?> uploadAvatarImage(Uint8List imageBytes) async {
    if (state.mapOrNull(loaded: (_) => true) != true) {
      return 'Сначала загрузите профиль';
    }
    try {
      final updated = await _repository.uploadAvatarImage(imageBytes);
      if (updated == null) {
        return 'Не удалось загрузить аватар';
      }
      emit(ProfileState.loaded(updated));
      return null;
    } on ProfileImageTooLargeException catch (e) {
      return e.toString();
    } catch (e, st) {
      developer.log('uploadAvatarImage: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      return '$e';
    }
  }

  /// Загрузка обложки в Storage и обновление профиля. `null` — успех, иначе текст ошибки.
  Future<String?> uploadBackgroundImage(Uint8List imageBytes) async {
    if (state.mapOrNull(loaded: (_) => true) != true) {
      return 'Сначала загрузите профиль';
    }
    try {
      final updated = await _repository.uploadBackgroundImage(imageBytes);
      if (updated == null) {
        return 'Не удалось загрузить обложку';
      }
      emit(ProfileState.loaded(updated));
      return null;
    } on ProfileImageTooLargeException catch (e) {
      return e.toString();
    } catch (e, st) {
      developer.log('uploadBackgroundImage: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      return '$e';
    }
  }

  /// Удалить аватар (Storage + `avatar_url`).
  Future<String?> deleteAvatarImage() async {
    if (state.mapOrNull(loaded: (_) => true) != true) {
      return 'Сначала загрузите профиль';
    }
    try {
      final updated = await _repository.deleteAvatarImage();
      if (updated == null) {
        return 'Не удалось удалить аватар';
      }
      emit(ProfileState.loaded(updated));
      return null;
    } catch (e, st) {
      developer.log('deleteAvatarImage: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      return '$e';
    }
  }

  /// Удалить обложку (Storage + `background_url`).
  Future<String?> deleteBackgroundImage() async {
    if (state.mapOrNull(loaded: (_) => true) != true) {
      return 'Сначала загрузите профиль';
    }
    try {
      final updated = await _repository.deleteBackgroundImage();
      if (updated == null) {
        return 'Не удалось удалить обложку';
      }
      emit(ProfileState.loaded(updated));
      return null;
    } catch (e, st) {
      developer.log('deleteBackgroundImage: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      return '$e';
    }
  }
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded(ProfileModel profile) = _Loaded;
  const factory ProfileState.error(String message) = _Error;
}

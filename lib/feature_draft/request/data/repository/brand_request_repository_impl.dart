import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:side_project/feature_draft/request/data/models/brand_request_model.dart';
import 'package:side_project/feature_draft/request/domain/repository/brand_request_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: BrandRequestRepository)
class BrandRequestRepositoryImpl implements BrandRequestRepository {
  final SupabaseClient _supabase;

  BrandRequestRepositoryImpl(this._supabase);

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<List<BrandRequestModel>> getMyRequests() async {
    try {
      final response = await _supabase
          .from('brand_requests')
          .select()
          .eq('user_id', _currentUserId)
          .order('created_at', ascending: false);

      return response.map((json) => BrandRequestModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createRequest(BrandRequestModel request) async {
    try {
      final data = request.toJson();
      // Чистим поля перед вставкой
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('moderator_history');
      data.remove('moderator_name');
      // Удаляем user_id, чтобы сработал default auth.uid() в SQL (если ты настроил)
      // Либо можно явно передать: data['user_id'] = _currentUserId;
      data.remove('user_id');

      await _supabase.from('brand_requests').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRequest(BrandRequestModel request) async {
    try {
      final data = request.toJson();

      // Удаляем лишнее, что нельзя менять руками
      data.remove('user_id');
      data.remove('created_at');
      data.remove('updated_at'); // Обновится триггером или само
      data.remove('moderator_history'); // Юзер не правит историю модератора

      // Обязательно меняем статус на 'pending', если юзер внес правки?
      // Обычно если исправляют ошибки, статус сбрасывается на "на проверке".
      // Если нужно, раскомментируй строку ниже:
      // data['status'] = 'pending';

      await _supabase
          .from('brand_requests')
          .update(data)
          .eq('id', request.id); // Ищем по ID заявки
      // RLS гарантирует, что чужую заявку обновить нельзя
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _supabase.from('brand_requests').delete().eq('id', requestId);
      // RLS не даст удалить чужое
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadDocument(File file, String docType) async {
    try {
      final userId = _currentUserId;
      final fileExt = file.path.split('.').last;

      // Генерируем путь: userId/front_timestamp.jpg
      final path =
          '$userId/${docType}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage
          .from('brand_docs')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      // ВАЖНО: Возвращаем ПУТЬ, а не URL.
      // Потому что бакет приватный, publicUrl не сработает.
      return path;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getViewUrl(String path) async {
    // Генерируем временную ссылку (действует 60 секунд или сколько укажешь)
    // Это нужно вызывать в UI (FutureBuilder) или в кубите при маппинге
    return _supabase.storage.from('brand_docs').createSignedUrl(path, 60 * 60);
  }
}

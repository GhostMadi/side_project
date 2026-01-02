import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile/data/models/user_stats_model.dart';
import 'package:side_project/feature/profile/domain/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ProfileRepository)
class IProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  // SupabaseClient сам подтянется из DI, если он зарегистрирован в модуле (см. пункт 5)
  IProfileRepository(this._supabase);

  @override
  Future<UserStatsModel> getMyStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Запрос к таблице user_stats
      final data = await _supabase
          .from('user_stats')
          .select()
          .eq('id', userId)
          .single();

      return UserStatsModel.fromJson(data);
    } catch (e) {
      rethrow; //
    }
  }
}

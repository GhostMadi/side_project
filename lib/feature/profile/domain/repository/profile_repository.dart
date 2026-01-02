import 'package:side_project/feature/profile/data/models/user_stats_model.dart';

abstract class ProfileRepository {
  Future<UserStatsModel> getMyStats();
}

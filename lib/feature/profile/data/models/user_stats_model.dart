import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats_model.freezed.dart';
part 'user_stats_model.g.dart';

@freezed
abstract class UserStatsModel with _$UserStatsModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserStatsModel({
    @Default(0) int followingCount,
    @Default(0) int followersCount,
    @Default(0) int eventersCount,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);
}

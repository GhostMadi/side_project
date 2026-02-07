import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
abstract class ProfileModel with _$ProfileModel {
  // ignore: invalid_annotation_target
  @JsonSerializable(
    fieldRename: FieldRename.snake,
  ) // Авто-маппинг (full_name -> fullName)
  const factory ProfileModel({
    required String id,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

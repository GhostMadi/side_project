import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  // ignore: invalid_annotation_target
  @JsonSerializable(
    fieldRename: FieldRename.snake,
  ) // Автоматически переводит camelCase в snake_case
  const factory UserModel({
    required String id,
    required String email,

    String? username,
    String?
    fullName, // в базе full_name (благодаря аннотации выше сконвертится само)
    String? avatarUrl, // в базе avatar_url
    String? phone,
    String? bio,
    String? website,
    String? fcmToken,

    @Default(false) bool isOnboarded,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

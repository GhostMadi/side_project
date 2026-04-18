import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_profile_mini_model.freezed.dart';
part 'chat_profile_mini_model.g.dart';

@freezed
abstract class ChatProfileMiniModel with _$ChatProfileMiniModel {
  const factory ChatProfileMiniModel({
    required String id,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _ChatProfileMiniModel;

  factory ChatProfileMiniModel.fromJson(Map<String, dynamic> json) => _$ChatProfileMiniModelFromJson(json);
}


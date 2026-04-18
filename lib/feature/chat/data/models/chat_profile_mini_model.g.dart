// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_profile_mini_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatProfileMiniModel _$ChatProfileMiniModelFromJson(
  Map<String, dynamic> json,
) => _ChatProfileMiniModel(
  id: json['id'] as String,
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$ChatProfileMiniModelToJson(
  _ChatProfileMiniModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
};

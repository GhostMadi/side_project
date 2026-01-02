// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) =>
    _UserStatsModel(
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      eventersCount: (json['eventers_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserStatsModelToJson(_UserStatsModel instance) =>
    <String, dynamic>{
      'following_count': instance.followingCount,
      'followers_count': instance.followersCount,
      'eventers_count': instance.eventersCount,
    };

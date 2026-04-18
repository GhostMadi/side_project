import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_follow_row.freezed.dart';

/// Строка из RPC `list_profile_followers` / `list_profile_following`.
@freezed
abstract class ProfileFollowRow with _$ProfileFollowRow {
  const factory ProfileFollowRow({
    required String profileId,
    String? username,
    String? avatarUrl,
  }) = _ProfileFollowRow;

  factory ProfileFollowRow.fromRpc(Map<String, dynamic> json) {
    return ProfileFollowRow(
      profileId: json['profile_id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

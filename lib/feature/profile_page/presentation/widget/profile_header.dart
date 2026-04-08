import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_bio_location.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_actions.dart'
    show ProfileCreateContentKind, ProfileHeaderActionRow;
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_shimmer.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_square_cover.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_stats_row.dart';

/// Хедер профиля: обложка, аватар, статистика, текстовый блок, био, локация, кнопки.
///
/// Секции вынесены в `profile_header/` для расширения без раздувания одного файла.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.isLoading = false,
    this.username,
    this.fullName,
    this.category,
    this.location,
    this.bio,
    this.coverImageUrl,
    this.avatarImageUrl,
    this.statFollowers = '0',
    this.statFollowing = '0',
    this.statThird = '0',
    this.statThirdLabel = 'Коллекции',
    this.onEditProfile,
    this.onMessage,
    this.onCreateContent,
    this.informer,
  });

  final bool isLoading;
  final String? username;
  final String? fullName;
  final String? category;
  final String? location;
  final String? bio;
  final String? coverImageUrl;
  final String? avatarImageUrl;
  final String statFollowers;
  final String statFollowing;
  final String statThird;
  final String statThirdLabel;
  final VoidCallback? onEditProfile;
  final VoidCallback? onMessage;
  final ValueChanged<ProfileCreateContentKind>? onCreateContent;
  final Widget? informer;

  const ProfileHeader.loading({super.key})
    : isLoading = true,
      username = null,
      fullName = null,
      category = null,
      location = null,
      bio = null,
      coverImageUrl = null,
      avatarImageUrl = null,
      statFollowers = '0',
      statFollowing = '0',
      statThird = '0',
      statThirdLabel = 'Коллекции',
      onEditProfile = null,
      onMessage = null,
      onCreateContent = null,
      informer = null;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ProfileHeaderShimmer();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coverImageUrl != null && coverImageUrl!.trim().isNotEmpty)
          ProfileHeaderSquareCover(imageUrl: coverImageUrl!.trim()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileHeaderAvatar(imageUrl: avatarImageUrl),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProfileHeaderStatItem(value: statFollowers, label: 'Подписчики'),
                        ProfileHeaderStatItem(value: statFollowing, label: 'Подписки'),
                        ProfileHeaderStatItem(value: statThird, label: statThirdLabel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileHeaderIdentity(fullName: fullName, username: username, category: category),
              if (bio != null && bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                ProfileHeaderExpandableBio(text: bio!.trim()),
              ],
              if (location != null && location!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                ProfileHeaderLocationRow(location: location!.trim()),
              ],
              if (informer != null) ...[const SizedBox(height: 16), informer!],
              const SizedBox(height: 16),
              ProfileHeaderActionRow(
                onEditProfile: onEditProfile ?? () => context.router.root.push(const EditProfileRoute()),
                onMessage: onMessage,
                onCreateContent: onCreateContent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

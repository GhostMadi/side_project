import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_informer.dart';
import 'package:side_project/feature/cluster/presentation/widget/owner_clusters_strip.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_list_view.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_formatting.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header/profile_header_actions.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_posts_tab_bar.dart';

/// Контент профиля после загрузки: хедер, кластеры из Supabase, сетка постов.
class ProfileLoadedBody extends StatelessWidget {
  const ProfileLoadedBody({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeaderFromModel(profile: profile),
        OwnerClustersStrip(ownerId: profile.id),
        const ProfilePostsTabBar(),
        PostsListView(
          onPostTap: (post) async {
            final initialSaved = context.read<PostsListCubit>().state.maybeWhen(
                  loaded: (_, __, savedByPostId, _, _, _, _) => savedByPostId[post.id],
                  orElse: () => null,
                );
            final deleted = await context.router.push<bool>(
              PostDetailRoute(post: post, initialIsSaved: initialSaved),
            );
            if (deleted == true && context.mounted) {
              context.read<PostsListCubit>().reloadKeepingFilter();
            }
          },
        ),
      ],
    );
  }
}

/// Сборка [ProfileHeader] из [ProfileModel] — одна точка для расширения (бейджи, кнопки и т.д.).
class _ProfileHeaderFromModel extends StatelessWidget {
  const _ProfileHeaderFromModel({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final rawUsername = profile.username?.trim();
    final usernameForHeader = rawUsername != null && rawUsername.isNotEmpty ? rawUsername : null;
    final needsUsername = usernameForHeader == null;

    final rawName = profile.fullName?.trim();
    final fullNameDisplay = rawName != null && rawName.isNotEmpty ? rawName : null;

    final categoryDisplay = profile.categoryCode?.labelRu;

    final location = ProfilePageFormatting.locationLine(profile);
    final locationDisplay = location.trim().isEmpty ? null : location;

    final rawBio = profile.bio?.trim();
    final bioDisplay = rawBio != null && rawBio.isNotEmpty ? rawBio : null;

    return ProfileHeader(
      username: usernameForHeader,
      fullName: fullNameDisplay,
      category: categoryDisplay,
      location: locationDisplay,
      bio: bioDisplay,
      coverImageUrl: profile.backgroundUrl,
      avatarImageUrl: profile.avatarUrl,
      statFollowers: ProfilePageFormatting.statString(profile.followersCount),
      statFollowing: ProfilePageFormatting.statString(profile.followingCount),
      statThird: ProfilePageFormatting.statString(profile.postCount),
      statThirdLabel: 'Публикации',
      statFourth: ProfilePageFormatting.statString(profile.clusterCount),
      statFourthLabel: 'Коллекции',
      onFollowersTap: () => context.router.root.push(
        FollowListsRoute(profileId: profile.id, username: usernameForHeader, initialTabIndex: 0),
      ),
      onFollowingTap: () => context.router.root.push(
        FollowListsRoute(profileId: profile.id, username: usernameForHeader, initialTabIndex: 1),
      ),
      onMessage: () => context.router.root.push(const SettingsRoute()),
      onCreateContent: (kind) {
        switch (kind) {
          case ProfileCreateContentKind.cluster:
            context.router.root.push(const ClusterCreateRoute());
            break;
          case ProfileCreateContentKind.post:
            context.router.root.push(PostCreateRoute());
            break;
        }
      },
      onEditProfile: () => context.router.root.push(const EditProfileRoute()),
      informer: needsUsername
          ? AppInformer(
              title: 'Никнейм не указан',
              message: 'Добавьте никнейм — так вас проще найти в приложении.',
              actionLabel: 'Указать ник',
              onAction: () => context.router.push(const EditProfileRoute()),
              leading: Icon(Icons.alternate_email_rounded, color: AppColors.primary, size: 22),
            )
          : null,
    );
  }
}

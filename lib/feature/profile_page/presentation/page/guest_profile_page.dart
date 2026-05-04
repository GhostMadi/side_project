import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/storage/prefs/profile_follow_status_prefs_storage.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:side_project/feature/cluster/presentation/cubit/clusters_list_cubit.dart';
import 'package:side_project/feature/cluster/presentation/widget/clusters_strip_shimmer.dart';
import 'package:side_project/feature/cluster/presentation/widget/owner_clusters_strip.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:side_project/feature/followers_page/presentation/cubit/follow_mutation_cubit.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_list_view.dart';
import 'package:side_project/feature/profile/data/models/profile_model.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_marker_linked_posts_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_markers_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_error_top.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_formatting.dart';
import 'package:side_project/feature/profile_page/presentation/page/profile_page_scroll_shell.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_header.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_marked_posts_grid.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_posts_tab_bar.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_posts_tab_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Профиль гостя (чужой профиль): без настроек/создания/редактирования, только подписка.
@RoutePage()
class GuestProfilePage extends StatefulWidget {
  const GuestProfilePage({super.key, required this.profileId});

  final String profileId;

  @override
  State<GuestProfilePage> createState() => _GuestProfilePageState();
}

class _GuestProfilePageState extends State<GuestProfilePage> {
  final ValueNotifier<bool> _refreshingVisual = ValueNotifier(false);
  late final ClustersListCubit _clustersCubit;
  late final PostsListCubit _postsCubit;
  late final ProfileMarkersCubit _markersCubit;
  late final ProfileMarkerLinkedPostsCubit _markerLinkedCubit;
  bool? _isFollowing;
  int _tabIndex = 0;

  String get _profileId => widget.profileId.trim();

  @override
  void initState() {
    super.initState();
    _clustersCubit = sl<ClustersListCubit>();
    _postsCubit = sl<PostsListCubit>();
    _markersCubit = sl<ProfileMarkersCubit>();
    _markerLinkedCubit = sl<ProfileMarkerLinkedPostsCubit>();

    final id = _profileId;
    if (id.isNotEmpty) {
      _clustersCubit.load(id);
      _postsCubit.loadUserFeed(id);
      _markersCubit.load(id);
      _markerLinkedCubit.load(id);
    }

    // Сразу: статус из локального кэша.
    unawaited(() async {
      final myId = Supabase.instance.client.auth.currentUser?.id;
      if (myId == null || myId.isEmpty) return;
      final cached = await sl<ProfileFollowStatusPrefsStorage>().readCachedForTarget(myId, id);
      if (!mounted) return;
      if (cached != null) setState(() => _isFollowing = cached);
    }());

    // Догрузка с сервера (один RPC) — обновит кэш.
    unawaited(() async {
      final myId = Supabase.instance.client.auth.currentUser?.id;
      if (myId == null || myId.isEmpty) return;
      try {
        final v = await sl<FollowListRepository>().isFollowing(id);
        await sl<ProfileFollowStatusPrefsStorage>().setCached(myId, id, v);
        if (!mounted) return;
        setState(() => _isFollowing = v);
      } catch (_) {}
    }());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileCubit>().loadProfile(id);
    });
  }

  @override
  void dispose() {
    _refreshingVisual.dispose();
    _clustersCubit.close();
    _postsCubit.close();
    _markersCubit.close();
    _markerLinkedCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<ProfileCubit>();
    final id = _profileId;
    if (id.isEmpty) return;

    _refreshingVisual.value = true;
    try {
      _clustersCubit.load(id);
      _postsCubit.loadUserFeed(id);
      _markersCubit.load(id);
      _markerLinkedCubit.reload();
      await cubit.loadProfile(id);
    } finally {
      if (mounted) _refreshingVisual.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom + 88;
    final id = _profileId;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      extendBody: true,
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _clustersCubit),
          BlocProvider.value(value: _postsCubit),
          BlocProvider.value(value: _markersCubit),
          BlocProvider.value(value: _markerLinkedCubit),
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                header: const _GuestProfileLoadingBody(),
              ),
              loading: (_) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                header: const _GuestProfileLoadingBody(),
              ),
              error: (e) => ProfilePageScrollShell(
                bottomPad: bottomPad,
                onRefresh: _onRefresh,
                top: ProfilePageErrorTop(message: e.message),
                header: const _GuestProfileLoadingBody(),
              ),
              loaded: (s) => ListenableBuilder(
                listenable: _refreshingVisual,
                builder: (context, _) {
                  return ProfilePageScrollShell(
                    bottomPad: bottomPad,
                    onRefresh: _onRefresh,
                    header: _refreshingVisual.value
                        ? const _GuestProfileLoadingBody()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GuestProfileLoadedBody(
                                profile: s.profile,
                                initialIsFollowing: _isFollowing,
                                onFollowChanged: (v) => setState(() => _isFollowing = v),
                                targetProfileId: id,
                              ),
                              OwnerClustersStrip(ownerId: id),
                              ProfilePostsTabBar(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                              ProfilePostsTabContent(
                                index: _tabIndex,
                                onIndexChanged: (i) => setState(() => _tabIndex = i),
                                posts: PostsListView(
                                  onPostTap: (post) async {
                                    final initialSaved = context.read<PostsListCubit>().state.maybeWhen(
                                      loaded: (_, __, savedByPostId, _, _, _, _) =>
                                          savedByPostId[post.id],
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
                                markers: const ProfileMarkedPostsGrid(key: ValueKey('marked_posts')),
                              ),
                            ],
                          ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GuestProfileLoadingBody extends StatelessWidget {
  const _GuestProfileLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeader.loading(),
        SizedBox(height: 6),
        Padding(padding: EdgeInsets.only(bottom: 8), child: ClustersStripShimmer()),
      ],
    );
  }
}

/// Версия `ProfileLoadedBody`, но с кастомным action-row: только подписка.
class GuestProfileLoadedBody extends StatelessWidget {
  const GuestProfileLoadedBody({
    super.key,
    required this.profile,
    required this.targetProfileId,
    required this.initialIsFollowing,
    required this.onFollowChanged,
  });

  final ProfileModel profile;
  final String targetProfileId;
  final bool? initialIsFollowing;
  final ValueChanged<bool> onFollowChanged;

  @override
  Widget build(BuildContext context) {
    final username = profile.username?.trim();
    final fullName = profile.fullName?.trim();
    final category = profile.categoryCode?.labelRu.trim();
    final location = ProfilePageFormatting.locationLine(profile).trim();

    final coverUrl = profile.backgroundUrl;
    final avatarUrl = profile.avatarUrl;

    final followersCount = profile.followersCount;
    final followingCount = profile.followingCount;
    final postCount = profile.postCount;
    final clusterCount = profile.clusterCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeader(
          username: (username != null && username.isNotEmpty) ? username : null,
          fullName: (fullName != null && fullName.isNotEmpty) ? fullName : null,
          category: (category != null && category.isNotEmpty) ? category : null,
          location: location.isEmpty ? null : location,
          bio: profile.bio?.trim(),
          coverImageUrl: coverUrl,
          avatarImageUrl: avatarUrl,
          statFollowers: ProfilePageFormatting.statString(followersCount),
          statFollowing: ProfilePageFormatting.statString(followingCount),
          statThird: ProfilePageFormatting.statString(postCount),
          statThirdLabel: 'Публикации',
          statFourth: ProfilePageFormatting.statString(clusterCount),
          statFourthLabel: 'Коллекции',
          informer: null,
          onFollowersTap: () => context.router.root.push(
            FollowListsRoute(profileId: targetProfileId, username: username, initialTabIndex: 0),
          ),
          onFollowingTap: () => context.router.root.push(
            FollowListsRoute(profileId: targetProfileId, username: username, initialTabIndex: 1),
          ),
          actionsRow: _GuestFollowActionsRow(
            targetProfileId: targetProfileId,
            initialIsFollowing: initialIsFollowing,
            onChanged: onFollowChanged,
          ),
        ),
        // Остальное (кластеры/посты) идёт ниже через `ProfilePageScrollShell` и кубиты.
      ],
    );
  }
}

class _GuestFollowActionsRow extends StatelessWidget {
  const _GuestFollowActionsRow({
    required this.targetProfileId,
    required this.initialIsFollowing,
    required this.onChanged,
  });

  final String targetProfileId;
  final bool? initialIsFollowing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    final isSelf = myId != null && myId == targetProfileId;
    if (isSelf) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<FollowMutationCubit>(),
      child: BlocConsumer<FollowMutationCubit, FollowMutationState>(
        listener: (context, state) async {
          state.whenOrNull(
            success: () async {
              final uid = Supabase.instance.client.auth.currentUser?.id;
              final was = initialIsFollowing ?? false;
              final next = !was;
              if (uid != null && uid.isNotEmpty) {
                await sl<ProfileFollowStatusPrefsStorage>().setCached(uid, targetProfileId, next);
              }
              onChanged(next);
              if (context.mounted) context.read<FollowMutationCubit>().reset();
            },
            failure: (msg) {
              AppSnackBar.show(context, message: msg, kind: AppSnackBarKind.error);
              context.read<FollowMutationCubit>().reset();
            },
          );
        },
        builder: (context, state) {
          final busy = state.maybeWhen(inProgress: () => true, orElse: () => false);
          final isFollowing = initialIsFollowing ?? false;
          final label = initialIsFollowing == null ? '...' : (isFollowing ? 'Отписаться' : 'Подписаться');

          return SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: (busy || initialIsFollowing == null)
                        ? null
                        : () {
                            final cubit = context.read<FollowMutationCubit>();
                            if (isFollowing) {
                              cubit.unfollow(targetProfileId);
                            } else {
                              cubit.follow(targetProfileId);
                            }
                          },
                    style: TextButton.styleFrom(
                      backgroundColor: isFollowing ? AppColors.inputBackground : AppColors.primary,
                      foregroundColor: isFollowing ? AppColors.textColor : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(label),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    // Открыть/создать DM и перейти в тред.
                    try {
                      final repo = sl<ChatRepository>();
                      final cid = await repo.createDm(targetProfileId);
                      if (!context.mounted) return;
                      context.router.root.push(ChatThreadRoute(conversationId: cid));
                    } catch (_) {
                      // ignore: empty catch (ui best-effort)
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppColors.border.withValues(alpha: 0.55)),
                    ),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

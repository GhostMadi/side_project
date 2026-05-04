import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_action_sheet.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_pill_navigation_bar.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_overflow_menu.dart';
import 'package:side_project/feature/archive_page/presentation/cubit/archived_posts_cubit.dart';
import 'package:side_project/feature/archive_page/presentation/cubit/archived_markers_cubit.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
import 'package:side_project/feature/cluster/presentation/cluster_list_refresh.dart';
import 'package:side_project/feature/cluster/presentation/cubit/archived_clusters_cubit.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/models/post_linked_marker_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';
import 'package:side_project/core/shared/media_widget.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ArchivedSection { clusters, posts, markers }

@RoutePage()
class ArchivedPage extends StatefulWidget {
  const ArchivedPage({super.key});

  @override
  State<ArchivedPage> createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  final ValueNotifier<ArchivedSection> _section = ValueNotifier(ArchivedSection.clusters);

  @override
  void dispose() {
    _section.dispose();
    super.dispose();
  }

  Future<void> _openSectionPickerSheet() async {
    await AppBottomSheet.show<void>(
      context: context,
      title: 'Раздел архива',
      upperCaseTitle: false,
      contentBottomSpacing: 16,
      content: Builder(
        builder: (sheetContext) {
          return ValueListenableBuilder<ArchivedSection>(
            valueListenable: _section,
            builder: (context, current, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.folder_outlined, color: AppColors.primary, size: 22),
                    title: Text(
                      'Кластеры',
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                    trailing: current == ArchivedSection.clusters
                        ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
                        : null,
                    onTap: () {
                      _section.value = ArchivedSection.clusters;
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.grid_on_rounded, color: AppColors.primary, size: 22),
                    title: Text(
                      'Посты',
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                    trailing: current == ArchivedSection.posts
                        ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
                        : null,
                    onTap: () {
                      _section.value = ArchivedSection.posts;
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    title: Text(
                      'Маркеры',
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                    trailing: current == ArchivedSection.markers
                        ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
                        : null,
                    onTap: () {
                      _section.value = ArchivedSection.markers;
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _archivedPillNavShell({required Widget child}) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomSafe + 88),
          child: child,
        ),
        Positioned(
          left: 100,
          right: 100,
          bottom: bottomSafe + 10,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppPillNavigationBar(
                  height: 66,
                  items: [
                    AppPillNavItem(
                      icon: AppIcons.back.icon,
                      label: 'Назад',
                      onTap: () => context.router.maybePop(),
                    ),
                    AppPillNavItem(
                      icon: Icons.layers_outlined,
                      label: 'Раздел',
                      onTap: () => unawaited(_openSectionPickerSheet()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        automaticallyImplyLeading: false,
        title: Text('Архив', style: AppTextStyle.base(19, fontWeight: FontWeight.w700)),
      ),
      body: _archivedPillNavShell(
        child: uid == null
            ? Center(
                child: Text(
                  'Нужно войти в аккаунт',
                  style: AppTextStyle.base(14, color: AppColors.subTextColor),
                ),
              )
            : ValueListenableBuilder<ArchivedSection>(
                valueListenable: _section,
                builder: (context, s, _) {
                  if (s == ArchivedSection.posts) {
                    return const _ArchivedPostsList();
                  }
                  if (s == ArchivedSection.markers) {
                    return const _ArchivedMarkersList();
                  }
                  return _ArchivedClustersList(ownerId: uid);
                },
              ),
      ),
    );
  }
}

class _ArchivedMarkersList extends StatefulWidget {
  const _ArchivedMarkersList();

  @override
  State<_ArchivedMarkersList> createState() => _ArchivedMarkersListState();
}

class _ArchivedMarkersListState extends State<_ArchivedMarkersList> {
  late final ArchivedMarkersCubit _cubit;
  late final _posts = sl<PostsRepository>();
  String _prefetchSig = '';
  Map<String, PostModel> _postById = const {};

  @override
  void initState() {
    super.initState();
    _cubit = sl<ArchivedMarkersCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _prefetchFor(List<ProfileMarkerModel> markers) async {
    final ids = <String>[
      for (final m in markers)
        if (m.postId != null && m.postId!.trim().isNotEmpty) m.postId!.trim(),
    ];
    ids.sort();
    final sig = ids.join('|');
    if (sig.isEmpty || sig == _prefetchSig) return;
    _prefetchSig = sig;

    await _posts.prefetchPostsByIds(ids);
    if (!mounted) return;
    final map = <String, PostModel>{};
    for (final id in ids) {
      final p = _posts.getCachedPostById(id);
      if (p != null) map[id] = p;
    }
    setState(() => _postById = map);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ArchivedMarkersCubit, ArchivedMarkersState>(
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.maxScrollExtent <= 0) return false;
              final remaining = n.metrics.maxScrollExtent - n.metrics.pixels;
              if (remaining < 600) {
                context.read<ArchivedMarkersCubit>().loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ArchivedMarkersCubit>().refresh(),
              child: state.map(
                initial: (_) => const Center(child: AppCircularProgressIndicator(dimension: 36)),
                loading: (_) => const Center(child: AppCircularProgressIndicator(dimension: 36)),
                error: (e) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      e.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  ),
                ),
                loaded: (s) {
                  unawaited(_prefetchFor(s.items));
                  if (s.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        const SizedBox(height: 64),
                        Icon(Icons.archive_outlined, size: 56, color: AppColors.subTextColor.withValues(alpha: 0.65)),
                        const SizedBox(height: 16),
                        Text(
                          'Нет архивных маркеров',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.base(17, fontWeight: FontWeight.w600, color: AppColors.textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Архивированные события будут появляться здесь.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.45),
                        ),
                      ],
                    );
                  }
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8),
                        sliver: SliverToBoxAdapter(
                          child: _MarkerGrid(
                            markers: s.items,
                            childForMarker: (m) {
                              final pid = m.postId?.trim();
                              final Widget child;
                              if (pid == null || pid.isEmpty) {
                                child = _MarkerNullPostTile(marker: m);
                              } else {
                                final post = _postById[pid];
                                child = post != null ? _ArchivedMarkerPostTile(marker: m, post: post) : const _MarkerCellShimmer();
                              }
                              return _ArchivedMarkerTileShell(marker: m, child: child);
                            },
                            bottomExtra: s.isLoadingMore && s.hasMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArchivedMarkerTileShell extends StatelessWidget {
  const _ArchivedMarkerTileShell({required this.marker, required this.child});

  final ProfileMarkerModel marker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: 6,
          right: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppOverflowMenu<String>(
              iconColor: AppColors.textInverse,
              items: const [
                AppOverflowMenuItem(
                  value: 'unarchive',
                  title: 'Разархивировать',
                  icon: Icons.unarchive_outlined,
                ),
                AppOverflowMenuItem(
                  value: 'delete',
                  title: 'Удалить',
                  icon: Icons.delete_outline_rounded,
                  titleColor: AppColors.destructive,
                  iconColor: AppColors.destructive,
                ),
              ],
              onSelected: (v) async {
                if (v == 'unarchive') {
                  await context.read<ArchivedMarkersCubit>().unarchiveMarker(marker.id);
                  if (!context.mounted) return;
                  AppSnackBar.show(context, message: 'Маркер разархивирован', kind: AppSnackBarKind.success);
                  return;
                }
                if (v == 'delete') {
                  final ok = await AppDialog.showConfirm(
                    context: context,
                    title: 'Удалить маркер?',
                    message: 'Маркер будет удалён навсегда. Это действие нельзя отменить.',
                    confirmLabel: 'Удалить',
                    confirmIsDestructive: true,
                  );
                  if (ok != true || !context.mounted) return;
                  await context.read<ArchivedMarkersCubit>().deleteMarker(marker.id);
                  if (!context.mounted) return;
                  AppSnackBar.show(context, message: 'Маркер удалён', kind: AppSnackBarKind.success);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerGrid extends StatelessWidget {
  const _MarkerGrid({required this.markers, required this.childForMarker, this.bottomExtra});

  final List<ProfileMarkerModel> markers;
  final Widget Function(ProfileMarkerModel m) childForMarker;
  final Widget? bottomExtra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [
          for (final m in markers)
            StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: childForMarker(m)),
          if (bottomExtra != null)
            StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 1, child: bottomExtra!),
        ],
      ),
    );
  }
}

class _MarkerCellShimmer extends StatelessWidget {
  const _MarkerCellShimmer();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kPostHeroRadiusCollapsed),
      child: const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: AppColors.surfaceSoft),
            Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          ],
        ),
      ),
    );
  }
}

class _ArchivedMarkerPostTile extends StatelessWidget {
  const _ArchivedMarkerPostTile({required this.marker, required this.post});

  final ProfileMarkerModel marker;
  final PostModel post;

  static const _radius = kPostHeroRadiusCollapsed;

  PostModel _seedMarkerIntoPost() {
    // В архиве маркеров мы 100% знаем, что маркер архивный.
    // Подмешиваем это в начальный `post`, чтобы меню действий сразу показывало "Разархивировать",
    // даже если сеть/кубит ещё не успели догрузить marker payload.
    return post.copyWith(
      markerId: marker.id,
      marker: PostLinkedMarker(
        id: marker.id,
        textEmoji: marker.textEmoji,
        addressText: marker.addressText,
        isArchived: true,
        eventTime: marker.eventTime,
        endTime: marker.endTime,
        status: marker.status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = post.media.isNotEmpty ? post.media.first : null;
    final seeded = _seedMarkerIntoPost();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: AppColors.surfaceSoft,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => context.router.push(PostDetailRoute(post: seeded)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: buildPostHero(
                  postId: post.id,
                  child: first == null
                      ? const PostMediaFramePlaceholder(shimmer: true)
                      : SizedBox.expand(
                          child: MediaWidget.previewTile(
                            url: first.url,
                            treatAsVideoFromModel: first.treatsAsVideoTile,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerNullPostTile extends StatelessWidget {
  const _MarkerNullPostTile({required this.marker});

  final ProfileMarkerModel marker;

  static const _radius = kPostHeroRadiusCollapsed;

  @override
  Widget build(BuildContext context) {
    final emoji = marker.textEmoji?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: AppColors.surfaceSoft,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => context.router.push(
            MarkerWithoutPostRoute(
              markerId: marker.id,
              textEmoji: marker.textEmoji,
              title: marker.addressText,
              eventTimeIso: marker.eventTime.toIso8601String(),
              endTimeIso: marker.endTime.toIso8601String(),
              status: marker.status,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const PostMediaFramePlaceholder(shimmer: false),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    (emoji == null || emoji.isEmpty) ? '📍' : emoji,
                    style: AppTextStyle.base(28, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedPostsList extends StatefulWidget {
  const _ArchivedPostsList();

  @override
  State<_ArchivedPostsList> createState() => _ArchivedPostsListState();
}

class _ArchivedPostsListState extends State<_ArchivedPostsList> {
  late final ArchivedPostsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ArchivedPostsCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _onPostTap(PostModel post) async {
    await context.router.push(PostDetailRoute(post: post));
    if (!mounted) return;
    try {
      await _cubit.refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ArchivedPostsCubit, ArchivedPostsState>(
        builder: (context, state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.maxScrollExtent <= 0) return false;
              final remaining = n.metrics.maxScrollExtent - n.metrics.pixels;
              if (remaining < 600) {
                context.read<ArchivedPostsCubit>().loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ArchivedPostsCubit>().refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: state.when(
                  initial: () => [_archivedPostsLoadingSliver()],
                  loading: () => [_archivedPostsLoadingSliver()],
                  loaded: (items, _, isLoadingMore) {
                    if (items.isEmpty) {
                      return [_archivedPostsEmptySliver()];
                    }
                    return [
                      SliverToBoxAdapter(
                        child: PostsSection(posts: items, onPostTap: _onPostTap),
                      ),
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppCircularProgressIndicator(dimension: 28)),
                          ),
                        ),
                    ];
                  },
                  error: (m) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ArchivedPostsErrorBody(
                        message: m,
                        onRetry: () => context.read<ArchivedPostsCubit>().load(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _archivedPostsLoadingSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppCircularProgressIndicator(dimension: 36),
              const SizedBox(height: 16),
              Text(
                'Загрузка постов…',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _archivedPostsEmptySliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.archive_outlined, size: 56, color: AppColors.subTextColor.withValues(alpha: 0.65)),
              const SizedBox(height: 16),
              Text(
                'Нет архивных постов',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(17, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Посты из профиля можно спрятать в архив — они появятся здесь.',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedPostsErrorBody extends StatelessWidget {
  const _ArchivedPostsErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.subTextColor.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text(
            'Не удалось загрузить',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
            ),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _ArchivedClustersList extends StatefulWidget {
  const _ArchivedClustersList({required this.ownerId});

  final String ownerId;

  @override
  State<_ArchivedClustersList> createState() => _ArchivedClustersListState();
}

class _ArchivedClustersListState extends State<_ArchivedClustersList> {
  late final ArchivedClustersCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ArchivedClustersCubit>();
    _cubit.load(widget.ownerId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _reload() async {
    await _cubit.load(widget.ownerId);
  }

  Future<void> _unarchiveCluster(ClusterModel cluster) async {
    final ok = await AppDialog.showConfirm(
      context: context,
      title: 'Разархивировать кластер?',
      message: 'Он вернётся в профиль.',
      confirmLabel: 'Разархивировать',
      upperCaseTitle: false,
    );
    if (ok != true || !mounted) return;

    try {
      await sl<ClusterRepository>().unarchiveCluster(clusterId: cluster.id);
      clusterListRefreshTick.value++;
      unawaited(sl<ProfileCubit>().refreshMyProfile());
      await _reload();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Кластер разархивирован', kind: AppSnackBarKind.success);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
    }
  }

  Future<void> _deleteCluster(ClusterModel cluster) async {
    final ok = await AppDialog.showConfirm(
      context: context,
      title: 'Удалить кластер?',
      message: 'Обложка тоже будет удалена.',
      confirmLabel: 'Удалить',
      confirmIsDestructive: true,
      upperCaseTitle: false,
    );
    if (ok != true || !mounted) return;

    try {
      await sl<ClusterRepository>().deleteCluster(clusterId: cluster.id);
      clusterListRefreshTick.value++;
      unawaited(sl<ProfileCubit>().refreshMyProfile());
      await _reload();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Кластер удалён', kind: AppSnackBarKind.success);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ArchivedClustersCubit, ArchivedClustersState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Padding(padding: EdgeInsets.only(top: 8), child: _ArchivedClustersShimmer()),
            error: (m) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  m,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.base(14, color: AppColors.subTextColor),
                ),
              ),
            ),
            loaded: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Архив пуст',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _ArchivedClusterTile(
                  cluster: items[i],
                  onUnarchive: () => _unarchiveCluster(items[i]),
                  onDelete: () => _deleteCluster(items[i]),
                  onEdit: () {
                    AppSnackBar.show(
                      context,
                      message: 'Редактирование подключим следующим шагом',
                      kind: AppSnackBarKind.info,
                    );
                  },
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _ArchivedClustersShimmer extends StatelessWidget {
  const _ArchivedClustersShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, _) {
          return Container(
            height: 82,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
          );
        },
      ),
    );
  }
}

class _ArchivedClusterTile extends StatelessWidget {
  const _ArchivedClusterTile({
    required this.cluster,
    required this.onEdit,
    required this.onUnarchive,
    required this.onDelete,
  });

  final ClusterModel cluster;
  final VoidCallback onEdit;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = cluster.title.trim().isEmpty ? 'Кластер' : cluster.title.trim();
    final sub = cluster.subtitle?.trim();
    final url = cluster.coverUrl?.trim();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                  image: (url != null && url.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                      : null,
                ),
                child: (url == null || url.isEmpty)
                    ? Icon(Icons.folder_outlined, color: AppColors.subTextColor.withValues(alpha: 0.65))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(15, fontWeight: FontWeight.w700),
                    ),
                    if (sub != null && sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(13, color: AppColors.subTextColor),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      cluster.postsCountLabel,
                      style: AppTextStyle.base(12, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: AppActionSheet<String>(
            title: 'Действия',
            items: const [
              AppActionSheetItem(value: 'edit', label: 'Редактировать', icon: Icons.edit_outlined),
              AppActionSheetItem(
                value: 'unarchive',
                label: 'Разархивировать',
                icon: Icons.unarchive_outlined,
              ),
              AppActionSheetItem(
                value: 'delete',
                label: 'Удалить',
                icon: Icons.delete_outline,
                isDestructive: true,
              ),
            ],
            onSelected: (v) {
              if (v == 'delete') return onDelete();
              if (v == 'unarchive') return onUnarchive();
              return onEdit();
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.more_vert_rounded, color: Colors.black.withValues(alpha: 0.65), size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

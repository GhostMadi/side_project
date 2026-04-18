import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/shared/app_action_sheet.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
import 'package:side_project/feature/cluster/presentation/cluster_list_refresh.dart';
import 'package:side_project/feature/cluster/presentation/cubit/clusters_list_cubit.dart';
import 'package:side_project/feature/cluster/presentation/widget/clusters_strip_shimmer.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/widget/profile_collection_card.dart';

/// Горизонтальный список кластеров владельца из Supabase.
///
/// Пустой список и состояния до успешной загрузки — [SizedBox.shrink].
/// [leading] — опционально виджет перед списком (например баннер).
class OwnerClustersStrip extends StatefulWidget {
  const OwnerClustersStrip({
    super.key,
    required this.ownerId,
    this.leading,
    this.selectedClusterId,
    this.onClusterTap,
  });

  final String ownerId;

  /// Вставляется перед кластерами с API.
  final Widget? leading;

  final String? selectedClusterId;
  final ValueChanged<ClusterModel>? onClusterTap;

  @override
  State<OwnerClustersStrip> createState() => _OwnerClustersStripState();
}

class _OwnerClustersStripState extends State<OwnerClustersStrip> {
  int _lastRefreshTick = 0;
  bool _reloadScheduled = false;

  @override
  void initState() {
    super.initState();
    _lastRefreshTick = clusterListRefreshTick.value;
    clusterListRefreshTick.addListener(_onGlobalRefreshTick);
  }

  @override
  void didUpdateWidget(covariant OwnerClustersStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      context.read<ClustersListCubit>().load(widget.ownerId);
    }
  }

  @override
  void dispose() {
    clusterListRefreshTick.removeListener(_onGlobalRefreshTick);
    super.dispose();
  }

  void _onGlobalRefreshTick() {
    final now = clusterListRefreshTick.value;
    if (now == _lastRefreshTick) return;
    _lastRefreshTick = now;
    if (_reloadScheduled) return;
    _reloadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadScheduled = false;
      if (!mounted) return;
      context.read<ClustersListCubit>().load(widget.ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClustersListCubit, ClustersListState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Padding(padding: EdgeInsets.only(bottom: 8), child: ClustersStripShimmer()),
          loaded: (items) {
            final hasLeading = widget.leading != null;
            if (!hasLeading && items.isEmpty) {
              return const SizedBox.shrink();
            }
            return _StripContent(
              ownerId: widget.ownerId,
              clusters: items,
              leading: widget.leading,
              selectedClusterId: widget.selectedClusterId,
              onClusterTap: widget.onClusterTap,
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _StripContent extends StatelessWidget {
  const _StripContent({
    required this.ownerId,
    required this.clusters,
    this.leading,
    this.selectedClusterId,
    this.onClusterTap,
  });

  static const double _kClusterCardWidth = 212;

  final String ownerId;
  final List<ClusterModel> clusters;
  final Widget? leading;
  final String? selectedClusterId;
  final ValueChanged<ClusterModel>? onClusterTap;

  void _applyClusterTap(BuildContext context, ClusterModel cluster) {
    final cubit = context.read<PostsListCubit>();
    final st = cubit.state;
    final selected = st.maybeWhen(
      loading: (feedClusterId, feedWithoutCluster) =>
          !feedWithoutCluster && feedClusterId == cluster.id,
      loaded: (_, __, ___, feedClusterId, feedWithoutCluster, ____, _____) =>
          !feedWithoutCluster && feedClusterId == cluster.id,
      orElse: () => false,
    );
    if (selected) {
      unawaited(cubit.loadUserFeed(ownerId));
    } else {
      unawaited(cubit.loadUserFeedForCluster(ownerId, cluster.id));
    }
  }

  bool _isAllPublicationsFilter(PostsListState postState) {
    return postState.maybeWhen(
      loading: (feedClusterId, feedWithoutCluster) => feedClusterId == null && !feedWithoutCluster,
      loaded: (_, __, ___, feedClusterId, feedWithoutCluster, ____, _____) =>
          feedClusterId == null && !feedWithoutCluster,
      orElse: () => false,
    );
  }

  /// Полная лента: посты с коллекцией и без.
  void _applyAllPublicationsTap(BuildContext context) {
    unawaited(context.read<PostsListCubit>().loadUserFeed(ownerId));
  }

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final showRest = clusters.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: BlocBuilder<PostsListCubit, PostsListState>(
                  buildWhen: (p, c) => p != c,
                  builder: (context, postState) {
                    final restIndex = leading != null ? 1 : 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leading != null) ...[leading, const SizedBox(width: 12)],
                        if (showRest) ...[
                          SizedBox(
                            width: _kClusterCardWidth,
                            child: ProfileCollectionCard(
                              index: restIndex,
                              imageUrl: '',
                              title: 'Все публикации',
                              collectionSubtitle: null,
                              countLabel: '',
                              isSelected: _isAllPublicationsFilter(postState),
                              onTap: () => _applyAllPublicationsTap(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        for (var i = 0; i < clusters.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          _ClusterCard(
                            index: restIndex + 1 + i,
                            cluster: clusters[i],
                            isSelected: postState.maybeWhen(
                              loading: (feedClusterId, feedWithoutCluster) =>
                                  !feedWithoutCluster && feedClusterId == clusters[i].id,
                              loaded: (_, __, ___, feedClusterId, feedWithoutCluster, ____, _____) =>
                                  !feedWithoutCluster && feedClusterId == clusters[i].id,
                              orElse: () => false,
                            ),
                            onTap: () {
                              if (onClusterTap != null) {
                                onClusterTap!(clusters[i]);
                              } else {
                                _applyClusterTap(context, clusters[i]);
                              }
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  const _ClusterCard({required this.index, required this.cluster, required this.isSelected, this.onTap});

  final int index;
  final ClusterModel cluster;
  final bool isSelected;
  final VoidCallback? onTap;

  static const double _cardWidth = 212;

  Future<void> _deleteCluster(BuildContext context) async {
    final ok = await AppDialog.showConfirm(
      context: context,
      title: 'Удалить кластер?',
      message: 'Обложка тоже будет удалена.',
      confirmLabel: 'Удалить',
      confirmIsDestructive: true,
      upperCaseTitle: false,
    );
    if (ok != true || !context.mounted) return;

    try {
      await sl<ClusterRepository>().deleteCluster(clusterId: cluster.id);
      clusterListRefreshTick.value++;
      if (!context.mounted) return;
      AppSnackBar.show(context, message: 'Кластер удалён', kind: AppSnackBarKind.success);
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
    }
  }

  Future<void> _archiveCluster(BuildContext context) async {
    final ok = await AppDialog.showConfirm(
      context: context,
      title: 'Архивировать кластер?',
      message: 'Он пропадёт из списка в профиле.',
      confirmLabel: 'Архивировать',
      confirmIsDestructive: false,
      upperCaseTitle: false,
    );
    if (ok != true || !context.mounted) return;

    try {
      await sl<ClusterRepository>().archiveCluster(clusterId: cluster.id);
      clusterListRefreshTick.value++;
      unawaited(sl<ProfileCubit>().refreshMyProfile());
      if (!context.mounted) return;
      AppSnackBar.show(context, message: 'Кластер архивирован', kind: AppSnackBarKind.success);
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: '$e', kind: AppSnackBarKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = cluster.coverUrl?.trim() ?? '';
    return SizedBox(
      width: _cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileCollectionCard(
            index: index,
            imageUrl: url,
            title: cluster.title,
            collectionSubtitle: cluster.subtitle,
            countLabel: cluster.postsCountLabel,
            isSelected: isSelected,
            onTap: onTap ?? () {},
          ),
          Positioned(
            right: 6,
            top: 6,
            child: AppActionSheet<String>(
              title: 'Действия',
              items: const [
                AppActionSheetItem(value: 'edit', label: 'Редактировать', icon: Icons.edit_outlined),
                AppActionSheetItem(value: 'archive', label: 'Архивировать', icon: Icons.archive_outlined),
                AppActionSheetItem(
                  value: 'delete',
                  label: 'Удалить',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                ),
              ],
              onSelected: (v) {
                if (v == 'delete') {
                  _deleteCluster(context);
                  return;
                }
                if (v == 'archive') {
                  _archiveCluster(context);
                  return;
                }
                AppSnackBar.show(
                  context,
                  message: 'Редактирование подключим следующим шагом',
                  kind: AppSnackBarKind.info,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.more_vert_rounded, color: Colors.black.withValues(alpha: 0.65), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

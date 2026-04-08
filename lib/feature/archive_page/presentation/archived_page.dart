import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart' show sl;
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_action_sheet.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_single_select.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
import 'package:side_project/feature/cluster/presentation/cluster_list_refresh.dart';
import 'package:side_project/feature/cluster/presentation/cubit/archived_clusters_cubit.dart';
import 'package:side_project/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ArchivedSection { clusters, posts }

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

  static const _options = <AppSingleSelectOption<ArchivedSection>>[
    AppSingleSelectOption(value: ArchivedSection.clusters, label: 'Кластеры'),
    AppSingleSelectOption(value: ArchivedSection.posts, label: 'Посты'),
  ];

  Future<void> _pickSection() async {
    final picked = await AppSingleSelect.showSheet<ArchivedSection>(
      context: context,
      title: 'Архив',
      options: _options,
      selected: _section.value,
      searchHint: 'Поиск',
    );
    if (!mounted || picked == null) return;
    _section.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppAppBar(
        automaticallyImplyLeading: true,
        title: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _pickSection,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<ArchivedSection>(
                  valueListenable: _section,
                  builder: (context, s, _) {
                    final label = s == ArchivedSection.clusters ? 'Кластеры' : 'Посты';
                    return Text(
                      label,
                      style: AppTextStyle.base(17, color: AppColors.textColor, fontWeight: FontWeight.w700),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subTextColor.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
      body: uid == null
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
                  return Center(
                    child: Text(
                      'Архив постов подключим позже',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
                    ),
                  );
                }
                return _ArchivedClustersList(ownerId: uid);
              },
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
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: _ArchivedClustersShimmer(),
            ),
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
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
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

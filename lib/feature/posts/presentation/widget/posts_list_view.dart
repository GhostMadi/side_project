import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/presentation/cubit/posts_list_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';

/// Переиспользуемый виджет, который показывает посты из [PostsListCubit].
///
/// Важно: **кубит создаётся и вызывается родителем** (как в кластерах) через `BlocProvider.value`.
class PostsListView extends StatelessWidget {
  const PostsListView({super.key, this.onPostTap, this.crossAxisCount = 2});

  final void Function(PostModel post)? onPostTap;

  /// Число колонок сетки (профиль: 2).
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.maxScrollExtent <= 0) return false;
        final remaining = n.metrics.maxScrollExtent - n.metrics.pixels;
        if (remaining < 600) {
          context.read<PostsListCubit>().loadMore();
        }
        return false;
      },
      child: BlocBuilder<PostsListCubit, PostsListState>(
        builder: (context, state) {
          return state.when(
            initial: () => _PostsGridLoadingShimmer(crossAxisCount: crossAxisCount),
            loading: (_, __) => _PostsGridLoadingShimmer(crossAxisCount: crossAxisCount),
            loaded: (items, _, savedByPostId, _, _, _, isLoadingMore) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PostsSection(
                  posts: items,
                  savedByPostId: savedByPostId,
                  onPostTap: onPostTap,
                  crossAxisCount: crossAxisCount,
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            error: (_) => PostsSection(posts: const [], crossAxisCount: crossAxisCount),
          );
        },
      ),
    );
  }
}

/// Плейсхолдер сетки до ответа API — не показываем «нет публикаций».
class _PostsGridLoadingShimmer extends StatelessWidget {
  const _PostsGridLoadingShimmer({required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    const tiles = 15;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: AppShimmer(
        child: StaggeredGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: [
            for (var i = 0; i < tiles; i++)
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: i % 6 == 0 ? 2 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kPostHeroRadiusCollapsed),
                  child: const ColoredBox(color: AppColors.surfaceSoft),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

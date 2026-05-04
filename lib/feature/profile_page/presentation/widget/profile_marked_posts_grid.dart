import 'dart:async' show unawaited;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/media_widget.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_marker_linked_posts_cubit.dart';
import 'package:side_project/feature/profile_page/presentation/cubit/profile_markers_cubit.dart';

/// Tab "markers" in profile:
/// visually the same grid as posts, but marker can have `post_id = null`.
/// If post exists → show media tile; if no post → show placeholder tile (no media).
class ProfileMarkedPostsGrid extends StatelessWidget {
  const ProfileMarkedPostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileMarkersCubit, ProfileMarkersState>(
      builder: (context, markerState) {
        final markers = markerState.maybeWhen(
          loaded: (items) => items,
          orElse: () => const <ProfileMarkerModel>[],
        );

        return BlocBuilder<ProfileMarkerLinkedPostsCubit, ProfileMarkerLinkedPostsState>(
          builder: (context, linkedState) {
            final (postsByMarkerId, savedByPostId) = linkedState.maybeWhen(
              loaded: (items, saved, __, ___) {
                final grouped = <String, List<PostModel>>{};
                for (final p in items) {
                  final mid = (p.markerId ?? '').trim();
                  if (mid.isEmpty) continue;
                  (grouped[mid] ??= <PostModel>[]).add(p);
                }
                return (grouped, saved);
              },
              orElse: () => (<String, List<PostModel>>{}, <String, bool>{}),
            );

            // Same spacing as posts grid; подгрузка при прокрутке как в [PostsListView].
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.maxScrollExtent <= 0) return false;
                final remaining = n.metrics.maxScrollExtent - n.metrics.pixels;
                if (remaining < 600) {
                  context.read<ProfileMarkerLinkedPostsCubit>().loadMore();
                }
                return false;
              },
              child: linkedState.map(
                initial: (_) => const SizedBox.shrink(),
                loading: (_) {
                  if (!markerState.maybeWhen(loaded: (_) => true, orElse: () => false)) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final mks = markerState.maybeWhen(loaded: (i) => i, orElse: () => <ProfileMarkerModel>[]);
                  if (mks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'Нет событий',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.base(14, color: AppColors.subTextColor),
                      ),
                    );
                  }
                  return _MarkerGrid(
                    markers: mks,
                    childForMarker: (m) {
                      return const _MarkerCellShimmer();
                    },
                    bottomExtra: null,
                  );
                },
                error: (e) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    e.message,
                    style: AppTextStyle.base(13, fontWeight: FontWeight.w600, color: AppColors.textColor),
                  ),
                ),
                loaded: (l) {
                  if (!markerState.maybeWhen(loaded: (_) => true, orElse: () => false)) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (markers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'Нет событий',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.base(14, color: AppColors.subTextColor),
                      ),
                    );
                  }
                  final moreLoading = l.isLoadingMore && l.hasMore;
                  return _MarkerGrid(
                    markers: markers,
                    childForMarker: (m) {
                      final posts = postsByMarkerId[m.id] ?? const <PostModel>[];
                      if (posts.isEmpty) return _MarkerNullPostTile(marker: m);

                      // [ProfileMarkerLinkedPostsCubit] возвращает фид по убыванию created_at,
                      // поэтому первый встретившийся пост для маркера — хороший превью-кандидат.
                      final preview = posts.first;
                      return _MarkerWithPostsTile(
                        marker: m,
                        preview: preview,
                        isSaved: savedByPostId[preview.id] ?? false,
                        markerPostsCount: posts.length,
                      );
                    },
                    bottomExtra: moreLoading
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
                  );
                },
              ),
            );
          },
        );
      },
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

class _PostTileLike extends StatelessWidget {
  const _PostTileLike({
    required this.post,
    required this.isSaved,
    required this.markerPostsCount,
    this.onTapOverride,
  });

  final PostModel post;
  final bool isSaved;
  final int markerPostsCount;
  final Future<void> Function()? onTapOverride;

  static const _radius = kPostHeroRadiusCollapsed;

  @override
  Widget build(BuildContext context) {
    final first = post.media.isNotEmpty ? post.media.first : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: AppColors.surfaceSoft,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () async {
            final override = onTapOverride;
            if (override != null) {
              await override();
              return;
            }
            final deleted = await context.router.push<bool>(
              PostDetailRoute(post: post, initialIsSaved: isSaved),
            );
            if (deleted == true && context.mounted) {
              unawaited(context.read<ProfileMarkerLinkedPostsCubit>().reload());
              unawaited(context.read<ProfileMarkersCubit>().reloadIfLoadedOwner());
            }
          },
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
              if (markerPostsCount > 1)
                Positioned(
                  top: 6,
                  left: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        '+${markerPostsCount - 1}',
                        style: AppTextStyle.base(12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              if (isSaved)
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.bookmark, size: 16, color: Colors.white),
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

class _MarkerWithPostsTile extends StatelessWidget {
  const _MarkerWithPostsTile({
    required this.marker,
    required this.preview,
    required this.isSaved,
    required this.markerPostsCount,
  });

  final ProfileMarkerModel marker;
  final PostModel preview;
  final bool isSaved;
  final int markerPostsCount;

  @override
  Widget build(BuildContext context) {
    return _PostTileLike(
      post: preview,
      isSaved: isSaved,
      markerPostsCount: markerPostsCount,
      // Если у маркера один пост — открываем как обычный пост.
      // Если постов много — открываем ленту постов маркера.
      onTapOverride: () async {
        if (markerPostsCount <= 1) {
          await context.router.push(PostDetailRoute(post: preview, initialIsSaved: isSaved, embedded: false));
          return;
        }
        await context.router.push(
          MarkerPostsRoute(
            markerId: marker.id,
            title: marker.addressText,
            textEmoji: marker.textEmoji,
            initialPost: preview,
          ),
        );
      },
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
              Positioned(bottom: 8, left: 8, right: 8, child: _StatusMiniPill(status: marker.status)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMiniPill extends StatelessWidget {
  const _StatusMiniPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'active' => (AppColors.primary.withValues(alpha: 0.14), AppColors.primary, 'Активно'),
      'upcoming' => (AppColors.surface.withValues(alpha: 0.85), AppColors.textColor, 'Скоро'),
      'finished' => (
        AppColors.surface.withValues(alpha: 0.70),
        AppColors.textColor.withValues(alpha: 0.7),
        'Прошло',
      ),
      'cancelled' => (Colors.red.withValues(alpha: 0.12), Colors.red, 'Отмена'),
      _ => (AppColors.surface.withValues(alpha: 0.70), AppColors.textColor.withValues(alpha: 0.7), status),
    };

    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(11, fontWeight: FontWeight.w900, color: fg),
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';

String postHeroTag(String postId) => 'post_hero_$postId';

const double kPostHeroRadiusCollapsed = 14.0; // tile radius
const double kPostHeroRadiusExpanded = 32.0; // detail radius

Widget buildPostHero({required String postId, required Widget child}) {
  return Hero(
    tag: postHeroTag(postId),
    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
      // UX: на вход (push) радиус может "раскрываться",
      // но на выход (pop) держим один радиус, чтобы не было заметного "пульса".
      final begin = flightDirection == HeroFlightDirection.push
          ? kPostHeroRadiusCollapsed
          : kPostHeroRadiusCollapsed;
      final end = flightDirection == HeroFlightDirection.push
          ? kPostHeroRadiusExpanded
          : kPostHeroRadiusCollapsed;
      final radiusAnim = Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));

      // Use destination widget to preserve image during flight.
      final hero =
          (flightDirection == HeroFlightDirection.push ? toHeroContext.widget : fromHeroContext.widget)
              as Hero;
      final heroChild = hero.child;

      return AnimatedBuilder(
        animation: radiusAnim,
        builder: (context, _) {
          return ClipRRect(borderRadius: BorderRadius.circular(radiusAnim.value), child: heroChild);
        },
      );
    },
    child: child,
  );
}

/// Переиспользуемая сетка постов (Pinterest/masonry).
/// [crossAxisCount]: в профиле обычно 3, на экране сохранённых по умолчанию 2.
class PostsSection extends StatelessWidget {
  const PostsSection({
    super.key,
    required this.posts,
    this.savedByPostId,
    this.onPostTap,
    this.crossAxisCount = 2,
  });

  final List<PostModel> posts;
  /// Состояние «сохранено мной» из enriched-RPC; если null — индикатор не рисуем.
  final Map<String, bool>? savedByPostId;
  final void Function(PostModel post)? onPostTap;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 32),
        child: Text(
          'нет публикаций',
          textAlign: TextAlign.center,
          style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
        ),
      );
    }
    return _PostsGrid(
      posts: posts,
      savedByPostId: savedByPostId,
      onPostTap: onPostTap,
      crossAxisCount: crossAxisCount,
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid({
    required this.posts,
    this.savedByPostId,
    this.onPostTap,
    required this.crossAxisCount,
  });

  final List<PostModel> posts;
  final Map<String, bool>? savedByPostId;
  final void Function(PostModel post)? onPostTap;
  final int crossAxisCount;

  static final _aspectRe = RegExp(r'__ar-(\d+)x(\d+)', caseSensitive: false);

  String? _aspectFromUrl(String url) {
    if (url.trim().isEmpty) return null;
    final u = Uri.tryParse(url);
    final path = (u?.path ?? url).toLowerCase();
    final m = _aspectRe.firstMatch(path);
    if (m == null) return null;
    final w = int.tryParse(m.group(1) ?? '');
    final h = int.tryParse(m.group(2) ?? '');
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return '${w}x$h';
  }

  ({int cross, int main}) _spanForPost(PostModel post) {
    final url = post.media.isNotEmpty ? post.media.first.url : '';
    final a = _aspectFromUrl(url);
    final g = crossAxisCount.clamp(2, 6);
    return switch (a) {
      '16x9' => (cross: g, main: 1),
      '9x16' => (cross: 1, main: 2),
      // 1x1 and 3x4: render as normal 1x1 square tile
      _ => (cross: 1, main: 1),
    };
  }

  Widget _buildGridTile(PostModel post) {
    final s = _spanForPost(post);
    return StaggeredGridTile.count(
      crossAxisCellCount: s.cross,
      mainAxisCellCount: s.main,
      child: _PostTile(
        post: post,
        isSaved: savedByPostId?[post.id] ?? false,
        onTap: onPostTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [for (final post in posts) _buildGridTile(post)],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.isSaved, required this.onTap});

  final PostModel post;
  final bool isSaved;
  final void Function(PostModel post)? onTap;

  static const _radius = kPostHeroRadiusCollapsed;

  @override
  Widget build(BuildContext context) {
    final url = post.media.isNotEmpty ? post.media.first.url : null;
    final hasUrl = url != null && url.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: AppColors.surfaceSoft,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap == null ? null : () => onTap!(post),
          child: Stack(
            children: [
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
              Positioned.fill(
                child: buildPostHero(
                  postId: post.id,
                  child: !hasUrl
                      ? const PostMediaFramePlaceholder(shimmer: true)
                      : CachedNetworkImage(
                          imageUrl: url.trim(),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const PostMediaFramePlaceholder(shimmer: true),
                          errorWidget: (_, __, ___) => const PostMediaFramePlaceholder(shimmer: false),
                          // Без повторного fade при возврате с детального экрана (кэш уже тёплый).
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
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

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/media_widget.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';

String postHeroTag(String postId) => 'post_hero_$postId';

const double kPostHeroRadiusCollapsed = 20.0; // tile radius
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
///
/// Плитка поста берёт **первый** элемент [PostModel.media] (`sort_order` с бэка).
/// Если первым стоит **видео**, в ячейке — только постер по соглашению имён (`…__poster.jpg`), сам ролик не грузим.
///
/// [crossAxisCount]: в профиле через [PostsListView] — 2 колонки; сохранённые по умолчанию 2.
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
  const _PostsGrid({required this.posts, this.savedByPostId, this.onPostTap, required this.crossAxisCount});

  final List<PostModel> posts;
  final Map<String, bool>? savedByPostId;
  final void Function(PostModel post)? onPostTap;
  final int crossAxisCount;

  static final _aspectRe = RegExp(r'__ar-(\d+)x(\d+)', caseSensitive: false);

  static String? _aspectFromUrl(String url) {
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

  static _PostGridAspectKind _aspectKind(PostModel post) {
    final url = post.media.isNotEmpty ? post.media.first.url : '';
    return switch (_aspectFromUrl(url)) {
      '16x9' => _PostGridAspectKind.landscape169,
      '9x16' => _PostGridAspectKind.portrait916,
      _ => _PostGridAspectKind.square,
    };
  }

  /// Сетка: **9×16** — одна колонка, высота 2 ячейки (вертикально); **16×9** — ровно 2 колонки
  /// в ширину, высота 1; **остальное** (нет `__ar-…` в URL или не эти соотношения) — квадрат 1×1.
  /// 16×9 при одной колонке сетки или если нет пары соседних колонок на одной «линии» — 1×1.
  static List<({int cross, int main})> _computeTileSpans(List<PostModel> posts, int crossAxisCount) {
    final n = crossAxisCount.clamp(1, 12);
    final colTop = List<int>.filled(n, 0);
    final out = <({int cross, int main})>[];

    int leftmostMinCol() {
      var idx = 0;
      var minVal = colTop[0];
      for (var i = 1; i < n; i++) {
        if (colTop[i] < minVal) {
          minVal = colTop[i];
          idx = i;
        }
      }
      return idx;
    }

    /// Первая слева пара столбцов [c, c+1] на минимальной «высоте» сетки.
    int? pairAtMinForLandscape() {
      if (n < 2) return null;
      var minV = colTop[0];
      for (var i = 1; i < n; i++) {
        if (colTop[i] < minV) minV = colTop[i];
      }
      for (var c = 0; c < n - 1; c++) {
        if (colTop[c] == minV && colTop[c + 1] == minV) return c;
      }
      return null;
    }

    for (final post in posts) {
      switch (_aspectKind(post)) {
        case _PostGridAspectKind.square:
          final c = leftmostMinCol();
          out.add((cross: 1, main: 1));
          colTop[c] += 1;
        case _PostGridAspectKind.portrait916:
          final c = leftmostMinCol();
          out.add((cross: 1, main: 2));
          colTop[c] += 2;
        case _PostGridAspectKind.landscape169:
          final pair = pairAtMinForLandscape();
          if (pair != null) {
            const main = 1;
            const cross = 2;
            out.add((cross: cross, main: main));
            colTop[pair] += main;
            colTop[pair + 1] += main;
          } else {
            final c = leftmostMinCol();
            out.add((cross: 1, main: 1));
            colTop[c] += 1;
          }
      }
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final spans = _computeTileSpans(posts, crossAxisCount);
    return Padding(
      padding: EdgeInsets.zero,
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [
          for (var i = 0; i < posts.length; i++)
            StaggeredGridTile.count(
              crossAxisCellCount: spans[i].cross,
              mainAxisCellCount: spans[i].main,
              child: _PostTile(
                post: posts[i],
                isSaved: savedByPostId?[posts[i].id] ?? false,
                onTap: onPostTap,
              ),
            ),
        ],
      ),
    );
  }
}

enum _PostGridAspectKind { square, portrait916, landscape169 }

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.isSaved, required this.onTap});

  final PostModel post;
  final bool isSaved;
  final void Function(PostModel post)? onTap;

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
          onTap: onTap == null ? null : () => onTap!(post),
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

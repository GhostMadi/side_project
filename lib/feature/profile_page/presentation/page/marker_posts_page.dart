import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/feature/map_page/data/repository/marker_post_links_repository.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/feature/posts/presentation/page/post_detail_page.dart';

@RoutePage()
class MarkerPostsPage extends StatefulWidget {
  const MarkerPostsPage({super.key, required this.markerId, this.title, this.textEmoji, this.initialPost});

  final String markerId;
  final String? title;
  final String? textEmoji;
  final PostModel? initialPost;

  @override
  State<MarkerPostsPage> createState() => _MarkerPostsPageState();
}

class _MarkerPostsPageState extends State<MarkerPostsPage> {
  late Future<void> _load;
  Object? _err;
  List<MarkerPostLink> _links = const [];
  PageController? _pageController;
  int _initialIndex = 0;
  final Map<String, Future<PostModel?>> _postFutures = {};

  @override
  void initState() {
    super.initState();
    _load = _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final links = await sl<MarkerPostLinksRepository>().listPostsForMarker(widget.markerId);
      if (!mounted) return;
      const initialIndex = 0;

      setState(() {
        _links = links;
        _initialIndex = initialIndex;
        _pageController ??= PageController(initialPage: initialIndex);
      });
      final ids = links.map((e) => e.postId).where((id) => id.trim().isNotEmpty).toList();
      await sl<PostsRepository>().prefetchPostsByIds(ids);
    } catch (e) {
      if (mounted) setState(() => _err = e);
    }
  }

  Future<PostModel?> _getPostFuture(String postIdRaw) {
    final postId = postIdRaw.trim();
    if (postId.isEmpty) return Future.value(null);
    return _postFutures.putIfAbsent(postId, () async {
      // If it's already cached, return synchronously-ish.
      final cached = sl<PostsRepository>().getCachedPostById(postId);
      if (cached != null) return cached;
      final base = await sl<PostsRepository>().getByIdWithAuthorMini(postId);
      return base?.post;
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBarHeight = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: AppPillBackNavOverlay(
        extraItems: [
          AppPillNavItem(
            icon: Icons.add_rounded,
            label: 'Пост',
            onTap: () => context.router.push(PostCreateRoute(markerId: widget.markerId)),
          ),
        ],
        child: Stack(
          children: [
            // Content: "post -> post" vertical paging.
            Positioned.fill(
              child: FutureBuilder<void>(
                future: _load,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done && _links.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: topBarHeight),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => const _PostCardShimmer(),
                      ),
                    );
                  }
                  if (_err != null) {
                    return Center(
                      child: Text(
                        'Не удалось загрузить посты',
                        style: AppTextStyle.base(15, color: AppColors.error),
                      ),
                    );
                  }
                  if (_links.isEmpty) {
                    return Center(
                      child: Text('Нет постов', style: AppTextStyle.base(15, color: AppColors.subTextColor)),
                    );
                  }

                  final controller = _pageController ?? PageController(initialPage: _initialIndex);
                  final initial = widget.initialPost;
                  final initialId = initial?.id.trim();
                  final extraTop = _links.length <= 1 ? 32.0 : 0.0;

                  return Padding(
                    // Впритык под верхнюю панель.
                    padding: EdgeInsets.only(top: topBarHeight),
                    child: ListView.separated(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: extraTop),
                      itemCount: _links.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final link = _links[i];
                        return RepaintBoundary(
                          child: _MarkerPostItem(
                            key: ValueKey('marker-post-${link.postId}'),
                            postId: link.postId,
                            initialPost:
                                (initialId != null && initialId.isNotEmpty && initialId == link.postId.trim())
                                ? initial
                                : null,
                            getFuture: _getPostFuture,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Top bar: fixed (без анимации), чтобы не ломать скролл PageView.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: AppColors.pageBackground,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: Center(
                      child: Text(
                        'Маркеры',
                        style: AppTextStyle.base(18, fontWeight: FontWeight.w900, color: AppColors.textColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCardShimmer extends StatelessWidget {
  const _PostCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 88,
                height: 28,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(height: 360, child: PostMediaFramePlaceholder(shimmer: false)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerPostItem extends StatefulWidget {
  const _MarkerPostItem({
    super.key,
    required this.postId,
    required this.initialPost,
    required this.getFuture,
  });

  final String postId;
  final PostModel? initialPost;
  final Future<PostModel?> Function(String postId) getFuture;

  @override
  State<_MarkerPostItem> createState() => _MarkerPostItemState();
}

class _MarkerPostItemState extends State<_MarkerPostItem> with AutomaticKeepAliveClientMixin {
  Future<PostModel?>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.initialPost == null) {
      _future = widget.getFuture(widget.postId);
    }
  }

  @override
  void didUpdateWidget(covariant _MarkerPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If postId changed (shouldn't in normal list usage), restart future once.
    if (oldWidget.postId.trim() != widget.postId.trim() && widget.initialPost == null) {
      _future = widget.getFuture(widget.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final initial = widget.initialPost;
    if (initial != null) {
      return PostDetailPage(post: initial, embedded: true);
    }

    final future = _future;
    if (future == null) {
      // Defensive: should not happen, but keep UI stable.
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: _PostCardShimmer());
    }

    return FutureBuilder<PostModel?>(
      future: future,
      builder: (context, snap) {
        final post = snap.data ?? sl<PostsRepository>().getCachedPostById(widget.postId);
        if (post == null) {
          return const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: _PostCardShimmer());
        }
        return PostDetailPage(post: post, embedded: true);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

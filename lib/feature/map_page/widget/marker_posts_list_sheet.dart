import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/map_page/data/repository/marker_post_links_repository.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/feature/posts/presentation/page/post_detail_page.dart';

/// Лента постов маркера на всю ширину шторки без боковых отступов ([AppBottomSheet] задаёт высоту).
class MarkerPostsListSheet extends StatefulWidget {
  const MarkerPostsListSheet({super.key, required this.mapMarker});

  final MapMarker mapMarker;

  @override
  State<MarkerPostsListSheet> createState() => _MarkerPostsListSheetState();
}

class _MarkerPostsListSheetState extends State<MarkerPostsListSheet> {
  late Future<void> _load;
  Object? _err;
  List<MarkerPostLink> _links = const [];

  @override
  void initState() {
    super.initState();
    _load = _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final links = await sl<MarkerPostLinksRepository>().listPostsForMarker(widget.mapMarker.id);
      if (!mounted) return;
      setState(() => _links = links);
    } catch (e) {
      if (mounted) setState(() => _err = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done && _links.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
              child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 28, color: AppColors.primary),
            ),
          );
        }
        if (_err != null) {
          return SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Не удалось загрузить посты',
                style: AppTextStyle.base(15, color: AppColors.error),
              ),
            ),
          );
        }
        if (_links.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(child: Text('Нет постов', style: AppTextStyle.base(15, color: AppColors.subTextColor))),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height * 0.5;

            return SizedBox(
              height: h,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _links.length,
                  itemBuilder: (context, i) {
                    final link = _links[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == _links.length - 1 ? 0 : 12),
                      child: FutureBuilder(
                        future: sl<PostsRepository>().getByIdWithAuthorMini(link.postId),
                        builder: (context, snap) {
                          final base = snap.data;
                          final post = base?.post ?? sl<PostsRepository>().getCachedPostById(link.postId);
                          if (post == null) {
                            if (snap.connectionState != ConnectionState.done) {
                              return SizedBox(
                                height: 180,
                                child: Center(
                                  child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 24, color: AppColors.primary),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                'Пост недоступен',
                                style: AppTextStyle.base(14, color: AppColors.subTextColor),
                              ),
                            );
                          }
                          return PostDetailPage(post: post, embedded: true);
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';

/// Переиспользуемая сетка постов (Pinterest/masonry, 2 колонки).
class PostsSection extends StatelessWidget {
  const PostsSection({super.key, required this.posts, this.onPostTap});

  final List<PostModel> posts;
  final void Function(PostModel post)? onPostTap;

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
    return _PostsGrid(posts: posts, onPostTap: onPostTap);
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid({required this.posts, this.onPostTap});

  final List<PostModel> posts;
  final void Function(PostModel post)? onPostTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // Пока нет aspect ratio в схеме поста — оставляем квадрат.
        return _MasonryTile(post: post, aspectRatio: 1.0, onTap: onPostTap);
      },
    );
  }
}

class _MasonryTile extends StatelessWidget {
  const _MasonryTile({required this.post, required this.aspectRatio, required this.onTap});

  final PostModel post;
  final double aspectRatio;
  final void Function(PostModel post)? onTap;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final url = post.media.isNotEmpty ? post.media.first.url : null;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Material(
          color: AppColors.surfaceSoft,
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: onTap == null ? null : () => onTap!(post),
            child: url == null || url.trim().isEmpty
                ? ColoredBox(
                    color: AppColors.surfaceSoft,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.subTextColor.withValues(alpha: 0.45),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(color: AppColors.surfaceSoft),
                    errorWidget: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.subTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

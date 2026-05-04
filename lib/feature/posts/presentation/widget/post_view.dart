import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/media_widget.dart';
import 'package:side_project/feature/posts/data/models/post_feed_item.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';

/// Переиспользуемый “вид поста”, который можно встроить:
/// - в ленту (ListView / PageView)
/// - в экран одного поста (Scaffold-обёртка)
///
/// Это НЕ страница и не делает навигацию “внутрь” автоматически.
class PostView extends StatelessWidget {
  const PostView({
    super.key,
    required this.postId,
    required this.indexLabel,
    required this.isPrimary,
    this.onOpenPost,
  });

  final String postId;
  final String indexLabel;
  final bool isPrimary;

  /// Если передан — на “открыть” используем внешний обработчик (например, открыть модал/роут).
  final VoidCallback? onOpenPost;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FutureBuilder<PostFeedItem?>(
          future: sl<PostsRepository>().getPostEnriched(postId),
          builder: (context, snap) {
            final item = snap.data;
            final post = item?.post ?? sl<PostsRepository>().getCachedPostById(postId);

            if (snap.connectionState != ConnectionState.done && post == null) {
              return const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (post == null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Пост недоступен',
                  style: AppTextStyle.base(14, color: AppColors.subTextColor),
                ),
              );
            }

            final first = post.media.isNotEmpty ? post.media.first : null;
            final title = post.title?.trim();
            final desc = post.description?.trim();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      Text(
                        indexLabel,
                        style: AppTextStyle.base(14, fontWeight: FontWeight.w900, color: AppColors.textColor),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
                          ),
                          child: Text(
                            'Главный',
                            style: AppTextStyle.base(12, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (onOpenPost != null)
                        IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onPressed: onOpenPost,
                          icon: Icon(Icons.open_in_new_rounded, color: AppColors.subTextColor.withValues(alpha: 0.8)),
                        )
                      else
                        const SizedBox(width: 24),
                    ],
                  ),
                ),

                AspectRatio(
                  aspectRatio: 1,
                  child: buildPostHero(
                    postId: post.id,
                    child: first == null
                        ? const PostMediaFramePlaceholder(shimmer: true)
                        : MediaWidget.previewTile(
                            url: first.url,
                            treatAsVideoFromModel: first.treatsAsVideoTile,
                          ),
                  ),
                ),

                if (title != null && title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Text(
                      title,
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w900, color: AppColors.textColor),
                    ),
                  ),
                if (desc != null && desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Text(
                      desc,
                      style: AppTextStyle.base(14, height: 1.35, color: AppColors.textColor.withValues(alpha: 0.9)),
                    ),
                  )
                else
                  const SizedBox(height: 14),
              ],
            );
          },
        ),
      ),
    );
  }
}


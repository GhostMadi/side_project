import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/feature/posts/data/models/post_saver.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

/// Список пользователей, сохранивших пост (доступен автору поста на бэке).
class PostSaversSheet extends StatelessWidget {
  const PostSaversSheet({super.key, required this.postId});

  final String postId;

  static Future<void> show(BuildContext context, {required String postId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (ctx) => PostSaversSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    return SafeArea(
      child: SizedBox(
        height: maxH,
        child: FutureBuilder<List<PostSaver>>(
          future: sl<PostsRepository>().listPostSavers(postId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Не удалось загрузить: ${snap.error}', style: AppTextStyle.base(14, color: AppColors.error)),
              );
            }
            final list = snap.data ?? const <PostSaver>[];
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Text(
                  'Никто не сохранил этот пост или нет доступа.',
                  style: AppTextStyle.base(14, color: AppColors.subTextColor),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Сохранили',
                    style: AppTextStyle.base(18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.subTextColor.withValues(alpha: 0.15)),
                    itemBuilder: (context, i) {
                      final s = list[i];
                      final name = (s.username?.trim().isNotEmpty ?? false) ? s.username!.trim() : 'Пользователь';
                      final url = s.avatarUrl?.trim();
                      final hasAvatar = url != null && url.isNotEmpty;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.surfaceSoft,
                          backgroundImage: hasAvatar ? CachedNetworkImageProvider(url) : null,
                          child: hasAvatar
                              ? null
                              : Icon(Icons.person_outline_rounded, color: AppColors.subTextColor.withValues(alpha: 0.8)),
                        ),
                        title: Text(name, style: AppTextStyle.base(16, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          _formatSavedAt(s.savedAt),
                          style: AppTextStyle.base(12, color: AppColors.subTextColor),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatSavedAt(DateTime t) {
    final local = t.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }
}

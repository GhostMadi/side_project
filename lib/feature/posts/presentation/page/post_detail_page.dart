import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_pill_navigation_bar.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/post_comments_bottom_sheet.dart';

String _formatCount(int n) {
  if (n < 0) return '0';
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Деталка поста (пока UI, данные берём из Supabase через [PostDetailCubit]).
@RoutePage()
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostDetailCubit _cubit;
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PostDetailCubit>()..load(widget.postId);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _cubit.close();
    _pageController.dispose();
    super.dispose();
  }

  void _openCommentsMock(PostModel post) {
    // Пока без реального API comments: показываем пустую шторку.
    unawaited(PostCommentsBottomSheet.show(context, comments: const <PostCommentUiModel>[]));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) {
          return state.when(
            initial: () => const _PostDetailScaffoldLoading(),
            loading: () => const _PostDetailScaffoldLoading(),
            notFound: () => const _PostDetailScaffoldMessage(message: 'Пост не найден'),
            error: (m) => _PostDetailScaffoldMessage(message: m),
            loaded: (post) => _PostDetailScaffold(
              post: post,
              pageController: _pageController,
              pageIndex: _pageIndex,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              onOpenComments: () => _openCommentsMock(post),
            ),
          );
        },
      ),
    );
  }
}

class _PostDetailScaffoldLoading extends StatelessWidget {
  const _PostDetailScaffoldLoading();

  @override
  Widget build(BuildContext context) {
    return const _PostDetailScaffoldMessage(message: 'Загрузка…');
  }
}

class _PostDetailScaffoldMessage extends StatelessWidget {
  const _PostDetailScaffoldMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back.icon, color: AppColors.textColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
          ),
        ),
      ),
    );
  }
}

class _PostDetailScaffold extends StatelessWidget {
  const _PostDetailScaffold({
    required this.post,
    required this.pageController,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onOpenComments,
  });

  final PostModel post;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenComments;

  @override
  Widget build(BuildContext context) {
    final media = post.media;
    final urls = media.map((m) => m.url).where((u) => u.trim().isNotEmpty).toList(growable: false);
    final title = post.title?.trim();
    final subtitle = post.subtitle?.trim();
    final body = post.description?.trim() ?? '';

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back.icon, color: AppColors.textColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Публикация', style: AppTextStyle.base(16, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (urls.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: urls.length,
                itemBuilder: (context, i) {
                  return CachedNetworkImage(
                    imageUrl: urls[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(color: AppColors.surfaceSoft),
                    errorWidget: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.subTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const AspectRatio(aspectRatio: 1, child: ColoredBox(color: AppColors.surfaceSoft)),
          if (urls.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: AppPillNavigationBar(
                  items: List.generate(
                    urls.length,
                    (i) => AppPillNavItem(
                      icon: Icons.circle,
                      label: '${i + 1}',
                      onTap: () => pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  selectedIndex: pageIndex,
                  onSelectionChanged: (i) => pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                  height: 72,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CountChip(icon: Icons.favorite_border_rounded, value: post.likesCount),
                const SizedBox(width: 8),
                _CountChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  value: post.commentsCount,
                  onTap: onOpenComments,
                ),
                const SizedBox(width: 8),
                _CountChip(icon: Icons.bookmark_border_rounded, value: post.savesCount),
                const SizedBox(width: 8),
                _CountChip(icon: Icons.send_rounded, value: post.sendsCount),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    style: AppTextStyle.base(18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                  ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyle.base(14, color: AppColors.subTextColor)),
                ],
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(body, style: AppTextStyle.base(14, color: AppColors.textColor, height: 1.45)),
                ],
                const SizedBox(height: 16),
                Text(
                  'Просмотры: ${_formatCount(post.viewsCount)}',
                  style: AppTextStyle.base(12, color: AppColors.subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.value, this.onTap});

  final IconData icon;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textColor),
            const SizedBox(width: 8),
            Text(_formatCount(value), style: AppTextStyle.base(13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
    return onTap == null
        ? child
        : InkWell(borderRadius: BorderRadius.circular(999), onTap: onTap, child: child);
  }
}

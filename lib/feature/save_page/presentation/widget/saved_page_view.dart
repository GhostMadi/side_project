import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';
import 'package:side_project/feature/save_page/presentation/cubit/saved_page_cubit.dart';

/// Лента сохранённых постов из [SavedPageCubit] с pull-to-refresh.
class SavedPageView extends StatelessWidget {
  const SavedPageView({super.key, this.onPostTap});

  final void Function(PostModel post)? onPostTap;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.maxScrollExtent <= 0) return false;
        final remaining = n.metrics.maxScrollExtent - n.metrics.pixels;
        if (remaining < 600) {
          context.read<SavedPageCubit>().loadMore();
        }
        return false;
      },
      child: BlocBuilder<SavedPageCubit, SavedPageState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<SavedPageCubit>().refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ...state.when(
                  initial: () => [_loadingSliver()],
                  loading: () => [_loadingSliver()],
                  loaded: (items, _, isLoadingMore) {
                    if (items.isEmpty) {
                      return [_emptySliver()];
                    }
                    return [
                      SliverToBoxAdapter(
                        child: PostsSection(
                          posts: items,
                          onPostTap: onPostTap,
                        ),
                      ),
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppCircularProgressIndicator(dimension: 28)),
                          ),
                        ),
                    ];
                  },
                  error: (m) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _SavedErrorBody(
                        message: m,
                        onRetry: () => context.read<SavedPageCubit>().load(),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppPillBackNavOverlay.scrollBottomInset(context)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _loadingSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppCircularProgressIndicator(dimension: 36),
              const SizedBox(height: 16),
              Text(
                'Загрузка сохранённого…',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _emptySliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: AppColors.subTextColor.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 16),
              Text(
                'Пока пусто',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(17, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Сохраняйте посты из ленты или экрана поста — они появятся здесь.',
                textAlign: TextAlign.center,
                style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedErrorBody extends StatelessWidget {
  const _SavedErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.subTextColor.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text(
            'Не удалось загрузить',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
            ),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

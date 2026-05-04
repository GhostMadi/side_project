import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_overflow_menu.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/marker_event_meta_card.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';
import 'package:side_project/feature/profile_page/data/repository/profile_markers_repository.dart';

/// Экран «как [PostDetailPage]», когда у маркера ещё нет публикации:
/// в шапке — аватар; в «фото»-блоке — крупный эмодзи маркера; [MarkerEventMetaCard] и «Пост» в пилюле.
@RoutePage()
class MarkerWithoutPostPage extends StatelessWidget {
  const MarkerWithoutPostPage({
    super.key,
    required this.markerId,
    this.textEmoji,
    this.title,
    required this.eventTimeIso,
    required this.endTimeIso,
    required this.status,
  });

  final String markerId;
  final String? textEmoji;
  final String? title;
  final String eventTimeIso;
  final String endTimeIso;
  final String status;

  @override
  Widget build(BuildContext context) {
    final placeTitle = title?.trim();
    final hasPlace = placeTitle != null && placeTitle.isNotEmpty;
    final event = DateTime.tryParse(eventTimeIso) ?? DateTime.now();
    final end = DateTime.tryParse(endTimeIso) ?? event;
    const aspectRatio = 1.0;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a != b,
      builder: (context, auth) {
        final url = auth.maybeWhen(authenticated: (u) => u.avatarUrl, orElse: () => null)?.trim();
        final hasAvatar = url != null && url.isNotEmpty;
        final em = textEmoji?.trim();
        final hasEmoji = em != null && em.isNotEmpty;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AppColors.pageBackground,
            body: AppPillBackNavOverlay(
              extraItems: [
                AppPillNavItem(
                  icon: Icons.add_rounded,
                  label: 'Пост',
                  onTap: () => context.router.push(PostCreateRoute(markerId: markerId)),
                ),
              ],
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.pageBackground,
                    elevation: 0,
                    pinned: false,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Center(
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.inputBackground,
                          backgroundImage: hasAvatar ? NetworkImage(url) : null,
                          child: hasAvatar
                              ? null
                              : const Icon(Icons.person_rounded, size: 20, color: AppColors.iconMuted),
                        ),
                      ),
                    ),
                    leadingWidth: 56,
                    centerTitle: true,
                    titleSpacing: 0,
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Событие',
                          style: AppTextStyle.base(
                            18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'пока без публикации',
                          style: AppTextStyle.base(
                            13,
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      AppOverflowMenu<String>(
                        iconColor: AppColors.textColor,
                        iconPadding: const EdgeInsets.only(right: 8),
                        items: const [
                          AppOverflowMenuItem(
                            value: 'archive',
                            title: 'Архивировать',
                            icon: Icons.archive_outlined,
                          ),
                          AppOverflowMenuItem(
                            value: 'delete',
                            title: 'Удалить',
                            icon: Icons.delete_outline_rounded,
                            titleColor: AppColors.destructive,
                            iconColor: AppColors.destructive,
                          ),
                        ],
                        onSelected: (v) async {
                          if (v == 'archive') {
                            await sl<ProfileMarkersRepository>().setMarkerArchived(markerId: markerId, archived: true);
                            if (!context.mounted) return;
                            AppSnackBar.show(context, message: 'Маркер в архиве', kind: AppSnackBarKind.success);
                            Navigator.of(context).maybePop(true);
                            return;
                          }
                          if (v == 'delete') {
                            final ok = await AppDialog.showConfirm(
                              context: context,
                              title: 'Удалить маркер?',
                              message: 'Маркер исчезнет из профиля и карты. Это действие нельзя отменить.',
                              confirmLabel: 'Удалить',
                              confirmIsDestructive: true,
                            );
                            if (ok != true || !context.mounted) return;
                            await sl<ProfileMarkersRepository>().deleteMarker(markerId);
                            if (!context.mounted) return;
                            AppSnackBar.show(context, message: 'Маркер удалён', kind: AppSnackBarKind.success);
                            Navigator.of(context).maybePop(true);
                          }
                        },
                      )
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(kPostHeroRadiusExpanded),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final w = c.maxWidth;
                                final h = (w / aspectRatio).clamp(w * 0.5, w * 2.0);
                                return SizedBox(
                                  width: double.infinity,
                                  height: h,
                                  child: _MarkerHeroPlaceholder(
                                    emoji: markerDisplayEmoji(textEmoji),
                                    heroHeight: h,
                                    subtitle: hasPlace
                                        ? 'Оформите пост с фото — детали события ниже'
                                        : (hasEmoji
                                              ? 'Добавьте публикацию — расскажите, что на маркере'
                                              : 'Создайте пост, чтобы прикрепить фото и рассказ'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          MarkerEventMetaCard(
                            status: status,
                            eventTime: event,
                            endTime: end,
                            place: hasPlace ? placeTitle : null,
                            emoji: textEmoji,
                          ),
                          SizedBox(height: AppPillBackNavOverlay.scrollBottomInset(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MarkerHeroPlaceholder extends StatelessWidget {
  const _MarkerHeroPlaceholder({required this.emoji, required this.heroHeight, required this.subtitle});

  /// Символ маркера (как раньше) — не аватар профиля.
  final String emoji;
  final double heroHeight;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientTopSoftGreen,
            AppColors.surfaceSoftGreen,
            AppColors.pageBackground.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(color: AppColors.borderCardGreen.withValues(alpha: 0.55)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -heroHeight * 0.12,
            top: -heroHeight * 0.05,
            child: IgnorePointer(
              child: Container(
                width: heroHeight * 0.45,
                height: heroHeight * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (heroHeight * 0.24).clamp(64, 128),
                      height: 1,
                      shadows: [
                        Shadow(
                          color: AppColors.textColor.withValues(alpha: 0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.base(
                      15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subTextColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

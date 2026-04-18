import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_button.dart';
import 'package:side_project/core/storage/prefs/profile_follow_status_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/comment/presentation/widget/post_comments_sheet.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:side_project/feature/followers_page/presentation/cubit/follow_mutation_cubit.dart';
import 'package:side_project/feature/login_page/presentation/cubit/auth_cubit.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';
import 'package:side_project/feature/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:side_project/feature/posts/presentation/widget/post_savers_sheet.dart';
import 'package:side_project/feature/posts/presentation/widget/posts_section.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.post, this.initialIsSaved});

  final PostModel post;

  /// Из enriched-ленты / сохранённого: сразу как в сетке, до ответа `get_post_enriched`.
  /// `null` — неизвестно, подставим из локального кэша или RPC.
  final bool? initialIsSaved;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostDetailCubit _cubit;
  late final PageController _pageController;
  int _pageIndex = 0;
  late PostModel _post;
  PostReaction _reaction = PostReaction.none;
  String? _authorUsername;
  String? _authorAvatarUrl;
  bool? _isFollowingAuthor;

  /// Был хотя бы один `loaded` из кубита (чтобы поздний read Isar не затёр данные с сервера).
  bool _authorDrivenByCubit = false;
  bool _isSaved = false;
  String? _error;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    log(widget.post.media.toString());
    _post = widget.post;
    if (widget.initialIsSaved != null) {
      _isSaved = widget.initialIsSaved!;
    }
    // Instant-ish: take cached reaction from Isar (async).
    unawaited(() async {
      final cachedKind = await sl<PostsRepository>().getCachedMyReactionKind(widget.post.id);
      if (!mounted || _authorDrivenByCubit) return;
      setState(() {
        _reaction = switch (cachedKind) {
          'like' => PostReaction.like,
          'dislike' => PostReaction.dislike,
          _ => PostReaction.none,
        };
      });
    }());
    // Как реакции: кэш «сохранено», если не передали с маршрута.
    if (widget.initialIsSaved == null) {
      unawaited(() async {
        final cachedSaved = await sl<PostsRepository>().getCachedIsPostSaved(widget.post.id);
        if (!mounted || _authorDrivenByCubit) return;
        if (cachedSaved != null) {
          setState(() => _isSaved = cachedSaved);
        }
      }());
    }

    // Быстро: локальный кэш "подписан ли я на автора".
    unawaited(() async {
      final uid = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
      if (uid == null || uid.isEmpty) return;
      final cached = await sl<ProfileFollowStatusPrefsStorage>().readCachedForTarget(uid, widget.post.userId);
      if (!mounted) return;
      if (cached != null) setState(() => _isFollowingAuthor = cached);
    }());

    // Догрузка с сервера (один RPC) — обновит кэш.
    unawaited(() async {
      final uid = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
      if (uid == null || uid.isEmpty) return;
      try {
        final v = await sl<FollowListRepository>().isFollowing(widget.post.userId);
        await sl<ProfileFollowStatusPrefsStorage>().setCached(uid, widget.post.userId, v);
        if (!mounted) return;
        setState(() => _isFollowingAuthor = v);
      } catch (_) {}
    }());

    // Как реакции: сразу дернуть батч‑префетч (если кэш пуст — данные подтянутся параллельно).
    if (widget.post.userId.trim().isNotEmpty) {
      unawaited(sl<ProfileRepository>().prefetchMiniProfilesForUserIds([widget.post.userId]));
    }

    // Быстрый первый кадр из Isar. Не трогаем шапку, если кубит уже выставил ник/аватар (в т.ч. с сервера).
    unawaited(() async {
      final cached = await sl<ProfileMiniCacheStorage>().read(widget.post.userId);
      if (!mounted || cached == null) return;
      if (_authorDrivenByCubit && (_authorUsername != null || _authorAvatarUrl != null)) return;
      final nu = _headerField(cached.username);
      final na = _headerField(cached.avatarUrl);
      if (_authorUsername == nu && _authorAvatarUrl == na) return;
      setState(() {
        _authorUsername = nu;
        _authorAvatarUrl = na;
      });
    }());
    // Load from backend without emitting loading (avoid 1s "empty" state).
    _cubit = sl<PostDetailCubit>()..load(widget.post.id, emitLoading: false);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _cubit.close();
    _pageController.dispose();
    super.dispose();
  }

  static String? _headerField(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  void _openComments(PostModel post) {
    final auth = sl<AuthCubit>().state;
    final canCompose = auth.maybeWhen(authenticated: (_) => true, orElse: () => false);
    final avatarUrl = auth.maybeWhen(authenticated: (u) => u.avatarUrl, orElse: () => null);
    unawaited(
      PostCommentsSheet.show(context, postId: post.id, composerAvatarUrl: avatarUrl, canCompose: canCompose),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
    final isAuthor = myId != null && myId == _post.userId;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<PostDetailCubit, PostDetailState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            notFound: () => setState(() => _notFound = true),
            error: (m) => setState(() => _error = m),
            loaded: (post, reaction, authorUsername, authorAvatarUrl, isSaved) => setState(() {
              _authorDrivenByCubit = true;
              _post = post;
              _reaction = reaction;
              _isSaved = isSaved;
              // Сервер (и кэш в первом emit кубита) — источник истины; UI трогаем только если строки реально изменились.
              final nu = _headerField(authorUsername);
              final na = _headerField(authorAvatarUrl);
              if (_authorUsername != nu || _authorAvatarUrl != na) {
                _authorUsername = nu;
                _authorAvatarUrl = na;
              }
              _error = null;
              _notFound = false;
            }),
          );
        },
        child: Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: _notFound
              ? const _PostDetailScaffoldMessage(message: 'Пост не найден')
              : (_error != null
                    ? _PostDetailScaffoldMessage(message: _error!)
                    : _PostDetailScaffold(
                        post: _post,
                        reaction: _reaction,
                        authorUsername: _authorUsername,
                        authorAvatarUrl: _authorAvatarUrl,
                        authorId: _post.userId,
                        isFollowingAuthor: _isFollowingAuthor,
                        onFollowingChanged: (v) => setState(() => _isFollowingAuthor = v),
                        isSaved: _isSaved,
                        isAuthor: isAuthor,
                        onOpenSavers: isAuthor
                            ? () {
                                unawaited(PostSaversSheet.show(context, postId: _post.id));
                              }
                            : null,
                        pageController: _pageController,
                        pageIndex: _pageIndex,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        onOpenComments: () => _openComments(_post),
                        onLike: () {
                          _cubit.toggleLike();
                        },
                        onDislike: () {
                          _cubit.toggleDislike();
                        },
                        onBookmark: () async {
                          final ok = sl<AuthCubit>().state.maybeWhen(
                            authenticated: (_) => true,
                            orElse: () => false,
                          );
                          if (!ok) {
                            if (!context.mounted) return;
                            AppSnackBar.show(
                              context,
                              message: 'Войдите, чтобы сохранять посты',
                              kind: AppSnackBarKind.info,
                            );
                            return;
                          }
                          await _cubit.toggleSave();
                        },
                      )),
        ),
      ),
    );
  }
}

/// Формат чисел в духе Instagram: до 9 999 — с разделителем групп по локали; от 10 000 — компакт (12K, 1.2M).
String _formatInstaCount(int n, BuildContext context) {
  var v = n;
  if (v < 0) v = 0;
  final tag = Localizations.localeOf(context).toLanguageTag();
  if (v < 10000) {
    return NumberFormat.decimalPattern(tag).format(v);
  }
  return NumberFormat.compact(locale: tag).format(v);
}

class _PostDetailScaffold extends StatelessWidget {
  const _PostDetailScaffold({
    required this.post,
    required this.reaction,
    required this.authorUsername,
    required this.authorAvatarUrl,
    required this.authorId,
    required this.isFollowingAuthor,
    required this.onFollowingChanged,
    required this.isSaved,
    required this.isAuthor,
    this.onOpenSavers,
    required this.pageController,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onOpenComments,
    required this.onLike,
    required this.onDislike,
    required this.onBookmark,
  });

  final PostModel post;
  final PostReaction reaction;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String authorId;
  final bool? isFollowingAuthor;
  final ValueChanged<bool> onFollowingChanged;
  final bool isSaved;
  final bool isAuthor;
  final VoidCallback? onOpenSavers;
  final PageController pageController;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenComments;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final Future<void> Function() onBookmark;

  Future<void> _openPostActionsSheet(BuildContext context) async {
    final action = await AppBottomSheet.show<String>(
      context: context,
      title: 'Действия',
      upperCaseTitle: false,
      contentBottomSpacing: 16,
      content: Builder(
        builder: (sheetContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  post.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                  color: AppColors.textColor,
                ),
                title: Text(
                  post.isArchived ? 'Разархивировать' : 'Архивировать',
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                ),
                onTap: () => Navigator.of(sheetContext).pop('archive'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  'Удалить',
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w700, color: AppColors.error),
                ),
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
            ],
          );
        },
      ),
    );
    if (!context.mounted) return;
    if (action == 'archive') {
      await context.read<PostDetailCubit>().setArchived(!post.isArchived);
      return;
    }
    if (action == 'delete') {
      final ok = await AppDialog.showConfirm(
        context: context,
        title: 'Удалить пост?',
        message: 'Пост будет удалён навсегда (включая медиа).',
        confirmLabel: 'Удалить',
        confirmIsDestructive: true,
      );
      if (ok == true && context.mounted) {
        await context.read<PostDetailCubit>().delete();
        if (context.mounted) {
          Navigator.of(context).maybePop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = post.media.map((m) => m.url).where((u) => u.isNotEmpty).toList();
    final String? subtitle = (post.subtitle?.trim().isNotEmpty ?? false) ? post.subtitle!.trim() : null;
    final String? description = (post.description?.trim().isNotEmpty ?? false)
        ? post.description!.trim()
        : null;
    final String? title = (post.title?.trim().isNotEmpty ?? false) ? post.title!.trim() : null;
    // Default when URL doesn't include `__ar-<w>x<h>` suffix.
    const aspectRatio = 1.0;
    final username = authorUsername?.trim();
    final usernameDisplay = (username != null && username.isNotEmpty) ? username : '';
    final avatarUrl = authorAvatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return AppPillBackNavOverlay(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Верхняя шапка (без кнопки назад)
          SliverAppBar(
            backgroundColor: AppColors.pageBackground,
            elevation: 0,
            pinned: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceSoft,
                  backgroundImage: hasAvatar ? CachedNetworkImageProvider(avatarUrl) : null,
                  child: hasAvatar
                      ? null
                      : Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.subTextColor.withValues(alpha: 0.8),
                          size: 20,
                        ),
                ),
              ),
            ),
            leadingWidth: 56,
            centerTitle: true,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Публикация',
                  style: AppTextStyle.base(18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                ),
                const SizedBox(height: 2),
                if (usernameDisplay.isNotEmpty)
                  Text(
                    usernameDisplay,
                    style: AppTextStyle.base(13, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: _AuthorFollowButton(
                    authorId: authorId,
                    initialIsFollowing: isFollowingAuthor,
                    onChanged: onFollowingChanged,
                  ),
                ),
              ),
            ],
          ),

          // ГЛАВНАЯ КАРТОЧКА (Pinterest Pin)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ФОТО С БОЛЬШИМ РАДИУСОМ
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kPostHeroRadiusExpanded),
                    child: Stack(
                      children: [
                        _AdaptiveMediaPager(
                          urls: urls,
                          pageIndex: pageIndex,
                          onPageChanged: onPageChanged,
                          pageController: pageController,
                          heroPostId: post.id,
                          aspectRatio: aspectRatio,
                          onLike: onLike,
                          onDislike: onDislike,
                        ),
                        if (isAuthor)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.black.withValues(alpha: 0.35),
                                border: Border.all(color: AppColors.white.withValues(alpha: 0.20)),
                              ),
                              child: IconButton(
                                onPressed: () => _openPostActionsSheet(context),
                                icon: Icon(AppIcons.more.icon),
                                color: AppColors.textInverse,
                                iconSize: 22,
                              ),
                            ),
                          ),
                        // Индикатор страниц (точки)
                        if (urls.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                urls.length,
                                (i) => _PinterestDot(isActive: i == pageIndex),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // БЛОК ДЕЙСТВИЙ: счётчик справа от иконки в одной линии
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 12, bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.favorite_border_rounded,
                          activeIcon: Icons.favorite_rounded,
                          isActive: reaction == PostReaction.like,
                          activeColor: Colors.red,
                          countText: _formatInstaCount(post.likesCount, context),
                          onTap: onLike,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.thumb_down_alt_outlined,
                          activeIcon: Icons.thumb_down_rounded,
                          isActive: reaction == PostReaction.dislike,
                          activeColor: Colors.orangeAccent,
                          outlinedWhenInactive: false,
                          countText: _formatInstaCount(post.dislikesCount, context),
                          onTap: onDislike,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.mode_comment_outlined,
                          countText: _formatInstaCount(post.commentsCount, context),
                          onTap: onOpenComments,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.near_me_rounded,
                          countText: _formatInstaCount(post.sendsCount, context),
                          onTap: () {
                            context.router.root.push(const ChatListRoute());
                          },
                        ),
                        const Spacer(),
                        _ActionButton(
                          icon: Icons.bookmark_border_rounded,
                          activeIcon: Icons.bookmark_rounded,
                          isActive: isSaved,
                          activeColor: AppColors.textColor,
                          onTap: () {
                            unawaited(onBookmark());
                          },
                        ),
                      ],
                    ),
                  ),

                  // ТЕКСТОВЫЙ КОНТЕНТ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(title, style: AppTextStyle.base(18, fontWeight: FontWeight.w700, height: 1.2)),
                        if (subtitle != null) ...[
                          if (title != null) const SizedBox(height: 10),
                          _PostTextTile(text: subtitle, kind: _PostTextTileKind.subtitle),
                        ],
                        if (description != null) ...[
                          if (title != null || subtitle != null) const SizedBox(height: 10),
                          _PostTextTile(text: description, kind: _PostTextTileKind.description),
                        ],
                        SizedBox(height: AppPillBackNavOverlay.scrollBottomInset(context)),
                      ],
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

enum _PostTextTileKind { subtitle, description }

class _PostTextTile extends StatelessWidget {
  const _PostTextTile({required this.text, required this.kind});

  final String text;
  final _PostTextTileKind kind;

  @override
  Widget build(BuildContext context) {
    final style = switch (kind) {
      _PostTextTileKind.subtitle => AppTextStyle.base(
        16,
        fontWeight: FontWeight.w400,
        color: AppColors.textColor.withValues(alpha: 0.5),
        height: 1,
      ),
      _PostTextTileKind.description => AppTextStyle.base(
        16,
        fontWeight: FontWeight.w500,

        color: AppColors.textColor.withValues(alpha: 0.86),
        height: 1,
      ),
    };

    return Text(text, style: style);
  }
}

class _PinterestDot extends StatelessWidget {
  final bool isActive;
  const _PinterestDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.textInverse : AppColors.textInverse.withValues(alpha: 0.5),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;
  final bool outlinedWhenInactive;

  /// Число справа от иконки (лайки, комментарии…).
  final String? countText;
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.activeIcon,
    this.activeColor,
    this.outlinedWhenInactive = false,
    this.countText,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? AppColors.error;
    final inactive = AppColors.textColor.withValues(alpha: 0.9);
    final iconData = widget.isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;
    final iconLayer = widget.outlinedWhenInactive
        ? Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                iconData,
                size: 28,
                color: widget.isActive ? active.withValues(alpha: 0.95) : inactive.withValues(alpha: 0.65),
              ),
              Icon(iconData, size: 26, color: widget.isActive ? active : Colors.transparent),
            ],
          )
        : Icon(iconData, size: 26, color: widget.isActive ? active : inactive);

    final iconPadded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: iconLayer,
    );

    final tappableIcon = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: iconPadded),
    );

    if (widget.countText == null || widget.countText!.isEmpty) {
      return tappableIcon;
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScaleTransition(scale: _scaleAnimation, child: iconPadded),
          const SizedBox(width: 6),
          Text(
            widget.countText!,
            style: AppTextStyle.base(
              14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
              height: 1.2,
            ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveMediaPager extends StatefulWidget {
  const _AdaptiveMediaPager({
    required this.urls,
    required this.pageIndex,
    required this.onPageChanged,
    required this.pageController,
    required this.heroPostId,
    required this.aspectRatio,
    required this.onLike,
    required this.onDislike,
  });

  final List<String> urls;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;
  final String heroPostId;
  final double aspectRatio;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  @override
  State<_AdaptiveMediaPager> createState() => _AdaptiveMediaPagerState();
}

class _AdaptiveMediaPagerState extends State<_AdaptiveMediaPager> {
  late int _currentIndex;
  int _tapCount = 0;
  Timer? _tapTimer;
  _BurstKind? _burst;
  Timer? _burstTimer;

  static const _ratioMin = 0.55;
  static const _ratioMax = 1.6;
  static final _aspectRe = RegExp(r'__ar-(\d+)x(\d+)', caseSensitive: false);
  static const _tapWindow = Duration(milliseconds: 320);
  static const _burstDuration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.pageIndex;
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _burstTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AdaptiveMediaPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _currentIndex = widget.pageIndex;
    }
  }

  void _registerTap() {
    _tapCount += 1;
    _tapTimer?.cancel();
    _tapTimer = Timer(_tapWindow, () {
      final c = _tapCount;
      _tapCount = 0;
      if (!mounted) return;
      if (c >= 3) {
        _triggerDislikeBurst();
        widget.onDislike();
        return;
      }
      if (c == 2) {
        _triggerLikeBurst();
        widget.onLike();
      }
    });
  }

  void _triggerLikeBurst() {
    _burstTimer?.cancel();
    setState(() => _burst = _BurstKind.like);
    _burstTimer = Timer(_burstDuration, () {
      if (!mounted) return;
      setState(() => _burst = null);
    });
  }

  void _triggerDislikeBurst() {
    _burstTimer?.cancel();
    setState(() => _burst = _BurstKind.dislike);
    _burstTimer = Timer(_burstDuration, () {
      if (!mounted) return;
      setState(() => _burst = null);
    });
  }

  String _activeUrl(List<String> urls, {int? pageIndex}) {
    if (urls.isEmpty) return '';
    final i = (pageIndex ?? _currentIndex).clamp(0, urls.length - 1);
    return urls[i];
  }

  double? _ratioFromUrl(String url) {
    if (url.isEmpty) return null;
    final u = Uri.tryParse(url);
    final path = (u?.path ?? url).toLowerCase();
    final m = _aspectRe.firstMatch(path);
    if (m == null) return null;
    final w = int.tryParse(m.group(1) ?? '');
    final h = int.tryParse(m.group(2) ?? '');
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

  bool _isVideoUrl(String url) {
    if (url.isEmpty) return false;
    final u = Uri.tryParse(url);
    final path = (u?.path ?? url).toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.m4v') || path.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    final activeUrl = _activeUrl(urls);
    final aspectRatio = (_ratioFromUrl(activeUrl) ?? widget.aspectRatio).clamp(_ratioMin, _ratioMax);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        // Allow visible differences between presets (e.g. 1:1 vs 9:16).
        // Allow wide formats like 16:9 to be visibly shorter too.
        final h = (w / aspectRatio).clamp(w * 0.50, w * 2.0);
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            height: h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _registerTap,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: widget.pageController,
                    onPageChanged: (i) {
                      setState(() => _currentIndex = i);
                      widget.onPageChanged(i);
                      assert(() {
                        final u = _activeUrl(widget.urls);
                        final r = _ratioFromUrl(u);
                        debugPrint('PostDetail pager: index=$i url=${u.split('/').last} ratio=$r');
                        return true;
                      }());
                    },
                    itemCount: urls.isEmpty ? 1 : urls.length,
                    itemBuilder: (context, i) {
                      final url = urls.isEmpty ? '' : urls[i];
                      if (url.isEmpty) {
                        return const PostMediaFramePlaceholder(shimmer: true);
                      }
                      if (_isVideoUrl(url)) {
                        return _NetworkVideoFrame(
                          url: url,
                          shimmerPlaceholder: const PostMediaFramePlaceholder(shimmer: true),
                        );
                      }
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => const PostMediaFramePlaceholder(shimmer: true),
                        errorWidget: (_, __, ___) => const PostMediaFramePlaceholder(shimmer: false),
                        fadeInDuration: const Duration(milliseconds: 180),
                        fadeOutDuration: Duration.zero,
                        imageBuilder: (context, provider) {
                          final img = Image(image: provider, fit: BoxFit.cover, width: double.infinity);
                          if (i != 0) return img;
                          return buildPostHero(postId: widget.heroPostId, child: img);
                        },
                      );
                    },
                  ),
                  IgnorePointer(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 140),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _burst == null
                            ? const SizedBox.shrink()
                            : _InstaBurst(key: ValueKey(_burst), kind: _burst!),
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

class _NetworkVideoFrame extends StatefulWidget {
  const _NetworkVideoFrame({required this.url, required this.shimmerPlaceholder});

  final String url;
  final Widget shimmerPlaceholder;

  @override
  State<_NetworkVideoFrame> createState() => _NetworkVideoFrameState();
}

class _NetworkVideoFrameState extends State<_NetworkVideoFrame> {
  VideoPlayerController? _c;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void didUpdateWidget(covariant _NetworkVideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_init());
    }
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prev = _c;
    _c = null;
    await prev?.dispose();

    try {
      final uri = Uri.parse(widget.url);
      final c = VideoPlayerController.networkUrl(uri);
      _c = c;
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return widget.shimmerPlaceholder;

    final c = _c;
    if (_error != null || c == null || !c.value.isInitialized) {
      // Вместо "белого квадрата" — понятная заглушка.
      return ColoredBox(
        color: AppColors.surfaceSoft,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 44,
                  color: AppColors.subTextColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 10),
                Text(
                  'Не удалось загрузить видео',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.base(14, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _init, child: const Text('Повторить')),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
        ),
        // Если видео буферизуется — показываем лёгкий оверлей, а не белый экран.
        if (c.value.isBuffering)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.08),
            child: const Center(child: PostMediaFramePlaceholder(shimmer: true)),
          ),
      ],
    );
  }
}

enum _BurstKind { like, dislike }

class _InstaBurst extends StatefulWidget {
  const _InstaBurst({super.key, required this.kind});
  final _BurstKind kind;

  @override
  State<_InstaBurst> createState() => _InstaBurstState();
}

class _InstaBurstState extends State<_InstaBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
    ]).animate(_c);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.kind == _BurstKind.like ? Icons.favorite : Icons.thumb_down;
    final color = widget.kind == _BurstKind.like ? AppColors.error : AppColors.textInverse;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Icon(
              icon,
              size: 110,
              color: color,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  color: AppColors.black.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostDetailScaffoldMessage extends StatelessWidget {
  const _PostDetailScaffoldMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: AppTextStyle.base(14, color: AppColors.subTextColor)),
    );
  }
}

class _AuthorFollowButton extends StatelessWidget {
  const _AuthorFollowButton({
    required this.authorId,
    required this.initialIsFollowing,
    required this.onChanged,
  });

  final String authorId;
  final bool? initialIsFollowing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
    final isSelf = currentUserId != null && currentUserId == authorId;
    if (isSelf) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => sl<FollowMutationCubit>(),
      child: _AuthorFollowButtonBody(
        authorId: authorId,
        initialIsFollowing: initialIsFollowing,
        onChanged: onChanged,
      ),
    );
  }
}

class _AuthorFollowButtonBody extends StatelessWidget {
  const _AuthorFollowButtonBody({
    required this.authorId,
    required this.initialIsFollowing,
    required this.onChanged,
  });

  final String authorId;
  final bool? initialIsFollowing;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowMutationCubit, FollowMutationState>(
      listener: (context, state) async {
        state.whenOrNull(
          success: () async {
            // Переключаем локально + пишем кэш.
            final uid = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
            final was = initialIsFollowing ?? false;
            final next = !was;
            if (uid != null && uid.isNotEmpty) {
              await sl<ProfileFollowStatusPrefsStorage>().setCached(uid, authorId, next);
            }
            onChanged(next);
            if (context.mounted) {
              context.read<FollowMutationCubit>().reset();
            }
          },
          failure: (msg) {
            AppSnackBar.show(context, message: msg, kind: AppSnackBarKind.error);
            context.read<FollowMutationCubit>().reset();
          },
        );
      },
      builder: (context, state) {
        final busy = state.maybeWhen(inProgress: () => true, orElse: () => false);
        final isFollowing = initialIsFollowing ?? false;

        final label = (initialIsFollowing == null) ? '...' : (isFollowing ? 'Отписаться' : 'Подписаться');

        return AppTextButton(
          text: label,
          onPressed: (busy || initialIsFollowing == null)
              ? () {}
              : () {
                  final cubit = context.read<FollowMutationCubit>();
                  if (isFollowing) {
                    cubit.unfollow(authorId);
                  } else {
                    cubit.follow(authorId);
                  }
                },
        );
      },
    );
  }
}

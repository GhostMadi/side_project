import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/media/media_service.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_dialog.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/core/shared/app_shimmer.dart';
import 'package:side_project/core/shared/app_snack_bar.dart';
import 'package:side_project/core/shared/app_text_button.dart';
import 'package:side_project/core/shared/marker_event_meta_card.dart'
    show
        MarkerEventDisplayStyle,
        MarkerEventMetaCard,
        markerDisplayEmoji,
        markerEffectiveStatus,
        markerEventStatusPillContext;
import 'package:side_project/core/storage/prefs/profile_follow_status_prefs_storage.dart';
import 'package:side_project/core/storage/prefs/profile_mini_cache_storage.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
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
import 'package:video_player/video_player.dart';

part 'post_detail_follow.part.dart';
part 'post_detail_media.part.dart';

@RoutePage()
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.post, this.initialIsSaved, this.embedded = false});

  final PostModel post;

  /// Из enriched-ленты / сохранённого: сразу как в сетке, до ответа `get_post_enriched`.
  /// `null` — неизвестно, подставим из локального кэша или RPC.
  final bool? initialIsSaved;

  /// Если true — используем тот же "вид поста", но без Scaffold-обёртки (для списков/лент).
  final bool embedded;

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
  bool? _initialIsFollowingAuthor;

  /// Был хотя бы один `loaded` из кубита (чтобы поздний read Isar не затёр данные с сервера).
  bool _authorDrivenByCubit = false;
  bool _isSaved = false;
  String? _error;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
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
      if (cached != null) {
        setState(() {
          _isFollowingAuthor = cached;
          _initialIsFollowingAuthor ??= cached;
        });
      }
    }());

    // Догрузка с сервера (один RPC) — обновит кэш.
    unawaited(() async {
      final uid = sl<AuthCubit>().state.maybeWhen(authenticated: (u) => u.id, orElse: () => null);
      if (uid == null || uid.isEmpty) return;
      try {
        final v = await sl<FollowListRepository>().isFollowing(widget.post.userId);
        await sl<ProfileFollowStatusPrefsStorage>().setCached(uid, widget.post.userId, v);
        if (!mounted) return;
        setState(() {
          _isFollowingAuthor = v;
          _initialIsFollowingAuthor ??= v;
        });
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
        child: widget.embedded
            ? ColoredBox(
                color: AppColors.pageBackground,
                child: _notFound
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
                              initialIsFollowingAuthor: _initialIsFollowingAuthor,
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
                              showBackPill: false,
                              allowInnerScroll: false,
                            )),
              )
            : Scaffold(
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
                              initialIsFollowingAuthor: _initialIsFollowingAuthor,
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
                              showBackPill: true,
                              allowInnerScroll: true,
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
    required this.initialIsFollowingAuthor,
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
    required this.showBackPill,
    required this.allowInnerScroll,
  });

  final PostModel post;
  final PostReaction reaction;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String authorId;
  final bool? isFollowingAuthor;
  final bool? initialIsFollowingAuthor;
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
  final bool showBackPill;
  final bool allowInnerScroll;

  Future<void> _openPostActionsSheet(BuildContext context) async {
    final hasMarker = post.markerId != null && post.markerId!.trim().isNotEmpty;
    final targetArchived = hasMarker ? (post.marker?.isArchived ?? false) : post.isArchived;
    final markerArchiveReady = !hasMarker || post.marker != null;
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
                  targetArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                  color: AppColors.textColor,
                ),
                title: Text(
                  targetArchived ? 'Разархивировать' : 'Архивировать',
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                ),
                subtitle: markerArchiveReady
                    ? null
                    : Text(
                        'Загружаем данные события…',
                        style: AppTextStyle.base(12, color: AppColors.subTextColor),
                      ),
                onTap: markerArchiveReady ? () => Navigator.of(sheetContext).pop('archive') : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.account_tree_outlined, color: AppColors.textColor),
                title: Text(
                  'Кластер',
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                ),
                subtitle: Text(
                  post.clusterId != null && post.clusterId!.trim().isNotEmpty
                      ? 'Привязан к кластеру'
                      : 'Не в кластере',
                  style: AppTextStyle.base(13, color: AppColors.subTextColor),
                ),
                onTap: () => Navigator.of(sheetContext).pop('cluster'),
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
      await context.read<PostDetailCubit>().setArchived(!targetArchived);
      return;
    }
    if (action == 'cluster') {
      await _openPostClusterSheet(context);
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

  Future<void> _openPostClusterSheet(BuildContext outerContext) async {
    List<ClusterModel>? clusters;
    Object? loadError;
    try {
      clusters = await sl<ClusterRepository>().listActiveByOwnerId(post.userId);
    } catch (e) {
      loadError = e;
    }
    if (!outerContext.mounted) return;
    if (loadError != null) {
      AppSnackBar.show(
        outerContext,
        message: 'Не удалось загрузить кластеры: $loadError',
        kind: AppSnackBarKind.error,
      );
      return;
    }
    final list = clusters ?? const <ClusterModel>[];
    final currentRaw = post.clusterId?.trim();
    final currentId = (currentRaw != null && currentRaw.isNotEmpty) ? currentRaw : null;
    ClusterModel? currentMeta;
    if (currentId != null) {
      for (final c in list) {
        if (c.id == currentId) {
          currentMeta = c;
          break;
        }
      }
    }

    await AppBottomSheet.show<void>(
      context: outerContext,
      title: 'Кластер',
      upperCaseTitle: false,
      contentBottomSpacing: 16,
      content: Builder(
        builder: (sheetContext) {
          final cubit = outerContext.read<PostDetailCubit>();
          final pickable = list.where((c) => c.id != currentId).toList();

          Future<void> afterChange(Future<void> Function() fn, String okMessage) async {
            await fn();
            if (!sheetContext.mounted) return;
            final failed = cubit.state.maybeWhen(error: (_) => true, orElse: () => false);
            Navigator.of(sheetContext).pop();
            if (!outerContext.mounted) return;
            if (!failed) {
              AppSnackBar.show(outerContext, message: okMessage, kind: AppSnackBarKind.success);
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentId != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: false,
                    leading: Icon(Icons.folder_special_outlined, color: AppColors.subTextColor),
                    title: Text(switch (currentMeta) {
                      ClusterModel(:final title) when title.trim().isNotEmpty => title.trim(),
                      _ => 'Привязанный кластер',
                    }, style: AppTextStyle.base(15, fontWeight: FontWeight.w700, color: AppColors.textColor)),
                    subtitle: currentMeta == null
                        ? Text(
                            'В списке не найден — можно отвязать.',
                            style: AppTextStyle.base(13, color: AppColors.subTextColor),
                          )
                        : Text(
                            currentMeta.postsCountLabel,
                            style: AppTextStyle.base(13, color: AppColors.subTextColor),
                          ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.link_off_rounded, color: AppColors.textColor),
                    title: Text(
                      'Убрать из кластера',
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                    onTap: () => afterChange(() => cubit.setPostCluster(null), 'Пост убран из кластера'),
                  ),
                  if (pickable.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        'Другой кластер',
                        style: AppTextStyle.base(
                          13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.subTextColor,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Привязать к кластеру',
                      style: AppTextStyle.base(
                        13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ),
                ],
                if (pickable.isEmpty && currentId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Нет активных кластеров. Создайте кластер в профиле.',
                      style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.35),
                    ),
                  ),
                ...pickable.map(
                  (c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.add_link_rounded, color: AppColors.primary),
                    title: Text(
                      c.title.trim().isEmpty ? 'Без названия' : c.title,
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                    subtitle: Text(
                      c.postsCountLabel,
                      style: AppTextStyle.base(13, color: AppColors.subTextColor),
                    ),
                    onTap: () => afterChange(() => cubit.setPostCluster(c.id), 'Пост привязан к кластеру'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailCubit, PostDetailState>(
      buildWhen: (p, c) => p != c,
      builder: (context, cubitState) {
        return _buildBody(context, cubitState: cubitState);
      },
    );
  }

  Widget _buildBody(BuildContext context, {required PostDetailState cubitState}) {
    final urls = post.media.map((m) => m.url).where((u) => u.isNotEmpty).toList();
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
    final markerExpected = (post.markerId?.trim().isNotEmpty ?? false);
    final markerReady = post.marker != null;
    final markerLoading = markerExpected && !markerReady;
    final markerEventWindow = markerReady ? post.resolvedMarkerEventWindow : null;

    final mid = post.markerId?.trim();
    final showAddLinkedPostFab = isAuthor && mid != null && mid.isNotEmpty;

    final content = CustomScrollView(
      primary: false,
      // В embedded режиме (лента) пост должен сжиматься по контенту,
      // иначе внутри ListView может не получить layout.
      shrinkWrap: !allowInnerScroll,
      physics: allowInnerScroll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      slivers: [
        // Верхняя шапка (без кнопки назад)
        SliverAppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          pinned: false,
          automaticallyImplyLeading: false,

          // 1. Убираем влияние статус-бара (если AppBar не должен его учитывать)
          // В обычном открытии (showBackPill=true) даём воздух сверху через status-bar inset.
          // В embedded-ленте оставляем "впритык" без дополнительной высоты.
          primary: showBackPill,

          // 2. Устанавливаем фиксированную высоту для всех состояний
          toolbarHeight: 60, // Минимально достаточная высота для аватара (36px) + отступы
          expandedHeight: 60,
          collapsedHeight: 60,

          leadingWidth: 0,
          centerTitle: false,
          titleSpacing: 12,

          // Используем FlexibleSpace, если Title обрезается.
          // Но в данном случае Title должен работать, если toolbarHeight > 0
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16, // Немного уменьшил радиус, чтобы не "съедался"
                backgroundColor: AppColors.surfaceSoft,
                backgroundImage: hasAvatar ? CachedNetworkImageProvider(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.subTextColor.withValues(alpha: 0.8),
                        size: 18,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  usernameDisplay.isNotEmpty ? usernameDisplay : 'Пользователь',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.base(16, fontWeight: FontWeight.w900, color: AppColors.textColor),
                ),
              ),
            ],
          ),

          // 3. Если bottom мешает, попробуй его временно убрать или
          // обернуть в PreferredSize с нулевой высотой, если он не загружается
          bottom: markerLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: AppColors.pageBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.45)),
                  ),
                )
              : null,

          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _AuthorFollowButton(
                  authorId: authorId,
                  initialIsFollowing: initialIsFollowingAuthor,
                  currentIsFollowing: isFollowingAuthor,
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
                      if (markerReady)
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: _MarkerStatusOverlayPill(
                            status: markerEffectiveStatus(
                              startLocal: markerEventWindow!.start.toLocal(),
                              endLocal: markerEventWindow.end.toLocal(),
                              storedStatus: post.marker!.status,
                            ),
                          ),
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

                // ТЕКСТ: шиммер, пока get_post_enriched не вернулся (и маркер/актуальные счётчики).
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        markerReady
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    markerDisplayEmoji(post.marker!.textEmoji),
                                    style: const TextStyle(fontSize: 24, height: 1.2),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.base(18, fontWeight: FontWeight.w700, height: 1.2),
                                    ),
                                  ),
                                  // const SizedBox(width: 8),
                                  // Text(
                                  //   markerDisplayEmoji(post.marker!.textEmoji),
                                  //   style: const TextStyle(fontSize: 24, height: 1.2),
                                  // ),
                                ],
                              )
                            : Text(
                                title,
                                style: AppTextStyle.base(18, fontWeight: FontWeight.w700, height: 1.2),
                              ),
                      if (markerLoading) ...[
                        if (title != null) const SizedBox(height: 8),
                        const _MarkerEventMetaInlineShimmer(),
                      ],
                      // Маркерные данные показываем только когда они реально догрузились.
                      if (markerReady) ...[
                        if (title != null) const SizedBox(height: 8),
                        MarkerEventMetaCard(
                          displayStyle: MarkerEventDisplayStyle.ticketInline,
                          status: post.marker!.status,
                          eventTime: markerEventWindow!.start,
                          endTime: markerEventWindow.end,
                          place: post.marker!.addressText,
                          emoji: post.marker!.textEmoji,
                        ),
                      ],
                      if (description != null) ...[
                        if (markerReady)
                          const SizedBox(height: 12)
                        else if (title != null)
                          const SizedBox(height: 10),
                        _PostTextTile(text: description, kind: _PostTextTileKind.description),
                      ],
                      // В embedded‑режиме посты идут подряд, без лишнего "хвоста" снизу.
                      SizedBox(height: showBackPill ? AppPillBackNavOverlay.scrollBottomInset(context) : 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    if (!showBackPill) return content;
    return AppPillBackNavOverlay(
      extraItems: [
        if (showAddLinkedPostFab)
          AppPillNavItem(
            icon: Icons.add_rounded,
            label: 'Пост',
            onTap: () => context.router.push(PostCreateRoute(markerId: mid)),
          ),
      ],
      child: content,
    );
  }
}

enum _PostTextTileKind { description }

class _PostTextTile extends StatelessWidget {
  const _PostTextTile({required this.text, required this.kind});

  final String text;
  final _PostTextTileKind kind;

  @override
  Widget build(BuildContext context) {
    final style = switch (kind) {
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

class _MarkerStatusOverlayPill extends StatelessWidget {
  const _MarkerStatusOverlayPill({required this.status});

  final String status;

  Color _contrastText(Color bg) {
    // Simple luminance-based contrast (0=dark, 1=light).
    return bg.computeLuminance() > 0.55 ? AppColors.textColor : AppColors.textInverse;
  }

  @override
  Widget build(BuildContext context) {
    final pill = markerEventStatusPillContext(status);
    final fg = _contrastText(pill.bg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: pill.bg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: pill.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          pill.shortLabel,
          style: AppTextStyle.base(12, fontWeight: FontWeight.w900, color: fg, height: 1.0),
        ),
      ),
    );
  }
}

class _MarkerEventMetaInlineShimmer extends StatelessWidget {
  const _MarkerEventMetaInlineShimmer();

  Widget _line(double w, {double height = 14}) {
    return Container(
      height: height,
      width: w,
      decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Approximate the final layout of MarkerEventMetaCard(ticketInline):
    // 1) start row (icon + text)
    // 2) place row (icon + text + copy icon)
    // 3) duration row (icon + text)
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 18, height: 18),
                  const SizedBox(width: 10),
                  Expanded(child: _line(w * 0.62, height: 16)),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 18, height: 18),
                  const SizedBox(width: 10),
                  Expanded(child: _line(w * 0.52, height: 15)),
                  const SizedBox(width: 10),
                  _line(18, height: 18),
                ],
              ),
              const SizedBox(height: 8),
              // Row 3
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 18, height: 18),
                  const SizedBox(width: 10),
                  Expanded(child: _line(w * 0.28, height: 15)),
                ],
              ),
            ],
          );
        },
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

// (moved to part files)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/feature/comment/data/models/comment_model.dart';
import 'package:side_project/feature/comment/data/repository/comments_repository.dart';
import 'package:side_project/feature/comment/presentation/cubit/post_comment_composer_cubit.dart';
import 'package:side_project/feature/comment/presentation/cubit/post_comments_list_cubit.dart';

/// Шторка комментариев на [AppBottomSheet]: список с пагинацией + отдельный композер.
abstract final class PostCommentsSheet {
  static Future<void> show(
    BuildContext context, {
    required String postId,
    String? composerAvatarUrl,
    bool canCompose = true,
  }) {
    final h = MediaQuery.sizeOf(context).height;
    return AppBottomSheet.show<void>(
      context: context,
      title: 'Комментарии',
      showCloseButton: true,
      upperCaseTitle: false,
      contentHeight: h * 0.62,
      contentBottomSpacing: 8,
      content: _PostCommentsSheetBody(
        postId: postId,
        composerAvatarUrl: composerAvatarUrl,
        canCompose: canCompose,
      ),
    );
  }
}

class _PostCommentsSheetBody extends StatelessWidget {
  const _PostCommentsSheetBody({required this.postId, this.composerAvatarUrl, required this.canCompose});

  final String postId;
  final String? composerAvatarUrl;
  final bool canCompose;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PostCommentsListCubit(sl<CommentsRepository>(), postId)..loadInitial()),
        BlocProvider(
          create: (ctx) => PostCommentComposerCubit(
            sl<CommentsRepository>(),
            postId,
            onPosted: (c) => ctx.read<PostCommentsListCubit>().prependComment(c),
          ),
        ),
      ],
      child: _PostCommentsSheetView(composerAvatarUrl: composerAvatarUrl, canCompose: canCompose),
    );
  }
}

class _PostCommentsSheetView extends StatefulWidget {
  const _PostCommentsSheetView({this.composerAvatarUrl, required this.canCompose});

  final String? composerAvatarUrl;
  final bool canCompose;

  @override
  State<_PostCommentsSheetView> createState() => _PostCommentsSheetViewState();
}

class _PostCommentsSheetViewState extends State<_PostCommentsSheetView> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scroll.position;
    if (!pos.hasViewportDimension) return;
    context.read<PostCommentsListCubit>().onScrollNearEnd(pos.pixels, pos.maxScrollExtent);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlocBuilder<PostCommentsListCubit, PostCommentsListState>(
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: AppCircularProgressIndicator(dimension: 32)),
                loading: () => const Center(child: AppCircularProgressIndicator(dimension: 32)),
                error: (m) => _CommentsError(
                  message: m,
                  onRetry: () => context.read<PostCommentsListCubit>().loadInitial(),
                ),
                loaded:
                    (
                      items,
                      _,
                      hasMore,
                      isLoadingMore,
                      replyThreads,
                      loadingRepliesForParentId,
                      myReactionByCommentId,
                    ) {
                      if (items.isEmpty) {
                        return ListView(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 120,
                              child: Center(
                                child: Text(
                                  'Пока нет комментариев.\nБудьте первым.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: items.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 24),
                              ),
                            );
                          }
                          return _CommentBranch(
                            comment: items[i],
                            depth: 0,
                            replyThreads: replyThreads,
                            loadingRepliesForParentId: loadingRepliesForParentId,
                            myReactionByCommentId: myReactionByCommentId,
                            canReact: widget.canCompose,
                          );
                        },
                      );
                    },
              );
            },
          ),
        ),
        if (widget.canCompose)
          BlocBuilder<PostCommentComposerCubit, PostCommentComposerState>(
            builder: (context, cState) {
              final replyLabel = cState.replyParentLabel;
              return _ComposerBlock(
                avatarUrl: widget.composerAvatarUrl,
                draft: cState.draft,
                isSending: cState.isSending,
                errorMessage: cState.errorMessage,
                replyBannerText: cState.replyParentCommentId != null
                    ? (replyLabel != null && replyLabel.isNotEmpty
                          ? 'Ответ $replyLabel'
                          : 'Ответ на комментарий')
                    : null,
                onClearReply: cState.replyParentCommentId != null
                    ? () => context.read<PostCommentComposerCubit>().clearReply()
                    : null,
                onDraftChanged: context.read<PostCommentComposerCubit>().setDraft,
                onSubmit: () => context.read<PostCommentComposerCubit>().submit(),
              );
            },
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'Войдите, чтобы оставить комментарий',
              textAlign: TextAlign.center,
              style: AppTextStyle.base(13, color: AppColors.subTextColor),
            ),
          ),
      ],
    );
  }
}

class _CommentsError extends StatelessWidget {
  const _CommentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.base(14, color: AppColors.error),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

String _commentAuthorLabel(CommentModel c) {
  final uname = c.author?.username?.trim();
  if (uname != null && uname.isNotEmpty) return uname;
  return 'Пользователь';
}

/// Склонение для кнопки «Показать N …» (рус.).
String _showRepliesButtonLabel(int n) {
  if (n <= 0) return 'Показать ответы';
  final mod10 = n % 10;
  final mod100 = n % 100;
  final String word;
  if (mod10 == 1 && mod100 != 11) {
    word = 'ответ';
  } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    word = 'ответа';
  } else {
    word = 'ответов';
  }
  return 'Показать $n $word';
}

String _formatCommentCount(int n, BuildContext context) {
  var v = n;
  if (v < 0) v = 0;
  final tag = Localizations.localeOf(context).toLanguageTag();
  if (v < 10000) {
    return NumberFormat.decimalPattern(tag).format(v);
  }
  return NumberFormat.compact(locale: tag).format(v);
}

String _commentTimeLabel(DateTime createdAt) {
  final now = DateTime.now().toUtc();
  final c = createdAt.toUtc();
  final diff = now.difference(c);
  if (diff.inSeconds < 45) return 'сейчас';
  if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
  if (diff.inHours < 24) return '${diff.inHours} ч';
  if (diff.inDays < 30) return '${diff.inDays} д';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} мес';
  return '${(diff.inDays / 365).floor()} г';
}

/// Рекурсивная ветка: комментарий, действия, дочерние ответы после [loadReplies].
class _CommentBranch extends StatelessWidget {
  const _CommentBranch({
    required this.comment,
    required this.depth,
    required this.replyThreads,
    required this.loadingRepliesForParentId,
    required this.myReactionByCommentId,
    required this.canReact,
  });

  final CommentModel comment;
  final int depth;
  final Map<String, List<CommentModel>> replyThreads;
  final String? loadingRepliesForParentId;
  final Map<String, String> myReactionByCommentId;
  final bool canReact;

  static const _maxVisualDepth = 8;
  static const _indent = 14.0;

  @override
  Widget build(BuildContext context) {
    final listCubit = context.read<PostCommentsListCubit>();
    final composer = context.read<PostCommentComposerCubit>();
    final id = comment.id;
    final myKind = myReactionByCommentId[id];
    final hasBranch = replyThreads.containsKey(id);
    final replies = hasBranch ? (replyThreads[id] ?? const <CommentModel>[]) : null;
    final loading = loadingRepliesForParentId == id;
    final showLoadButton = !hasBranch && comment.repliesCount > 0;
    final visualLeft = (depth > _maxVisualDepth ? _maxVisualDepth : depth) * _indent;

    return Padding(
      padding: EdgeInsets.only(left: visualLeft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CommentTile(
            comment: comment,
            onReply: () =>
                composer.startReply(parentCommentId: comment.id, parentLabel: _commentAuthorLabel(comment)),
            showLoadRepliesButton: showLoadButton,
            loadRepliesLabel: showLoadButton ? _showRepliesButtonLabel(comment.repliesCount) : null,
            onLoadReplies: showLoadButton ? () => listCubit.loadReplies(comment.id) : null,
            myReactionKind: myKind,
            canReact: canReact,
            onLike: canReact ? () => listCubit.toggleCommentLike(comment.id) : null,
            onDislike: canReact ? () => listCubit.toggleCommentDislike(comment.id) : null,
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(left: 52, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 18),
              ),
            ),
          if (hasBranch && replies != null) ...[
            if (replies.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52, bottom: 6),
                child: Text('Пока нет ответов', style: AppTextStyle.base(12, color: AppColors.subTextColor)),
              ),
            for (final r in replies)
              _CommentBranch(
                comment: r,
                depth: depth + 1,
                replyThreads: replyThreads,
                loadingRepliesForParentId: loadingRepliesForParentId,
                myReactionByCommentId: myReactionByCommentId,
                canReact: canReact,
              ),
          ],
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.showLoadRepliesButton,
    this.loadRepliesLabel,
    this.onLoadReplies,
    this.myReactionKind,
    required this.canReact,
    this.onLike,
    this.onDislike,
  });

  final CommentModel comment;
  final VoidCallback onReply;
  final bool showLoadRepliesButton;
  final String? loadRepliesLabel;
  final VoidCallback? onLoadReplies;
  final String? myReactionKind;
  final bool canReact;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  @override
  Widget build(BuildContext context) {
    final name = _commentAuthorLabel(comment);
    final url = comment.author?.avatarUrl?.trim();
    final time = _commentTimeLabel(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.inputBackground,
            child: url == null || url.isEmpty
                ? Icon(Icons.person_rounded, color: AppColors.subTextColor.withValues(alpha: 0.7))
                : ClipOval(
                    child: CachedNetworkImage(imageUrl: url, width: 36, height: 36, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(13, color: AppColors.textColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: AppTextStyle.base(12, color: AppColors.subTextColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTextStyle.base(14, color: AppColors.textColor, height: 1.35)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onReply,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.subTextColor,
                      ),
                      child: Text('Ответить', style: AppTextStyle.base(13, color: AppColors.primary)),
                    ),
                    if (showLoadRepliesButton && onLoadReplies != null && loadRepliesLabel != null)
                      TextButton(
                        onPressed: onLoadReplies,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          loadRepliesLabel!,
                          style: AppTextStyle.base(13, color: AppColors.subTextColor),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentReactionMini(
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                count: comment.likesCount,
                isActive: myReactionKind == 'like',
                activeColor: Colors.red,
                enabled: canReact,
                onTap: onLike,
              ),
              const SizedBox(width: 4),
              _CommentReactionMini(
                icon: Icons.thumb_down_alt_outlined,
                activeIcon: Icons.thumb_down_rounded,
                count: comment.dislikesCount,
                isActive: myReactionKind == 'dislike',
                activeColor: Colors.orangeAccent,
                enabled: canReact,
                onTap: onDislike,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentReactionMini extends StatelessWidget {
  const _CommentReactionMini({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = AppColors.subTextColor.withValues(alpha: 0.75);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, size: 18, color: isActive ? activeColor : inactive),
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    _formatCommentCount(count, context),
                    style: AppTextStyle.base(10, color: AppColors.subTextColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerBlock extends StatefulWidget {
  const _ComposerBlock({
    this.avatarUrl,
    required this.draft,
    required this.isSending,
    this.errorMessage,
    this.replyBannerText,
    this.onClearReply,
    required this.onDraftChanged,
    required this.onSubmit,
  });

  final String? avatarUrl;
  final String draft;
  final bool isSending;
  final String? errorMessage;
  final String? replyBannerText;
  final VoidCallback? onClearReply;
  final ValueChanged<String> onDraftChanged;
  final VoidCallback onSubmit;

  @override
  State<_ComposerBlock> createState() => _ComposerBlockState();
}

class _ComposerBlockState extends State<_ComposerBlock> {
  late final TextEditingController _controller;

  static const double _avatarR = 20;
  static const double _sendSize = 40;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _ComposerBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draft != _controller.text && widget.draft.isEmpty && oldWidget.draft != widget.draft) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.avatarUrl?.trim();
    final len = _controller.text.length;
    final maxLen = PostCommentComposerCubit.maxLength;
    final hasText = _controller.text.trim().isNotEmpty;
    final canSend = hasText && !widget.isSending;
    final showSendSlot = hasText || widget.isSending;

    // Как в Instagram: один фон с шторкой, без второго «блока» — только разделитель сверху.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 0.5, color: AppColors.border.withValues(alpha: 0.65)),
        if (widget.replyBannerText != null && widget.replyBannerText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Material(
              color: AppColors.inputBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 18, color: AppColors.subTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.replyBannerText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(13, color: AppColors.textColor, height: 1.25),
                      ),
                    ),
                    if (widget.onClearReply != null)
                      IconButton(
                        onPressed: widget.isSending ? null : widget.onClearReply,
                        icon: Icon(Icons.close_rounded, size: 20, color: AppColors.subTextColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(widget.errorMessage!, style: AppTextStyle.base(12, color: AppColors.error)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CircleAvatar(
                  radius: _avatarR,
                  backgroundColor: AppColors.inputBackground,
                  child: url == null || url.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 22,
                          color: AppColors.subTextColor.withValues(alpha: 0.75),
                        )
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: _avatarR * 2,
                            height: _avatarR * 2,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      enabled: !widget.isSending,
                      minLines: 1,
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: AppColors.primary,
                      style: AppTextStyle.base(15, color: AppColors.textColor, height: 1.35),
                      textInputAction: TextInputAction.newline,
                      onChanged: widget.onDraftChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.replyBannerText != null ? 'Ваш ответ…' : 'Комментарий…',
                        hintStyle: AppTextStyle.base(15, color: AppColors.subTextColor),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      ),
                    ),
                    if (len > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
                        child: Text(
                          '$len / $maxLen',
                          textAlign: TextAlign.right,
                          style: AppTextStyle.base(
                            11,
                            color: len > maxLen ? AppColors.error : AppColors.iconMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topRight,
                child: showSendSlot
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4, top: 10),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, v, child) {
                            return Opacity(
                              opacity: v,
                              child: Transform.translate(offset: Offset((1 - v) * 12, 0), child: child),
                            );
                          },
                          child: SizedBox(
                            width: _sendSize,
                            height: _sendSize,
                            child: widget.isSending
                                ? const Center(
                                    child: AppCircularProgressIndicator(strokeWidth: 2, dimension: 22),
                                  )
                                : Tooltip(
                                    message: 'Отправить',
                                    child: Material(
                                      color: canSend ? AppColors.primary : AppColors.inputBackground,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: canSend ? widget.onSubmit : null,
                                        child: Icon(
                                          Icons.send_rounded,
                                          size: 22,
                                          color: canSend ? AppColors.textInverse : AppColors.iconMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    : SizedBox(width: 0, height: 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

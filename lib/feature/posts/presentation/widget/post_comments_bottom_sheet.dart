import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class PostCommentUiModel {
  const PostCommentUiModel({
    required this.authorLabel,
    required this.text,
    this.timeLabel,
    this.likesCount,
    this.replies = const [],
  });

  final String authorLabel;
  final String text;
  final String? timeLabel;
  final int? likesCount;
  final List<PostCommentUiModel> replies;
}

/// Шторка комментариев (пока UI-модель; подключим реальный comments позже).
abstract final class PostCommentsBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required List<PostCommentUiModel> comments,
    String? composerAvatarUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final viewInsets = MediaQuery.viewInsetsOf(ctx);
        final h = MediaQuery.sizeOf(ctx).height;
        final safeBottom = MediaQuery.paddingOf(ctx).bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: SizedBox(
            height: h - viewInsets.bottom,
            child: _CommentsSheetScaffold(
              comments: comments,
              composerAvatarUrl: composerAvatarUrl,
              safeBottomInset: safeBottom,
            ),
          ),
        );
      },
    );
  }
}

class _CommentsSheetScaffold extends StatefulWidget {
  const _CommentsSheetScaffold({
    required this.comments,
    this.composerAvatarUrl,
    required this.safeBottomInset,
  });

  final List<PostCommentUiModel> comments;
  final String? composerAvatarUrl;
  final double safeBottomInset;

  @override
  State<_CommentsSheetScaffold> createState() => _CommentsSheetScaffoldState();
}

class _CommentsSheetScaffoldState extends State<_CommentsSheetScaffold> {
  late final TextEditingController _composer;

  @override
  void initState() {
    super.initState();
    _composer = TextEditingController();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DraggableScrollableSheet(
            expand: true,
            initialChildSize: 0.88,
            minChildSize: 0.35,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Material(
                color: AppColors.surface,
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Комментарии',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.base(16, color: AppColors.textColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, thickness: 0.5, color: AppColors.border.withValues(alpha: 0.85)),
                    Expanded(
                      child: widget.comments.isEmpty
                          ? ListView(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: Text(
                                      'Пока нет комментариев.\nБудьте первым.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.4),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                              itemCount: widget.comments.length,
                              itemBuilder: (context, i) {
                                return _CommentThreadBlock(
                                  comment: widget.comments[i],
                                  depth: 0,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Material(
          color: AppColors.surface,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 1, thickness: 0.5, color: AppColors.border.withValues(alpha: 0.9)),
              _ComposerRow(
                controller: _composer,
                avatarUrl: widget.composerAvatarUrl,
                onPublish: () {
                  final t = _composer.text.trim();
                  if (t.isEmpty) return;
                  _composer.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
              SizedBox(height: widget.safeBottomInset > 0 ? widget.safeBottomInset : 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentThreadBlock extends StatelessWidget {
  const _CommentThreadBlock({required this.comment, required this.depth});

  final PostCommentUiModel comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final replies = comment.replies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CommentRow(comment: comment, depth: depth),
        if (replies.isNotEmpty)
          ...replies.map(
            (r) => Padding(
              padding: EdgeInsets.only(top: 4, left: depth == 0 ? 4 : 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.border.withValues(alpha: 0.9), width: 2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _CommentThreadBlock(comment: r, depth: depth + 1),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment, required this.depth});

  final PostCommentUiModel comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final time = comment.timeLabel?.trim();
    final likes = comment.likesCount;
    return Padding(
      padding: EdgeInsets.fromLTRB(14 + depth * 6.0, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.inputBackground,
            child: Icon(Icons.person_rounded, color: AppColors.subTextColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorLabel,
                      style: AppTextStyle.base(13, color: AppColors.textColor, fontWeight: FontWeight.w700),
                    ),
                    if (time != null && time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(time, style: AppTextStyle.base(12, color: AppColors.subTextColor)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTextStyle.base(14, color: AppColors.textColor, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.subTextColor.withValues(alpha: 0.8)),
              if (likes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('$likes', style: AppTextStyle.base(11, color: AppColors.subTextColor)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposerRow extends StatelessWidget {
  const _ComposerRow({required this.controller, this.avatarUrl, required this.onPublish});

  final TextEditingController controller;
  final String? avatarUrl;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.inputBackground,
            child: url == null || url.isEmpty
                ? Icon(Icons.person_rounded, color: AppColors.subTextColor.withValues(alpha: 0.7))
                : ClipOval(child: CachedNetworkImage(imageUrl: url, width: 36, height: 36, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onPublish(),
              decoration: InputDecoration(
                hintText: 'Добавить комментарий…',
                hintStyle: AppTextStyle.base(14, color: AppColors.subTextColor),
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: onPublish,
            icon: Icon(Icons.send_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}


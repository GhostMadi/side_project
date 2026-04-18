import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_media_gallery_item.dart';
import 'package:side_project/core/shared/app_media_gallery_viewer.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/chat/data/models/chat_message_attachment_model.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/domain/chat_attachment_rules.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_delivery.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_outgoing_part.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_timeline_utils.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_voice_message_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Пузырёк: время и статус снизу внутри; свои — однотонный [AppColors.primary], чужие — белый с рамкой.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.item, this.onRetryOptimistic});

  final ChatThreadItem item;

  final void Function(String localId)? onRetryOptimistic;

  static const _tickSize = 14.0;
  static const _bubbleRadius = 17.0;
  static const _padH = 11.0;
  static const _padVTop = 8.0;
  static const _padVBottom = 4.0;

  static Color _tickColor(Color fg, {double a = 0.88}) => fg.withValues(alpha: a);

  static Widget? _ticksOutgoing({required Color fg, required bool doubleCheck, required bool readAccent}) {
    final a = readAccent ? 0.92 : 0.62;
    return Icon(
      doubleCheck ? Icons.done_all_rounded : Icons.done_rounded,
      size: _tickSize,
      color: _tickColor(fg, a: a),
    );
  }

  static Widget _optimisticTrailing(ChatOptimisticDelivery d, Color fg) {
    switch (d) {
      case ChatOptimisticDelivery.sending:
        return AppCircularProgressIndicator(
          dimension: _tickSize,
          strokeWidth: 2,
          color: fg.withValues(alpha: 0.92),
        );
      case ChatOptimisticDelivery.ack:
        return Icon(Icons.done_rounded, size: _tickSize, color: _tickColor(fg, a: 0.62));
      case ChatOptimisticDelivery.synced:
        return Icon(Icons.done_all_rounded, size: _tickSize, color: _tickColor(fg, a: 0.92));
      case ChatOptimisticDelivery.failed:
        return Icon(Icons.error_outline_rounded, size: _tickSize + 1, color: _tickColor(fg, a: 0.95));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    return item.when(
      server: (data) {
        final isMine = myId != null && myId == data.message.senderId;
        final fg = isMine ? AppColors.textInverse : AppColors.textColor;
        final timeText = formatChatTime(data.message.createdAt);

        /// Пока нет поля «прочитано собеседником» в API — исходящие с двойной галкой.
        final readAppearance = isMine;
        final trailing = isMine
            ? _ticksOutgoing(fg: fg, doubleCheck: true, readAccent: readAppearance)
            : null;

        Widget bubble;
        if (data.message.kind == 'post_ref') {
          final text = data.postRef?.caption?.trim().isNotEmpty == true
              ? 'Пост: ${data.postRef!.caption!.trim()}'
              : 'Пост';
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            body: Text(
              text,
              style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w500),
            ),
            timeText: timeText,
            trailing: trailing,
          );
        } else if (data.attachments.isNotEmpty) {
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            body: _ServerAlbumAndFiles(data: data, fg: fg, heroScopeId: item.stableBubbleKey),
            timeText: timeText,
            trailing: trailing,
          );
        } else {
          final text = data.message.text ?? '';
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            body: Text(
              text.isEmpty ? '\u200b' : text,
              style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w500),
            ),
            timeText: timeText,
            trailing: trailing,
          );
        }

        return bubble;
      },
      optimisticText: (localId, conversationId, text, createdAt, server, delivery) {
        final effectiveText = server?.message.kind == 'post_ref'
            ? (server?.postRef?.caption?.trim().isNotEmpty == true
                  ? 'Пост: ${server!.postRef!.caption!.trim()}'
                  : 'Пост')
            : (server?.message.text ?? text);
        final displayText = effectiveText.isEmpty ? '\u200b' : effectiveText;

        final failed = delivery == ChatOptimisticDelivery.failed;
        final fg = AppColors.textInverse;
        final tick = server != null
            ? _ticksOutgoing(fg: fg, doubleCheck: true, readAccent: true)
            : _optimisticTrailing(delivery, fg);

        final at = server?.message.createdAt ?? createdAt;
        final timeText = formatChatTime(at);

        Widget bubble = _TelegramBubble(
          id: localId,
          isMine: true,
          dimmed: failed,
          body: Text(
            displayText,
            style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w500),
          ),
          timeText: timeText,
          trailing: Padding(padding: const EdgeInsets.only(bottom: 1), child: tick),
        );

        if (failed && onRetryOptimistic != null) {
          bubble = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onRetryOptimistic!(localId),
            child: bubble,
          );
        }

        return bubble;
      },
      optimisticAttachments: (localId, conversationId, createdAt, parts, caption, server, delivery) {
        final failed = delivery == ChatOptimisticDelivery.failed;
        final fg = AppColors.textInverse;
        final tick = server != null
            ? _ticksOutgoing(fg: fg, doubleCheck: true, readAccent: true)
            : _optimisticTrailing(delivery, fg);

        final at = server?.message.createdAt ?? createdAt;
        final timeText = formatChatTime(at);

        final body = server != null
            ? _ServerAlbumAndFiles(data: server, fg: fg, heroScopeId: item.stableBubbleKey)
            : _OptimisticOutgoingAlbum(parts: parts, caption: caption, fg: fg);

        Widget bubble = _TelegramBubble(
          id: localId,
          isMine: true,
          dimmed: failed,
          body: body,
          timeText: timeText,
          trailing: Padding(padding: const EdgeInsets.only(bottom: 1), child: tick),
        );

        if (failed && onRetryOptimistic != null) {
          bubble = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onRetryOptimistic!(localId),
            child: bubble,
          );
        }

        return bubble;
      },
    );
  }
}

class _OptimisticOutgoingAlbum extends StatelessWidget {
  const _OptimisticOutgoingAlbum({
    required this.parts,
    required this.caption,
    required this.fg,
  });

  final List<ChatOptimisticOutgoingPart> parts;
  final String? caption;
  final Color fg;

  bool _isVisual(ChatOptimisticOutgoingPart p) {
    final m = ChatAttachmentRules.inferMime(p.filename, p.mimeType);
    return ChatAttachmentRules.isImageMime(m) || m.startsWith('video/');
  }

  bool _isAudio(ChatOptimisticOutgoingPart p) {
    final m = ChatAttachmentRules.inferMime(p.filename, p.mimeType);
    return m.startsWith('audio/');
  }

  Widget _thumb(ChatOptimisticOutgoingPart p) {
    final m = ChatAttachmentRules.inferMime(p.filename, p.mimeType);
    if (m.startsWith('video/')) {
      return ColoredBox(
        color: AppColors.iconMuted.withValues(alpha: 0.28),
        child: Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: fg.withValues(alpha: 0.95),
            size: 36,
          ),
        ),
      );
    }
    return Image.memory(p.bytes, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final visuals = parts.where(_isVisual).toList(growable: false);
    final audios = parts.where(_isAudio).toList(growable: false);
    final files = parts.where((p) => !_isVisual(p) && !_isAudio(p)).toList(growable: false);
    final cap = caption?.trim();
    final hasCap = cap != null && cap.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (visuals.length == 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _thumb(visuals[0]),
              ),
            ),
          )
        else if (visuals.length > 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: visuals.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _thumb(visuals[i]),
              ),
            ),
          ),
        ...audios.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(top: e.key == 0 && visuals.isEmpty ? 0 : 3),
            child: ChatVoiceMessagePlayer(
              memoryBytes: e.value.bytes,
              mimeType: ChatAttachmentRules.inferMime(e.value.filename, e.value.mimeType),
              fg: fg,
            ),
          ),
        ),
        ...files.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(top: e.key == 0 && visuals.isEmpty && audios.isEmpty ? 0 : 3),
            child: _OptimisticFileRow(part: e.value, fg: fg),
          ),
        ),
        if (hasCap)
          Padding(
            padding: EdgeInsets.only(top: visuals.isEmpty && audios.isEmpty && files.isEmpty ? 0 : 3),
            child: Text(
              cap,
              style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}

class _OptimisticFileRow extends StatelessWidget {
  const _OptimisticFileRow({required this.part, required this.fg});

  final ChatOptimisticOutgoingPart part;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final name = part.filename;
    final mime = ChatAttachmentRules.inferMime(name, part.mimeType);
    IconData icon = Icons.insert_drive_file_rounded;
    if (mime == 'application/pdf') icon = Icons.picture_as_pdf_rounded;
    if (mime.startsWith('video/')) icon = Icons.videocam_rounded;

    final mb = (part.bytes.length / (1024 * 1024)).toStringAsFixed(1);

    return Row(
      children: [
        Icon(icon, color: fg.withValues(alpha: 0.92), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.base(13, color: fg, fontWeight: FontWeight.w600),
              ),
              Text('$mb МБ', style: AppTextStyle.base(11, color: fg.withValues(alpha: 0.75))),
            ],
          ),
        ),
      ],
    );
  }
}

class _TelegramBubble extends StatelessWidget {
  const _TelegramBubble({
    required this.id,
    required this.isMine,
    required this.body,
    required this.timeText,
    this.trailing,
    this.dimmed = false,
  });

  final String id;
  final bool isMine;
  final Widget body;
  final String timeText;
  final Widget? trailing;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxBubbleW = (mq.width * 0.78).clamp(140.0, 340.0);

    final fg = isMine ? AppColors.textInverse : AppColors.textColor;
    final metaStyle = AppTextStyle.base(
      11,
      color: fg.withValues(alpha: isMine ? 0.82 : 0.52),
      fontWeight: FontWeight.w500,
    );

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        body,
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(timeText, style: metaStyle),
            if (isMine && trailing != null) ...[const SizedBox(width: 5), trailing!],
          ],
        ),
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.fromLTRB(
        ChatMessageBubble._padH,
        ChatMessageBubble._padVTop,
        ChatMessageBubble._padH,
        ChatMessageBubble._padVBottom,
      ),
      child: inner,
    );

    late final Widget shell;
    if (isMine) {
      shell = Container(
        decoration: BoxDecoration(
          color: dimmed ? AppColors.primary.withValues(alpha: 0.55) : AppColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(ChatMessageBubble._bubbleRadius),
            topRight: Radius.circular(ChatMessageBubble._bubbleRadius),
            bottomLeft: Radius.circular(ChatMessageBubble._bubbleRadius),
            bottomRight: Radius.circular(6),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: dimmed ? 0.06 : 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: padded,
      );
    } else {
      shell = Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(ChatMessageBubble._bubbleRadius),
            topRight: Radius.circular(ChatMessageBubble._bubbleRadius),
            bottomRight: Radius.circular(ChatMessageBubble._bubbleRadius),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withValues(alpha: 0.65),
              blurRadius: 5,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: padded,
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleW),
                child: shell,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerAlbumAndFiles extends StatelessWidget {
  const _ServerAlbumAndFiles({
    required this.data,
    required this.fg,
    required this.heroScopeId,
  });

  final ChatMessageEnriched data;
  final Color fg;

  /// Уникальность Hero в ленте: строка сообщения + id вложения (не только message.id + индекс).
  final String heroScopeId;

  /// Фото и видео в сетке; остальное — строки файлов.
  static bool _isAlbumVisual(ChatMessageAttachmentModel a) {
    final m = ChatAttachmentRules.inferMime(a.path.split('/').last, a.mime);
    return ChatAttachmentRules.isImageMime(m) || m.startsWith('video/');
  }

  static bool _isAudio(ChatMessageAttachmentModel a) {
    final m = ChatAttachmentRules.inferMime(a.path.split('/').last, a.mime);
    return m.startsWith('audio/');
  }

  static List<AppMediaGalleryItem> _galleryItems(List<ChatMessageAttachmentModel> attachments) {
    final client = Supabase.instance.client;
    return attachments
        .map((a) {
          final url = client.storage.from(a.bucket).getPublicUrl(a.path).trim();
          final m = ChatAttachmentRules.inferMime(a.path.split('/').last, a.mime);
          return AppMediaGalleryItem(url: url, isVideo: m.startsWith('video/'));
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visuals = data.attachments.where(_isAlbumVisual).toList(growable: false);
    final audios = data.attachments.where(_isAudio).toList(growable: false);
    final files = data.attachments.where((a) => !_isAlbumVisual(a) && !_isAudio(a)).toList(growable: false);
    final cap = data.message.text?.trim();
    final hasCap = cap != null && cap.isNotEmpty;

    final gallery = _galleryItems(visuals);
    final heroTags = List<String?>.generate(
      gallery.length,
      (i) => gallery[i].isVideo ? null : 'chat_gallery_${heroScopeId}_${visuals[i].id}',
    );

    Widget wrapTap({required int index, required Widget child}) {
      if (gallery.isEmpty) return child;
      final tag = heroTags[index];
      final wrapped = tag != null
          ? Hero(
              tag: tag,
              createRectTween: AppMediaGalleryViewer.heroRectTween,
              child: Material(type: MaterialType.transparency, child: child),
            )
          : child;
      return Builder(
        builder: (tapCtx) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Rect? thumbRect;
              final ro = tapCtx.findRenderObject();
              if (ro is RenderBox && ro.hasSize) {
                thumbRect = ro.localToGlobal(Offset.zero) & ro.size;
              }
              AppMediaGalleryViewer.show(
                tapCtx,
                items: gallery,
                initialIndex: index,
                heroTags: heroTags,
                thumbnailRect: thumbRect,
              );
            },
            child: wrapped,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (visuals.length == 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: wrapTap(index: 0, child: _AttachmentThumb(att: visuals[0])),
              ),
            ),
          )
        else if (visuals.length > 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: visuals.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: wrapTap(
                  index: i,
                  child: _AttachmentThumb(att: visuals[i]),
                ),
              ),
            ),
          ),
        ...audios.asMap().entries.map((e) {
          final client = Supabase.instance.client;
          final att = e.value;
          final url = client.storage.from(att.bucket).getPublicUrl(att.path).trim();
          final m = ChatAttachmentRules.inferMime(att.path.split('/').last, att.mime);
          return Padding(
            padding: EdgeInsets.only(top: e.key == 0 && visuals.isEmpty ? 0 : 3),
            child: ChatVoiceMessagePlayer(
              networkUrl: url,
              mimeType: m,
              fg: fg,
              durationMsHint: att.durationMs,
            ),
          );
        }),
        ...files.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(top: e.key == 0 && visuals.isEmpty && audios.isEmpty ? 0 : 3),
            child: _FileRow(att: e.value, fg: fg),
          ),
        ),
        if (hasCap)
          Padding(
            padding: EdgeInsets.only(top: visuals.isEmpty && audios.isEmpty && files.isEmpty ? 0 : 3),
            child: Text(
              cap,
              style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({required this.att});

  final ChatMessageAttachmentModel att;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final url = client.storage.from(att.bucket).getPublicUrl(att.path).trim();
    final mime = ChatAttachmentRules.inferMime(att.path.split('/').last, att.mime);

    if (mime.startsWith('video/')) {
      return ColoredBox(
        color: AppColors.iconMuted.withValues(alpha: 0.28),
        child: Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: AppColors.textInverse.withValues(alpha: 0.95),
            size: 36,
          ),
        ),
      );
    }

    return AppProgressiveNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(10),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.att, required this.fg});

  final ChatMessageAttachmentModel att;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final name = att.path.split('/').last;
    final mime = ChatAttachmentRules.inferMime(name, att.mime);
    IconData icon = Icons.insert_drive_file_rounded;
    if (mime == 'application/pdf') icon = Icons.picture_as_pdf_rounded;
    if (mime.startsWith('video/')) icon = Icons.videocam_rounded;

    final mb = att.sizeBytes != null ? (att.sizeBytes! / (1024 * 1024)).toStringAsFixed(1) : null;

    return Row(
      children: [
        Icon(icon, color: fg.withValues(alpha: 0.92), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.base(13, color: fg, fontWeight: FontWeight.w600),
              ),
              if (mb != null) Text('$mb МБ', style: AppTextStyle.base(11, color: fg.withValues(alpha: 0.75))),
            ],
          ),
        ),
      ],
    );
  }
}

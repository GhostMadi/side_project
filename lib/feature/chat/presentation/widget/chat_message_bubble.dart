import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Позиция пузырька в цепочке подряд идущих сообщений одного отправителя (как в WhatsApp).
enum ChatBubbleChain { single, first, middle, last }

ChatBubbleChain _chatBubbleChainFromFlags({required bool groupWithPrevious, required bool groupWithNext}) {
  if (!groupWithPrevious && !groupWithNext) return ChatBubbleChain.single;
  if (!groupWithPrevious && groupWithNext) return ChatBubbleChain.first;
  if (groupWithPrevious && groupWithNext) return ChatBubbleChain.middle;
  return ChatBubbleChain.last;
}

bool _chatUuidEq(String? a, String? b) {
  if (a == null || b == null) return false;
  return a.trim().toLowerCase() == b.trim().toLowerCase();
}

String _replyKindShortLabel(String kind) {
  switch (kind) {
    case 'post_ref':
      return 'Пост';
    case 'media':
      return 'Медиа';
    case 'file':
      return 'Файл';
    default:
      return 'Сообщение';
  }
}

/// Полоска «ответ на …» над телом пузырька.
class _ReplyQuoteBar extends StatelessWidget {
  const _ReplyQuoteBar({required this.fg, required this.title, required this.subtitle, this.onTap});

  final Color fg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    /// Без [width: double.infinity]: иначе цитата растягивает весь пузырёк до maxWidth,
    /// и короткие ответы выглядят как одна длинная полоса на всю ширину.
    final core = Container(
      padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3, right: 5),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: fg.withValues(alpha: 0.45), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.base(13, color: fg.withValues(alpha: 0.72), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.base(15, color: fg.withValues(alpha: 0.88), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
    if (onTap == null) return core;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: core),
    );
  }
}

Widget? _replyQuoteFromPreview(
  Color fg,
  ChatReplyPreview preview, {
  String? senderLabel,
  void Function(String messageId)? onReferencedTap,
}) {
  final title = senderLabel ?? 'Ответ';
  final sub = preview.text != null && preview.text!.trim().isNotEmpty
      ? preview.text!.trim()
      : _replyKindShortLabel(preview.kind);
  return _ReplyQuoteBar(
    fg: fg,
    title: title,
    subtitle: sub,
    onTap: onReferencedTap == null ? null : () => onReferencedTap(preview.id),
  );
}

/// Свайп для ответа: чужое сообщение — вправо; своё — влево. Горизонталь должна доминировать над вертикалью (скролл ленты).
class _BubbleReplySwipe extends StatefulWidget {
  const _BubbleReplySwipe({required this.isMine, required this.onReply, required this.child});

  final bool isMine;
  final VoidCallback onReply;
  final Widget child;

  @override
  State<_BubbleReplySwipe> createState() => _BubbleReplySwipeState();
}

class _BubbleReplySwipeState extends State<_BubbleReplySwipe> with SingleTickerProviderStateMixin {
  double _accumDx = 0;
  double _accumDy = 0;
  bool _horizontalIntent = false;

  /// Сдвиг пузырька во время жеста (после отпускания кратко анимируется к 0).
  double _displayShift = 0;

  late AnimationController _snapCtrl;

  static const double _triggerDx = 52;
  static const double _bias = 1.12;
  static const double _maxVisualShift = 56;
  static const double _shiftGain = 0.62;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))
      ..addListener(() {
        if (!mounted) return;
        final t = Curves.easeOutCubic.transform(_snapCtrl.value);
        setState(() => _displayShift = _snapStart * (1 - t));
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        if (!mounted) return;
        _snapStart = 0;
        _displayShift = 0;
        setState(() {});
      });
  }

  double _snapStart = 0;

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _resetTracking() {
    _accumDx = 0;
    _accumDy = 0;
    _horizontalIntent = false;
  }

  /// Текущий горизонтальный сдвиг пузырька для отрисовки.
  double _bubbleShiftPx() {
    if (_snapCtrl.isAnimating) return _displayShift;
    if (!_horizontalIntent) return 0;
    if (!widget.isMine) {
      if (_accumDx <= 0) return 0;
      return math.min(_accumDx * _shiftGain, _maxVisualShift);
    }
    if (_accumDx >= 0) return 0;
    return math.max(_accumDx * _shiftGain, -_maxVisualShift);
  }

  double _normProgress(double shift) => math.min(shift.abs() / _maxVisualShift, 1.0).clamp(0.0, 1.0);

  bool get _triggered {
    if (!_horizontalIntent) return false;
    if (widget.isMine) {
      return _accumDx <= -_triggerDx;
    }
    return _accumDx >= _triggerDx;
  }

  void _startSnapBack(double from) {
    _snapCtrl.stop();
    _snapStart = from;
    _displayShift = from;
    _snapCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!mounted) return;
        _snapCtrl.stop();
        _resetTracking();
        setState(() => _displayShift = 0);
      },
      onPointerMove: (e) {
        if (!mounted || _snapCtrl.isAnimating) return;
        _accumDx += e.delta.dx;
        _accumDy += e.delta.dy.abs();
        final ax = _accumDx.abs();
        final ay = _accumDy;
        if (ax > 10 && ax > ay * _bias) {
          _horizontalIntent = true;
        }
        if (!mounted) return;
        setState(() {});
      },
      onPointerUp: (_) {
        if (!mounted || _snapCtrl.isAnimating) return;
        final triggered = _triggered;
        final endShift = _bubbleShiftPx();
        if (triggered) {
          HapticFeedback.mediumImpact();
          widget.onReply();
          _resetTracking();
          if (mounted) setState(() => _displayShift = 0);
          return;
        }
        _resetTracking();
        if (endShift.abs() > 3) {
          _startSnapBack(endShift);
        } else if (mounted) {
          setState(() => _displayShift = 0);
        }
      },
      onPointerCancel: (_) {
        if (!mounted) return;
        _snapCtrl.stop();
        final s = _bubbleShiftPx();
        _resetTracking();
        if (s.abs() > 3) {
          _startSnapBack(s);
        } else if (mounted) {
          setState(() => _displayShift = 0);
        }
      },
      child: LayoutBuilder(
        builder: (context, c) {
          final shift = _bubbleShiftPx();
          final progress = _normProgress(shift);
          final iconSide = widget.isMine ? Alignment.centerRight : Alignment.centerLeft;
          final pad = EdgeInsets.only(left: widget.isMine ? 0 : 10, right: widget.isMine ? 10 : 0);
          return SizedBox(
            width: c.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: iconSide,
                    child: Padding(
                      padding: pad,
                      child: Opacity(
                        opacity: progress * 0.95,
                        child: Icon(
                          Icons.reply_rounded,
                          size: 26 + 6 * progress,
                          color: AppColors.primary.withValues(alpha: 0.35 + 0.35 * progress),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(offset: Offset(shift, 0), child: widget.child),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Пузырёк: время и статус снизу внутри; свои — однотонный [AppColors.primary], чужие — белый с рамкой.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.item,
    this.onRetryOptimistic,
    this.onReply,
    this.onReferencedMessageTap,
    this.groupWithPrevious = false,
    this.groupWithNext = false,
  });

  final ChatThreadItem item;

  final void Function(String localId)? onRetryOptimistic;

  /// Свайп по серверному сообщению (чужое — вправо, своё — влево) — черновик ответа.
  final void Function(ChatMessageEnriched data)? onReply;

  /// Тап по полоске ответа — переход к исходному сообщению в ленте (по id из [ChatReplyPreview.id]).
  final void Function(String referencedMessageId)? onReferencedMessageTap;

  /// Подряд с предыдущим сообщением того же отправителя (уменьшаем верхний зазор и скругления).
  final bool groupWithPrevious;

  /// Подряд со следующим сообщением того же отправителя.
  final bool groupWithNext;

  static const _tickSize = 16.0;

  /// Скругление основных углов пузырька (было 17 — делаем мягче).
  static const _bubbleRadius = 24.0;

  /// Меньший угол у «хвоста» (нижний внешний угол цепочки).
  static const _bubbleTailRadius = 10.0;

  /// Углы у подряд идущих сообщений одного отправителя (середина цепочки).
  static const _bubbleStackRadius = 14.0;
  static const _padH = 14.0;
  static const _padVTop = 10.0;
  static const _padVBottom = 6.0;

  static Color _tickColor(Color fg, {double a = 0.88}) => fg.withValues(alpha: a);

  /// Одна галочка — на сервере / не прочитано собеседником; две яркие — только при [readAccent] (read_by_peer).
  static Widget? _ticksOutgoing({required Color fg, required bool readAccent}) {
    final a = readAccent ? 0.92 : 0.62;
    return Icon(
      readAccent ? Icons.done_all_rounded : Icons.done_rounded,
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
        // Двойная только при read_by_peer на серверной строке; здесь без server — как «ещё не прочитано».
        return Icon(Icons.done_rounded, size: _tickSize, color: _tickColor(fg, a: 0.62));
      case ChatOptimisticDelivery.failed:
        return Icon(Icons.error_outline_rounded, size: _tickSize + 1, color: _tickColor(fg, a: 0.95));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    final chain = _chatBubbleChainFromFlags(
      groupWithPrevious: groupWithPrevious,
      groupWithNext: groupWithNext,
    );
    return item.when(
      server: (data) {
        final isMine = _chatUuidEq(myId, data.message.senderId);
        final fg = isMine ? AppColors.textInverse : AppColors.textColor;
        final timeText = formatChatTime(data.message.createdAt);

        /// read_by_peer с бэка: остальные участники прочитали до этой строки (не факт «я открыл чат»).
        final trailing = isMine
            ? _ticksOutgoing(fg: fg, readAccent: data.message.readByPeer)
            : null;

        Widget bubble;
        final replyHeader = data.replyPreview != null
            ? _replyQuoteFromPreview(fg, data.replyPreview!, onReferencedTap: onReferencedMessageTap)
            : null;

        if (data.message.kind == 'post_ref') {
          final text = data.postRef?.caption?.trim().isNotEmpty == true
              ? 'Пост: ${data.postRef!.caption!.trim()}'
              : 'Пост';
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            chain: chain,
            replyHeader: replyHeader,
            body: Text(
              text,
              style: AppTextStyle.base(16, color: fg, fontWeight: FontWeight.w500),
            ),
            timeText: timeText,
            trailing: trailing,
          );
        } else if (data.attachments.isNotEmpty) {
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            chain: chain,
            replyHeader: replyHeader,
            body: _ServerAlbumAndFiles(data: data, fg: fg, heroScopeId: item.stableBubbleKey),
            timeText: timeText,
            trailing: trailing,
          );
        } else {
          final text = data.message.text ?? '';
          bubble = _TelegramBubble(
            id: data.message.id,
            isMine: isMine,
            chain: chain,
            replyHeader: replyHeader,
            body: Text(
              text.isEmpty ? '\u200b' : text,
              style: AppTextStyle.base(16, color: fg, fontWeight: FontWeight.w500),
            ),
            timeText: timeText,
            trailing: trailing,
          );
        }

        if (onReply != null) {
          bubble = _BubbleReplySwipe(isMine: isMine, onReply: () => onReply!(data), child: bubble);
        }

        return bubble;
      },
      optimisticText:
          (localId, conversationId, text, createdAt, server, delivery, _, quotedPreview, quotedSenderLabel) {
            final effectiveText = server?.message.kind == 'post_ref'
                ? (server?.postRef?.caption?.trim().isNotEmpty == true
                      ? 'Пост: ${server!.postRef!.caption!.trim()}'
                      : 'Пост')
                : (server?.message.text ?? text);
            final displayText = effectiveText.isEmpty ? '\u200b' : effectiveText;

            final failed = delivery == ChatOptimisticDelivery.failed;
            final fg = AppColors.textInverse;
            final tick = server != null
                ? _ticksOutgoing(fg: fg, readAccent: server.message.readByPeer)
                : _optimisticTrailing(delivery, fg);

            final at = server?.message.createdAt ?? createdAt;
            final timeText = formatChatTime(at);

            final replyHeader = quotedPreview != null
                ? _replyQuoteFromPreview(
                    fg,
                    quotedPreview,
                    senderLabel: quotedSenderLabel,
                    onReferencedTap: onReferencedMessageTap,
                  )
                : null;

            Widget bubble = _TelegramBubble(
              id: localId,
              isMine: true,
              chain: chain,
              dimmed: failed,
              replyHeader: replyHeader,
              body: Text(
                displayText,
                style: AppTextStyle.base(16, color: fg, fontWeight: FontWeight.w500),
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
      optimisticAttachments:
          (
            localId,
            conversationId,
            createdAt,
            parts,
            caption,
            server,
            delivery,
            _,
            quotedPreview,
            quotedSenderLabel,
          ) {
            final failed = delivery == ChatOptimisticDelivery.failed;
            final fg = AppColors.textInverse;
            final tick = server != null
                ? _ticksOutgoing(fg: fg, readAccent: server.message.readByPeer)
                : _optimisticTrailing(delivery, fg);

            final at = server?.message.createdAt ?? createdAt;
            final timeText = formatChatTime(at);

            final body = server != null
                ? _ServerAlbumAndFiles(data: server, fg: fg, heroScopeId: item.stableBubbleKey)
                : _OptimisticOutgoingAlbum(parts: parts, caption: caption, fg: fg);

            final replyHeader = quotedPreview != null
                ? _replyQuoteFromPreview(
                    fg,
                    quotedPreview,
                    senderLabel: quotedSenderLabel,
                    onReferencedTap: onReferencedMessageTap,
                  )
                : null;

            Widget bubble = _TelegramBubble(
              id: localId,
              isMine: true,
              chain: chain,
              dimmed: failed,
              replyHeader: replyHeader,
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
  const _OptimisticOutgoingAlbum({required this.parts, required this.caption, required this.fg});

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
          child: Icon(Icons.play_circle_fill_rounded, color: fg.withValues(alpha: 0.95), size: 36),
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
            constraints: const BoxConstraints(maxWidth: 300),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _thumb(visuals[0])),
            ),
          )
        else if (visuals.length >= 3 && visuals.length.isOdd)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _albumOddVisualCountLayout([
              for (final p in visuals)
                ClipRRect(borderRadius: BorderRadius.circular(12), child: _thumb(p)),
            ]),
          )
        else if (visuals.length > 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
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
              itemBuilder: (_, i) =>
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: _thumb(visuals[i])),
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
              style: AppTextStyle.base(16, color: fg, fontWeight: FontWeight.w500),
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
                style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w600),
              ),
              Text('$mb МБ', style: AppTextStyle.base(12, color: fg.withValues(alpha: 0.75))),
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
    required this.chain,
    required this.body,
    required this.timeText,
    this.replyHeader,
    this.trailing,
    this.dimmed = false,
  });

  final String id;
  final bool isMine;
  final ChatBubbleChain chain;
  final Widget body;
  final String timeText;
  final Widget? replyHeader;
  final Widget? trailing;
  final bool dimmed;

  static BorderRadius _radiusMine(ChatBubbleChain c) {
    const r = ChatMessageBubble._bubbleRadius;
    const tail = ChatMessageBubble._bubbleTailRadius;
    const stack = ChatMessageBubble._bubbleStackRadius;
    switch (c) {
      case ChatBubbleChain.single:
        return const BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomLeft: Radius.circular(r),
          bottomRight: Radius.circular(tail),
        );
      case ChatBubbleChain.first:
        return const BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomLeft: Radius.circular(r),
          bottomRight: Radius.circular(stack),
        );
      case ChatBubbleChain.middle:
        return const BorderRadius.only(
          topLeft: Radius.circular(stack),
          topRight: Radius.circular(stack),
          bottomLeft: Radius.circular(stack),
          bottomRight: Radius.circular(stack),
        );
      case ChatBubbleChain.last:
        return const BorderRadius.only(
          topLeft: Radius.circular(stack),
          topRight: Radius.circular(stack),
          bottomLeft: Radius.circular(r),
          bottomRight: Radius.circular(tail),
        );
    }
  }

  static BorderRadius _radiusTheirs(ChatBubbleChain c) {
    const r = ChatMessageBubble._bubbleRadius;
    const tail = ChatMessageBubble._bubbleTailRadius;
    const stack = ChatMessageBubble._bubbleStackRadius;
    switch (c) {
      case ChatBubbleChain.single:
        return const BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomRight: Radius.circular(r),
          bottomLeft: Radius.circular(tail),
        );
      case ChatBubbleChain.first:
        return const BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomRight: Radius.circular(stack),
          bottomLeft: Radius.circular(stack),
        );
      case ChatBubbleChain.middle:
        return const BorderRadius.only(
          topLeft: Radius.circular(stack),
          topRight: Radius.circular(stack),
          bottomRight: Radius.circular(stack),
          bottomLeft: Radius.circular(stack),
        );
      case ChatBubbleChain.last:
        return const BorderRadius.only(
          topLeft: Radius.circular(stack),
          topRight: Radius.circular(stack),
          bottomRight: Radius.circular(r),
          bottomLeft: Radius.circular(tail),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxBubbleW = (mq.width * 0.82).clamp(160.0, 384.0);

    final fg = isMine ? AppColors.textInverse : AppColors.textColor;
    final metaStyle = AppTextStyle.base(
      12,
      color: fg.withValues(alpha: isMine ? 0.82 : 0.52),
      fontWeight: FontWeight.w500,
    );

    final quote = replyHeader;
    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (quote != null) ...[quote, const SizedBox(height: 6)],
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

    final topPad = chain == ChatBubbleChain.single || chain == ChatBubbleChain.first ? 3.0 : 1.0;
    final bottomPad = chain == ChatBubbleChain.single || chain == ChatBubbleChain.last ? 3.0 : 1.0;

    late final Widget shell;
    if (isMine) {
      shell = Container(
        decoration: BoxDecoration(
          color: dimmed ? AppColors.primary.withValues(alpha: 0.55) : AppColors.primary,
          borderRadius: _radiusMine(chain),
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
          borderRadius: _radiusTheirs(chain),
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
        padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
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

/// Нечётное число медиа ≥3: первые n−1 в сетке 2 колонки, последнее на всю ширину снизу (без «дыры» в последней строке).
Widget _albumOddVisualCountLayout(List<Widget> cells) {
  assert(cells.length >= 3 && cells.length.isOdd);
  final n = cells.length;
  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      const gap = 4.0;
      final side = (w - gap) / 2;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
              childAspectRatio: 1,
            ),
            itemCount: n - 1,
            itemBuilder: (_, i) => cells[i],
          ),
          SizedBox(height: gap),
          SizedBox(width: w, height: side, child: cells[n - 1]),
        ],
      );
    },
  );
}

class _ServerAlbumAndFiles extends StatelessWidget {
  const _ServerAlbumAndFiles({required this.data, required this.fg, required this.heroScopeId});

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
            constraints: const BoxConstraints(maxWidth: 300),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: wrapTap(index: 0, child: _AttachmentThumb(att: visuals[0])),
              ),
            ),
          )
        else if (visuals.length >= 3 && visuals.length.isOdd)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _albumOddVisualCountLayout([
              for (var i = 0; i < visuals.length; i++)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: wrapTap(
                    index: i,
                    child: _AttachmentThumb(att: visuals[i]),
                  ),
                ),
            ]),
          )
        else if (visuals.length > 1)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
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
                borderRadius: BorderRadius.circular(12),
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
              style: AppTextStyle.base(16, color: fg, fontWeight: FontWeight.w500),
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
      borderRadius: BorderRadius.circular(12),
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
                style: AppTextStyle.base(14, color: fg, fontWeight: FontWeight.w600),
              ),
              if (mb != null) Text('$mb МБ', style: AppTextStyle.base(12, color: fg.withValues(alpha: 0.75))),
            ],
          ),
        ),
      ],
    );
  }
}

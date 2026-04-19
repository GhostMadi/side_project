import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/presentation/chat_display_username.dart';

class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    super.key,
    required this.item,
    required this.onTap,
    this.currentUserId,
  });

  final ChatConversationEnriched item;
  final VoidCallback onTap;

  /// Для галочек «прочитано» у последнего **исходящего** сообщения в превью.
  final String? currentUserId;

  static String? _shortTime(DateTime? t) {
    if (t == null) return null;
    final local = t.toLocal();
    final n = DateTime.now();
    if (local.year == n.year && local.month == n.month && local.day == n.day) {
      return DateFormat.Hm().format(local);
    }
    if (local.year == n.year) {
      return DateFormat('d MMM').format(local);
    }
    return DateFormat.yMd().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final isDm = item.conversation.type == 'dm';
    final dmBare = chatDisplayUsername(item.otherUser?.username);
    final title = isDm
        ? (dmBare.isNotEmpty ? dmBare : 'Диалог')
        : (item.conversation.title?.trim().isNotEmpty == true ? item.conversation.title!.trim() : 'Группа');

    final last = item.lastMessage;
    final subtitle = last == null
        ? 'Нет сообщений'
        : (last.kind == 'post_ref'
              ? (last.text?.trim().isNotEmpty == true ? 'Пост: ${last.text!.trim()}' : 'Пост')
              : (last.text?.trim().isNotEmpty == true ? last.text!.trim() : last.kind));

    final myNorm = currentUserId?.trim().toLowerCase();
    final senderNorm = last?.senderId.trim().toLowerCase();
    final lastIsMine = last != null && myNorm != null && myNorm.isNotEmpty && senderNorm == myNorm;
    final showReadTicks = lastIsMine && item.conversation.type == 'dm';

    final unread = item.unreadCount;
    /// Последнее сообщение от собеседника — превью чуть контрастнее («чужое» не только серым).
    final subtitleColor = last == null || lastIsMine
        ? AppColors.subTextColor
        : AppColors.textColor.withValues(alpha: unread > 0 ? 0.92 : 0.82);
    final avatarUrl = item.otherUser?.avatarUrl?.trim();
    final timeLabel = _shortTime(last?.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceSoftGreen,
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? AppProgressiveNetworkImage(
                          imageUrl: avatarUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.person_rounded, color: AppColors.iconMuted.withValues(alpha: 0.85), size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.base(13, color: subtitleColor, height: 1.25),
                          ),
                        ),
                        if (showReadTicks) ...[
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.done_all_rounded,
                              size: 17,
                              color: last.readByPeer
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.48),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeLabel != null)
                    Text(
                      timeLabel,
                      style: AppTextStyle.base(12, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
                    ),
                  if (unread > 0)
                    Padding(
                      padding: EdgeInsets.only(top: timeLabel != null ? 6 : 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          unread > 99 ? '99+' : unread.toString(),
                          style: AppTextStyle.base(12, color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

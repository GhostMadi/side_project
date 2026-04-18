import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';

class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({super.key, required this.item, required this.onTap});

  final ChatConversationEnriched item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDm = item.conversation.type == 'dm';
    final title = isDm
        ? (item.otherUser?.username?.trim().isNotEmpty == true
              ? '@${item.otherUser!.username!.trim()}'
              : 'Диалог')
        : (item.conversation.title?.trim().isNotEmpty == true ? item.conversation.title!.trim() : 'Группа');

    final last = item.lastMessage;
    final subtitle = last == null
        ? 'Нет сообщений'
        : (last.kind == 'post_ref'
              ? (last.text?.trim().isNotEmpty == true ? 'Пост: ${last.text!.trim()}' : 'Пост')
              : (last.text?.trim().isNotEmpty == true ? last.text!.trim() : last.kind));

    final unread = item.unreadCount;
    final avatarUrl = item.otherUser?.avatarUrl?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputBackground,
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? AppProgressiveNetworkImage(
                          imageUrl: avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person_rounded, color: AppColors.iconMuted, size: 26),
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
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w700, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(13, color: AppColors.subTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unread.toString(),
                    style: AppTextStyle.base(12, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/chat/data/messenger_user_search_service.dart';
import 'package:side_project/feature/chat/presentation/chat_display_username.dart';

/// Секции **People** / **Suggested** (как в Instagram) — поиск людей, не чатов.
class ChatMessengerUserSearchResults extends StatelessWidget {
  const ChatMessengerUserSearchResults({
    super.key,
    required this.loading,
    required this.outcome,
    required this.onUserTap,
  });

  final bool loading;
  final MessengerSearchOutcome? outcome;
  final void Function(MessengerSearchHit hit) onUserTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: AppCircularProgressIndicator(dimension: 32, strokeWidth: 2.5)),
      );
    }
    if (outcome == null) {
      return const SizedBox.shrink();
    }
    final p = outcome!.people;
    final s = outcome!.suggested;
    if (p.isEmpty && s.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Text(
          'Пользователи не найдены',
          textAlign: TextAlign.center,
          style: AppTextStyle.base(15, color: AppColors.subTextColor),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p.isNotEmpty) _sectionHeader('People'),
        if (p.isNotEmpty) ...p.map((e) => _UserRow(hit: e, onTap: () => onUserTap(e))),
        if (s.isNotEmpty) _sectionHeader('Suggested'),
        if (s.isNotEmpty) ...s.map((e) => _UserRow(hit: e, onTap: () => onUserTap(e))),
      ],
    );
  }

  static Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Text(
        title,
        style: AppTextStyle.base(13, fontWeight: FontWeight.w800, color: AppColors.subTextColor, letterSpacing: 0.6),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.hit, required this.onTap});

  final MessengerSearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pr = hit.profile;
    final nickBare = chatDisplayUsername(pr.username);
    final nick = nickBare.isNotEmpty ? nickBare : '…';
    final name = pr.fullName?.trim();
    final av = pr.avatarUrl?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceSoftGreen,
                child: ClipOval(
                  child: av != null && av.isNotEmpty
                      ? AppProgressiveNetworkImage(imageUrl: av, width: 52, height: 52, fit: BoxFit.cover)
                      : Icon(Icons.person_rounded, color: AppColors.iconMuted.withValues(alpha: 0.85), size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null && name.isNotEmpty)
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(16, fontWeight: FontWeight.w700, color: AppColors.textColor),
                      ),
                    Text(
                      nick,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(
                        14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (hit.existingConversationId != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'Чат',
                    style: AppTextStyle.base(12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

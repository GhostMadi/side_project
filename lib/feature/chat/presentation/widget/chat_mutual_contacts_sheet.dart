import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:side_project/feature/chat/presentation/chat_display_username.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Новый диалог только с **взаимными** подписками (я подписан и на меня подписаны).
/// Глобальный поиск людей здесь не используется — см. [PeopleSearchRoute] для прочего.
Future<void> showChatMutualContactsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ChatMutualContactsSheetBody(),
  );
}

class _ChatMutualContactsSheetBody extends StatefulWidget {
  const _ChatMutualContactsSheetBody();

  @override
  State<_ChatMutualContactsSheetBody> createState() => _ChatMutualContactsSheetBodyState();
}

class _ChatMutualContactsSheetBodyState extends State<_ChatMutualContactsSheetBody> {
  final _filter = TextEditingController();

  List<ProfileFollowRow> _all = [];
  List<ProfileFollowRow> _visible = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _filter.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _filter.removeListener(_applyFilter);
    _filter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final followRepo = sl<FollowListRepository>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final myId = Supabase.instance.client.auth.currentUser?.id.trim();
      if (myId == null || myId.isEmpty) {
        throw StateError('Нет сессии');
      }
      final following = await followRepo.listFollowing(myId, limit: 400, offset: 0);
      final followers = await followRepo.listFollowers(myId, limit: 400, offset: 0);
      final followerIds = followers.map((e) => e.profileId.trim().toLowerCase()).toSet();
      final mutual = following
          .where((e) => followerIds.contains(e.profileId.trim().toLowerCase()))
          .toList(growable: false);
      mutual.sort((a, b) {
        final ua = (a.username ?? '').toLowerCase();
        final ub = (b.username ?? '').toLowerCase();
        return ua.compareTo(ub);
      });
      if (!mounted) return;
      setState(() {
        _all = mutual;
        _visible = mutual;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _applyFilter() {
    final q = _filter.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _visible = List.of(_all));
      return;
    }
    setState(() {
      _visible = _all.where((e) {
        final u = (e.username ?? '').toLowerCase();
        return u.contains(q);
      }).toList(growable: false);
    });
  }

  Future<void> _openChat(String profileId) async {
    final router = context.router;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final repo = sl<ChatRepository>();
    try {
      final cid = await repo.createDm(profileId);
      if (!mounted) return;
      Navigator.of(context).pop();
      await router.push(ChatThreadRoute(conversationId: cid));
    } catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.38,
      maxChildSize: 0.94,
      expand: false,
      builder: (ctx, scroll) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, -4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Новое сообщение',
                        style: AppTextStyle.base(18, fontWeight: FontWeight.w800, color: AppColors.textColor),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: AppColors.iconMuted),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Только взаимные подписки — с кем вы и ваш собеседник подписаны друг на друга.',
                  style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _filter,
                  decoration: InputDecoration(
                    hintText: 'Фильтр по @нику',
                    prefixIcon: Icon(Icons.filter_list_rounded, color: AppColors.iconMuted, size: 22),
                    filled: true,
                    fillColor: AppColors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildList(scroll, bottom),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(ScrollController scroll, double bottomPad) {
    if (_loading) {
      return const Center(child: AppCircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не удалось загрузить контакты',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor),
          ),
        ),
      );
    }
    if (_all.isEmpty) {
      return ListView(
        controller: scroll,
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomPad),
        children: [
          Text(
            'Пока никого: взаимная подписка — когда вы подписаны на человека и он на вас. Тогда здесь появится контакт.',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.4),
          ),
        ],
      );
    }
    if (_visible.isEmpty) {
      return ListView(
        controller: scroll,
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomPad),
        children: [
          Text(
            'Никого по фильтру',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: scroll,
      padding: EdgeInsets.fromLTRB(8, 4, 8, 16 + bottomPad),
      itemCount: _visible.length,
      itemBuilder: (context, i) {
        final r = _visible[i];
        final bare = chatDisplayUsername(r.username);
        final label = bare.isNotEmpty ? bare : 'Профиль';
        final av = r.avatarUrl?.trim();
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openChat(r.profileId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surfaceSoftGreen,
                    child: ClipOval(
                      child: av != null && av.isNotEmpty
                          ? AppProgressiveNetworkImage(imageUrl: av, width: 52, height: 52, fit: BoxFit.cover)
                          : Icon(Icons.person_rounded, color: AppColors.iconMuted, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyle.base(16, fontWeight: FontWeight.w600, color: AppColors.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primary.withValues(alpha: 0.85)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

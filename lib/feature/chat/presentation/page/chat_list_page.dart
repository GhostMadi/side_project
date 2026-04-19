import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_refresh.dart';
import 'package:side_project/feature/chat/data/messenger_user_search_service.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:side_project/feature/chat/presentation/chat_display_username.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_conversations_list_cubit.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_conversation_tile.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_messenger_user_search_results.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatConversationsListCubit, ChatConversationsListState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceSoftBlue,
          body: state.when(
            initial: () => const _ChatListLoading(),
            loading: () => const _ChatListLoading(),
            error: (m) => _ChatListError(
              message: m,
              onRetry: () => context.read<ChatConversationsListCubit>().load(),
            ),
            loaded: (items, _, errorMessage) {
              return _MessengerChatListBody(
                items: items,
                errorBanner: errorMessage,
                onRefresh: () => context.read<ChatConversationsListCubit>().refresh(),
                onOpenThread: (cid) => context.router.push(ChatThreadRoute(conversationId: cid)),
              );
            },
          ),
        );
      },
    );
  }
}

class _ChatListHeaderSliver extends StatelessWidget {
  const _ChatListHeaderSliver();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surfaceSoftBlue,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: const _ChatListHeaderTitle(),
    );
  }
}

/// Заголовок — ник текущего пользователя (без символа `@`).
class _ChatListHeaderTitle extends StatefulWidget {
  const _ChatListHeaderTitle();

  @override
  State<_ChatListHeaderTitle> createState() => _ChatListHeaderTitleState();
}

class _ChatListHeaderTitleState extends State<_ChatListHeaderTitle> {
  String _label = '…';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final p = await sl<ProfileRepository>().getCurrentUserProfile();
      if (!mounted) return;
      final nick = p?.username?.trim();
      final name = p?.fullName?.trim();
      setState(() {
        if (nick != null && nick.isNotEmpty) {
          final bare = chatDisplayUsername(nick);
          if (bare.isNotEmpty) {
            _label = bare;
          } else if (name != null && name.isNotEmpty) {
            _label = name;
          } else {
            _label = 'Сообщения';
          }
        } else if (name != null && name.isNotEmpty) {
          _label = name;
        } else {
          _label = 'Сообщения';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _label = 'Сообщения');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.base(15, fontWeight: FontWeight.w400, color: AppColors.textColor, height: 1.05),
    );
  }
}

class _ChatListLoading extends StatelessWidget {
  const _ChatListLoading();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        const _ChatListHeaderSliver(),
        const SliverFillRemaining(child: Center(child: AppCircularProgressIndicator())),
      ],
    );
  }
}

class _ChatListError extends StatelessWidget {
  const _ChatListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        const _ChatListHeaderSliver(),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.subTextColor.withValues(alpha: 0.65)),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.base(15, color: AppColors.subTextColor, height: 1.35),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Повторить', style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessengerChatListBody extends StatefulWidget {
  const _MessengerChatListBody({
    required this.items,
    required this.errorBanner,
    required this.onRefresh,
    required this.onOpenThread,
  });

  final List<ChatConversationEnriched> items;
  final String? errorBanner;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onOpenThread;

  @override
  State<_MessengerChatListBody> createState() => _MessengerChatListBodyState();
}

class _MessengerChatListBodyState extends State<_MessengerChatListBody> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  bool _searchLoading = false;
  MessengerSearchOutcome? _searchOutcome;
  int _searchGen = 0;

  String get _myId => Supabase.instance.client.auth.currentUser?.id.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.removeListener(_onSearchTextChanged);
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _debounce?.cancel();
    final t = _search.text.trim();
    if (t.isEmpty) {
      setState(() {
        _searchLoading = false;
        _searchOutcome = null;
      });
      return;
    }
    setState(() => _searchLoading = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _search.text.trim();
      if (q.isEmpty) return;
      unawaited(_runSearch(q));
    });
  }

  Future<void> _runSearch(String q) async {
    final gen = ++_searchGen;
    final svc = sl<MessengerUserSearchService>();
    final conv = context.read<ChatConversationsListCubit>().state.maybeMap(
      loaded: (s) => s.items,
      orElse: () => widget.items,
    );
    try {
      final out = await svc.search(rawQuery: q, myUserId: _myId, conversations: conv);
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _searchOutcome = out;
        _searchLoading = false;
      });
    } catch (_) {
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _searchOutcome = const MessengerSearchOutcome(people: [], suggested: []);
        _searchLoading = false;
      });
    }
  }

  Future<void> _onUserPick(MessengerSearchHit hit) async {
    final router = context.router;
    final repo = sl<ChatRepository>();
    try {
      final cid = hit.existingConversationId ?? await repo.createDm(hit.profile.id);
      if (!mounted) return;
      _search.clear();
      _searchFocus.unfocus();
      setState(() => _searchOutcome = null);
      await context.read<ChatConversationsListCubit>().refresh();
      if (!mounted) return;
      await router.push(ChatThreadRoute(conversationId: cid));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  bool get _showSearchResults => _search.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final refresh = AppRefresh(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const _ChatListHeaderSliver(),
          if (widget.errorBanner != null && widget.errorBanner!.trim().isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoftGreen.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderCardGreen.withValues(alpha: 0.85)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.errorBanner!,
                            style: AppTextStyle.base(13, color: AppColors.textColor, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            sliver: SliverToBoxAdapter(
              child: _MessengerSearchField(controller: _search, focusNode: _searchFocus),
            ),
          ),
          if (_showSearchResults)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              sliver: SliverToBoxAdapter(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: ChatMessengerUserSearchResults(
                      loading: _searchLoading,
                      outcome: _searchOutcome,
                      onUserTap: _onUserPick,
                    ),
                  ),
                ),
              ),
            )
          else if (widget.items.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: _EmptyChats())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(childCount: widget.items.length, (context, i) {
                  final item = widget.items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ChatConversationTile(
                          item: item,
                          currentUserId: _myId.isEmpty ? null : _myId,
                          onTap: () => widget.onOpenThread(item.conversation.id),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    return refresh;
  }
}

class _MessengerSearchField extends StatefulWidget {
  const _MessengerSearchField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_MessengerSearchField> createState() => _MessengerSearchFieldState();
}

class _MessengerSearchFieldState extends State<_MessengerSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderCardGreen.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Поиск людей',
          hintStyle: AppTextStyle.base(15, color: AppColors.subTextColor),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary.withValues(alpha: 0.9)),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.iconMuted),
                  onPressed: () {
                    widget.controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
        style: AppTextStyle.base(16, color: AppColors.textColor),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 52,
                color: AppColors.primary.withValues(alpha: 0.88),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Нет диалогов',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(20, fontWeight: FontWeight.w800, color: AppColors.textColor),
          ),
          const SizedBox(height: 10),
          Text(
            'Найдите человека в строке поиска выше и откройте диалог.',
            textAlign: TextAlign.center,
            style: AppTextStyle.base(14, color: AppColors.subTextColor, height: 1.45),
          ),
        ],
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_conversations_list_cubit.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_conversation_tile.dart';

@RoutePage()
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatConversationsListCubit>()..load(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ChatConversationsListCubit, ChatConversationsListState>(
          builder: (context, state) {
            return state.when(
              initial: () => const _ChatListShell(isLoading: true),
              loading: () => const _ChatListShell(isLoading: true),
              error: (m) =>
                  _ErrorBody(message: m, onRetry: () => context.read<ChatConversationsListCubit>().load()),
              loaded: (items, isRefreshing, errorMessage) {
                return _ChatListShell(
                  isLoading: false,
                  items: items,
                  onRefresh: () => context.read<ChatConversationsListCubit>().refresh(),
                  onOpenSearch: () => context.router.push(const ChatSearchRoute()),
                  onOpenThread: (cid) => context.router.push(ChatThreadRoute(conversationId: cid)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChatListShell extends StatelessWidget {
  const _ChatListShell({
    required this.isLoading,
    this.items = const [],
    this.onRefresh,
    this.onOpenSearch,
    this.onOpenThread,
  });

  final bool isLoading;
  final List<ChatConversationEnriched> items;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenSearch;
  final ValueChanged<String>? onOpenThread;

  @override
  Widget build(BuildContext context) {
    final refresh = onRefresh;
    final canRefresh = refresh != null;

    Widget body;
    if (isLoading) {
      body = const Center(child: AppCircularProgressIndicator());
    } else if (items.isEmpty) {
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 36),
          Center(
            child: Text('Пока нет диалогов', style: AppTextStyle.base(14, color: AppColors.subTextColor)),
          ),
        ],
      );
    } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border.withValues(alpha: 0.35)),
        itemBuilder: (context, i) {
          final item = items[i];
          return ChatConversationTile(item: item, onTap: () => onOpenThread?.call(item.conversation.id));
        },
      );
    }

    final scrollable = canRefresh ? RefreshIndicator(onRefresh: refresh, child: body) : body;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          automaticallyImplyLeading: false, // navbar page: no back button
          titleSpacing: 16,
          title: Text(
            'Сообщения',
            style: AppTextStyle.base(24, fontWeight: FontWeight.w800, color: AppColors.textColor),
          ),
          actions: [
            IconButton(
              icon: Icon(AppIcons.search.icon, color: AppColors.textColor),
              onPressed: onOpenSearch,
            ),
            const SizedBox(width: 6),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.25)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpenSearch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(AppIcons.search.icon, color: AppColors.subTextColor),
                      const SizedBox(width: 10),
                      Text('Поиск', style: AppTextStyle.base(14, color: AppColors.subTextColor)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(hasScrollBody: true, child: scrollable),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.base(14, color: AppColors.subTextColor),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

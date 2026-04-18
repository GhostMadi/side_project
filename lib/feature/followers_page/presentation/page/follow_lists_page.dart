import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_pill_back_nav_overlay.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:side_project/feature/followers_page/presentation/cubit/profile_followers_list_cubit.dart';
import 'package:side_project/feature/followers_page/presentation/cubit/profile_following_list_cubit.dart';
import 'package:side_project/feature/followers_page/presentation/widget/follow_user_row.dart';

/// Табы: подписчики и подписки для профиля [profileId].
@RoutePage()
class FollowListsPage extends StatefulWidget {
  const FollowListsPage({
    super.key,
    required this.profileId,
    this.username,
    this.initialTabIndex = 0,
  });

  final String profileId;

  /// Никнейм аккаунта (для заголовка, как в Instagram).
  final String? username;

  /// 0 — подписчики, 1 — подписки.
  final int initialTabIndex;

  @override
  State<FollowListsPage> createState() => _FollowListsPageState();
}

class _FollowListsPageState extends State<FollowListsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final username = widget.username?.trim();
    final titleText = (username != null && username.isNotEmpty) ? '@$username' : 'Аккаунт';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProfileFollowersListCubit>()..load(widget.profileId),
        ),
        BlocProvider(
          create: (_) => sl<ProfileFollowingListCubit>()..load(widget.profileId),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppAppBar(
          backgroundColor: bg,
          automaticallyImplyLeading: false,
          title: Text(
            titleText,
            style: AppTextStyle.base(18, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: Icon(AppIcons.search.icon),
              onPressed: () => context.router.root.push(const PeopleSearchRoute()),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subTextColor,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Подписчики'),
              Tab(text: 'Подписки'),
            ],
          ),
        ),
        body: AppPillBackNavOverlay(
          child: TabBarView(
            controller: _tabController,
            children: [
              _FollowersTab(profileId: widget.profileId),
              _FollowingTab(profileId: widget.profileId),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowersTab extends StatelessWidget {
  const _FollowersTab({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileFollowersListCubit, ProfileFollowersListState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: AppCircularProgressIndicator()),
          loading: () => const Center(child: AppCircularProgressIndicator()),
          error: (msg) => _ErrorBody(message: msg, onRetry: () => context.read<ProfileFollowersListCubit>().load(profileId)),
          loaded: (items, hasMore, loadingMore) => _FollowListScroll(
            items: items,
            hasMore: hasMore,
            loadingMore: loadingMore,
            emptyLabel: 'Пока нет подписчиков',
            onLoadMore: () => context.read<ProfileFollowersListCubit>().loadMore(),
            onRefresh: () => context.read<ProfileFollowersListCubit>().refresh(),
          ),
        );
      },
    );
  }
}

class _FollowingTab extends StatelessWidget {
  const _FollowingTab({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileFollowingListCubit, ProfileFollowingListState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: AppCircularProgressIndicator()),
          loading: () => const Center(child: AppCircularProgressIndicator()),
          error: (msg) => _ErrorBody(message: msg, onRetry: () => context.read<ProfileFollowingListCubit>().load(profileId)),
          loaded: (items, hasMore, loadingMore) => _FollowListScroll(
            items: items,
            hasMore: hasMore,
            loadingMore: loadingMore,
            emptyLabel: 'Нет подписок',
            onLoadMore: () => context.read<ProfileFollowingListCubit>().loadMore(),
            onRefresh: () => context.read<ProfileFollowingListCubit>().refresh(),
          ),
        );
      },
    );
  }
}

class _FollowListScroll extends StatefulWidget {
  const _FollowListScroll({
    required this.items,
    required this.hasMore,
    required this.loadingMore,
    required this.emptyLabel,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<ProfileFollowRow> items;
  final bool hasMore;
  final bool loadingMore;
  final String emptyLabel;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  State<_FollowListScroll> createState() => _FollowListScrollState();
}

class _FollowListScrollState extends State<_FollowListScroll> {
  late final FollowListRepository _followRepository;
  final Map<String, bool> _followById = {};
  bool _prefetching = false;

  @override
  void initState() {
    super.initState();
    _followRepository = sl<FollowListRepository>();
    unawaited(_prefetch());
  }

  @override
  void didUpdateWidget(covariant _FollowListScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      unawaited(_prefetch());
    }
  }

  Future<void> _prefetch() async {
    if (_prefetching) return;
    final ids = widget.items.map((e) => e.profileId).where((id) => !_followById.containsKey(id)).toList();
    if (ids.isEmpty) return;
    _prefetching = true;
    try {
      final map = await _followRepository.isFollowingBatch(ids);
      if (!mounted) return;
      setState(() => _followById.addAll(map));
    } finally {
      _prefetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final hasMore = widget.hasMore;
    final loadingMore = widget.loadingMore;
    final onLoadMore = widget.onLoadMore;
    final onRefresh = widget.onRefresh;

    if (items.isEmpty && !loadingMore) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: AppDimensions.spaceHuge,
            bottom: AppPillBackNavOverlay.scrollBottomInset(context),
          ),
          children: [
            Center(
              child: Text(
                widget.emptyLabel,
                style: AppTextStyle.base(15, color: AppColors.subTextColor),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120 && hasMore && !loadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: AppPillBackNavOverlay.scrollBottomInset(context)),
          itemCount: items.length + (loadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: AppCircularProgressIndicator(dimension: 22, strokeWidth: 2)),
              );
            }
            final row = items[i];
            return FollowUserRow(row: row, initialIsFollowing: _followById[row.profileId]);
          },
        ),
      ),
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
            Text(message, textAlign: TextAlign.center, style: AppTextStyle.base(14, color: AppColors.subTextColor)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

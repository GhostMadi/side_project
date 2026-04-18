import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/core/shared/app_refresh.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:side_project/feature/chat/presentation/models/chat_outgoing_reply_draft.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_attachment_panel_sheet.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_message_bubble.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_composer_bar.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_day_header.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_message_entrance.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_timeline_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Нижний край ленты (новые сообщения снизу): пользователь «видит» хвост — можно слать mark_read.
bool _chatThreadScrollNearBottomForRead(ScrollMetrics m) {
  if (!m.hasViewportDimension) return false;
  /// Чуть шире, чем типичный «безопасный» inset: после programmatic `jumpTo` позиция иногда ещё не до конца на первом кадре.
  const threshold = 120.0;
  final max = m.maxScrollExtent;
  if (max <= 0) return true;
  return m.pixels >= max - threshold;
}

/// Одна проверка через 450ms часто промахивается: `jumpTo(max)` ещё не применился или нет ScrollNotification.
/// Повторяем с задержками — иначе у собеседника долго не уходит mark_read → у отправителя не меняются галочки до перезахода.
void _scheduleMarkReadRetriesWhenNearBottom(BuildContext context, ScrollController scroll) {
  const delaysMs = <int>[350, 700, 1100, 1700];

  void attempt(int index) {
    if (index >= delaysMs.length) return;
    Future<void>.delayed(Duration(milliseconds: delaysMs[index]), () {
      if (!context.mounted || !scroll.hasClients) return;
      if (_chatThreadScrollNearBottomForRead(scroll.position)) {
        context.read<ChatThreadCubit>().scheduleMarkReadAfterViewingBottom();
        return;
      }
      attempt(index + 1);
    });
  }

  attempt(0);
}

@RoutePage()
class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  late final TextEditingController _composer;
  final GlobalKey<ChatThreadComposerBarState> _composerKey = GlobalKey<ChatThreadComposerBarState>();
  final ScrollController _scrollController = ScrollController();

  /// Якоря строк для перехода к сообщению по тапу на цитату ответа (`Scrollable.ensureVisible`).
  final Map<String, GlobalKey> _messageAnchorKeys = {};

  GlobalKey _anchorFor(String stableBubbleKey) =>
      _messageAnchorKeys.putIfAbsent(stableBubbleKey, GlobalKey.new);

  void _scrollToReferencedMessage(String referencedMessageId) {
    final id = referencedMessageId.trim();
    if (id.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _messageAnchorKeys[id]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }

  /// Предыдущее состояние cubit для сравнения хвоста списка в listener.
  ChatThreadState? _previousBlocEmit;

  /// Pull-to-refresh: не дёргать скролл и анимацию хвоста в [BlocListener].
  bool _suppressListenerScroll = false;

  /// Хвост сообщения, для которого показываем входящую анимацию один раз.
  String? _entranceFocusId;

  /// Ответ на сообщение (панель над композером).
  ChatOutgoingReplyDraft? _replyDraft;

  void _clearReplyDraft() => setState(() => _replyDraft = null);

  void _onReplyToMessage(ChatMessageEnriched data) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    setState(() => _replyDraft = ChatOutgoingReplyDraft.fromEnriched(data, myId));
  }

  /// Чаты: скролл как обычно (старые сверху), липкая дата цепляется к верху экрана.
  /// Горизонтальные отступы ленты от краёв экрана.
  static const double _bubbleInsetLeft = 14;
  static const double _bubbleInsetRight = 12;

  @override
  void initState() {
    super.initState();
    _composer = TextEditingController();
  }

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatThreadPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _messageAnchorKeys.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Future<void> _showAttachmentChooser() async {
    final choice = await ChatAttachmentPanelSheet.show(context);
    if (!mounted || choice == null) return;
    switch (choice) {
      case ChatAttachmentChoice.gallery:
        await _composerKey.currentState?.pickGalleryAfterSheet();
      case ChatAttachmentChoice.camera:
        await _composerKey.currentState?.pickCameraAfterSheet();
      case ChatAttachmentChoice.file:
        await _composerKey.currentState?.pickDocumentsAfterSheet();
    }
  }

  /// Подгрузка истории: верх списка (малый offset).
  bool _shouldLoadOlder(ScrollNotification n, bool hasMore, bool isLoadingMore) {
    if (!hasMore || isLoadingMore) return false;
    final m = n.metrics;
    if (!m.hasViewportDimension) return false;
    return m.pixels <= 140;
  }

  void _scrollToBottomAfterFrame() {
    void jumpMax() {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }

    // Два кадра: после новых sliver maxScrollExtent обновляется не сразу.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jumpMax();
      WidgetsBinding.instance.addPostFrameCallback((_) => jumpMax());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey<String>(widget.conversationId),
      providers: [BlocProvider(create: (_) => sl<ChatThreadCubit>()..load(widget.conversationId))],
      child: DefaultStickyHeaderController(
        child: BlocListener<ChatThreadCubit, ChatThreadState>(
          listenWhen: (prev, cur) {
            final loaded = cur.maybeMap(loaded: (s) => s, orElse: () => null);
            if (loaded == null || loaded.items.isEmpty) return false;
            final prevLoaded = prev.maybeMap(loaded: (s) => s, orElse: () => null);
            if (prevLoaded == null || prevLoaded.items.isEmpty) return true;
            // Новый хвост (сообщение снизу). Подгрузка истории меняет только начало списка —
            // last не меняется, слушатель молчит — без скролла вниз и без «перерисовки всей страницы».
            return loaded.items.last.stableBubbleKey != prevLoaded.items.last.stableBubbleKey;
          },
          listener: (context, state) {
            final prev = _previousBlocEmit;
            _previousBlocEmit = state;
            if (_suppressListenerScroll) return;
            state.maybeMap(
              loaded: (loaded) {
                void scheduleReadIfStillAtBottom() {
                  _scheduleMarkReadRetriesWhenNearBottom(context, _scrollController);
                }

                if (loaded.items.isEmpty) {
                  _scrollToBottomAfterFrame();
                  return;
                }
                final prevLoaded = prev?.maybeMap(loaded: (s) => s, orElse: () => null);
                if (prevLoaded == null || prevLoaded.items.isEmpty) {
                  _scrollToBottomAfterFrame();
                  scheduleReadIfStillAtBottom();
                  return;
                }
                final tailChanged =
                    loaded.items.last.stableBubbleKey != prevLoaded.items.last.stableBubbleKey;
                if (tailChanged) {
                  setState(() => _entranceFocusId = loaded.items.last.stableBubbleKey);
                  Future<void>.delayed(const Duration(milliseconds: 260), () {
                    if (mounted) setState(() => _entranceFocusId = null);
                  });
                  _scrollToBottomAfterFrame();
                  scheduleReadIfStillAtBottom();
                }
              },
              orElse: () {},
            );
          },
          child: Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppAppBar(
              automaticallyImplyLeading: true,
              title: Text('Чат', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
            ),
            body: Builder(
              builder: (context) {
                final bottomGap = MediaQuery.viewPaddingOf(context).bottom + 70;
                return _ChatThreadResumeSync(
                  scrollController: _scrollController,
                  child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: BlocBuilder<ChatThreadCubit, ChatThreadState>(
                        builder: (context, state) {
                          return state.when(
                            initial: () => const Center(child: AppCircularProgressIndicator()),
                            loading: () => const Center(child: AppCircularProgressIndicator()),
                            error: (m) => Center(
                              child: Text(m, style: AppTextStyle.base(14, color: AppColors.subTextColor)),
                            ),
                            loaded: (conversationId, items, isLoadingMore, hasMore, errorMessage, _) {
                              return MediaQuery.removePadding(
                                context: context,
                                removeRight: true,
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (_shouldLoadOlder(n, hasMore, isLoadingMore)) {
                                      context.read<ChatThreadCubit>().loadMore();
                                    }
                                    if ((n is ScrollUpdateNotification || n is ScrollEndNotification) &&
                                        n.metrics.axis == Axis.vertical &&
                                        _chatThreadScrollNearBottomForRead(n.metrics)) {
                                      context.read<ChatThreadCubit>().scheduleMarkReadAfterViewingBottom();
                                    }
                                    return false;
                                  },
                                  child: AppRefresh(
                                    onRefresh: () async {
                                      _suppressListenerScroll = true;
                                      try {
                                        await context.read<ChatThreadCubit>().refresh(syncReadReceipt: false);
                                        if (context.mounted &&
                                            _scrollController.hasClients &&
                                            _chatThreadScrollNearBottomForRead(_scrollController.position)) {
                                          context.read<ChatThreadCubit>().scheduleMarkReadAfterViewingBottom();
                                        }
                                      } finally {
                                        _suppressListenerScroll = false;
                                      }
                                    },
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      physics: const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      slivers: [
                                        if (items.isEmpty)
                                          SliverFillRemaining(
                                            hasScrollBody: false,
                                            child: Padding(
                                              padding: EdgeInsets.only(bottom: bottomGap),
                                              child: Center(
                                                child: Text(
                                                  'Нет сообщений',
                                                  style: AppTextStyle.base(14, color: AppColors.subTextColor),
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          ..._buildDaySlivers(context, items, _entranceFocusId),
                                        SliverPadding(
                                          padding: EdgeInsets.only(bottom: bottomGap),
                                          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: BlocBuilder<ChatThreadCubit, ChatThreadState>(
                        buildWhen: (p, c) =>
                            p.maybeMap(loaded: (a) => a.isLoadingMore, orElse: () => false) !=
                            c.maybeMap(loaded: (b) => b.isLoadingMore, orElse: () => false),
                        builder: (context, state) {
                          final loadingMore =
                              state.maybeMap(loaded: (s) => s.isLoadingMore, orElse: () => false);
                          if (!loadingMore) return const SizedBox.shrink();
                          return const IgnorePointer(
                            child: Center(
                              child: AppCircularProgressIndicator(dimension: 22, strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ChatThreadComposerBar(
                        key: _composerKey,
                        controller: _composer,
                        conversationId: widget.conversationId,
                        showAttachmentChooser: _showAttachmentChooser,
                        replyDraft: _replyDraft,
                        onClearReplyDraft: _clearReplyDraft,
                      ),
                    ),
                  ],
                ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Дни снизу вверх по времени: старые секции выше, «Сегодня» у композера; липкий заголовок — к верху экрана.
  List<Widget> _buildDaySlivers(BuildContext context, List<ChatThreadItem> items, String? entranceFocusId) {
    if (items.isEmpty) return const [];
    final sections = splitChatItemsByDay(items);
    if (sections.isEmpty) return const [];

    final out = <Widget>[];
    for (var si = 0; si < sections.length; si++) {
      final section = sections[si];
      final chronological = section.messagesAsc;
      final isLastSection = si == sections.length - 1;
      out.add(
        SliverStickyHeader(
          header: ChatThreadDayHeader(day: section.day),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final item = chronological[i];
              final myId = Supabase.instance.client.auth.currentUser?.id;
              final curKey = item.groupSenderKey(myId);
              final prevKey = i > 0 ? chronological[i - 1].groupSenderKey(myId) : null;
              final nextKey =
                  i + 1 < chronological.length ? chronological[i + 1].groupSenderKey(myId) : null;
              final groupWithPrevious =
                  prevKey != null && curKey != null && prevKey.isNotEmpty && prevKey == curKey;
              final groupWithNext =
                  nextKey != null && curKey != null && nextKey.isNotEmpty && nextKey == curKey;
              final animateEntrance =
                  entranceFocusId != null &&
                  isLastSection &&
                  i == chronological.length - 1 &&
                  item.stableBubbleKey == entranceFocusId;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  _bubbleInsetLeft,
                  groupWithPrevious ? 0 : 2,
                  _bubbleInsetRight,
                  groupWithNext ? 1 : 4,
                ),
                child: ChatThreadMessageEntrance(
                  key: _anchorFor(item.stableBubbleKey),
                  animate: animateEntrance,
                  child: ChatMessageBubble(
                    item: item,
                    groupWithPrevious: groupWithPrevious,
                    groupWithNext: groupWithNext,
                    onRetryOptimistic: (localId) => context.read<ChatThreadCubit>().retryPending(localId),
                    onReply: _onReplyToMessage,
                    onReferencedMessageTap: _scrollToReferencedMessage,
                  ),
                ),
              );
            }, childCount: chronological.length),
          ),
        ),
      );
    }
    return out;
  }
}

/// После возврата из фона: синк ленты без mark_read; mark_read только если пользователь всё ещё у нижнего края.
class _ChatThreadResumeSync extends StatefulWidget {
  const _ChatThreadResumeSync({required this.scrollController, required this.child});

  final ScrollController scrollController;
  final Widget child;

  @override
  State<_ChatThreadResumeSync> createState() => _ChatThreadResumeSyncState();
}

class _ChatThreadResumeSyncState extends State<_ChatThreadResumeSync> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ChatThreadCubit>().refresh(syncReadReceipt: false);
      if (!mounted) return;
      if (widget.scrollController.hasClients &&
          _chatThreadScrollNearBottomForRead(widget.scrollController.position)) {
        context.read<ChatThreadCubit>().scheduleMarkReadAfterViewingBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:side_project/feature/chat/presentation/models/chat_outgoing_reply_draft.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_attachment_panel_sheet.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_message_bubble.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_referenced_jump_pulse.dart';
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

  String _anchorKeyFor(String stableBubbleKey) => stableBubbleKey.trim().toLowerCase();

  GlobalKey _anchorFor(String stableBubbleKey) =>
      _messageAnchorKeys.putIfAbsent(_anchorKeyFor(stableBubbleKey), GlobalKey.new);

  /// Монотонно растёт на каждый тап по цитате — предыдущая цепочка подгрузки + скролл игнорируются.
  int _referencedNavOp = 0;

  /// Жест пользователя во время программной прокрутки к цитате — отменяем добивку `ensureVisible`.
  bool _cancelReferencedNav = false;

  /// [blocContext] — контекст **ниже** [BlocProvider], иначе [ProviderNotFoundException]
  /// (контекст [State] — предок провайдера).
  Future<void> _scrollToReferencedMessage(BuildContext blocContext, String referencedMessageId) async {
    final trimmed = referencedMessageId.trim();
    if (trimmed.isEmpty) return;

    final op = ++_referencedNavOp;
    _cancelReferencedNav = false;

    final cubit = blocContext.read<ChatThreadCubit>();
    final ok = await cubit.ensureReferencedMessageInView(
      trimmed,
      shouldContinue: () => mounted && op == _referencedNavOp && !_cancelReferencedNav,
    );

    if (!mounted || op != _referencedNavOp || !ok || _cancelReferencedNav) return;

    await _revealReferencedBubble(cubit, trimmed, op);
  }

  String? _referencedPulseKey;
  int _referencedPulseSeq = 0;

  void _triggerReferencedPulse(String normalizedAnchorKey) {
    if (!mounted) return;
    setState(() {
      _referencedPulseKey = normalizedAnchorKey;
      _referencedPulseSeq++;
    });
  }

  int? _indexOfAnchoredMessage(String rawId, List<ChatThreadItem> items) {
    final want = _anchorKeyFor(rawId);
    for (var i = 0; i < items.length; i++) {
      if (_anchorKeyFor(items[i].stableBubbleKey) == want) return i;
    }
    return null;
  }

  /// У [SliverList] строка вне viewport часто **не построена** → у [GlobalKey] нет context.
  /// Сначала прыжок по индексу в ленте, затем несколько кадров и лёгкие сдвиги, пока якорь не появится.
  Future<void> _revealReferencedBubble(ChatThreadCubit cubit, String trimmedId, int op) async {
    final want = _anchorKeyFor(trimmedId);

    void ensureIfMounted() {
      final ctx = _messageAnchorKeys[want]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    }

    final st = cubit.state;
    final loaded = st.maybeMap(loaded: (s) => s, orElse: () => null);
    if (loaded != null && _scrollController.hasClients) {
      final idx = _indexOfAnchoredMessage(trimmedId, loaded.items);
      final n = loaded.items.length;
      if (idx != null && n > 1) {
        final pos = _scrollController.position;
        final t = idx / (n - 1);
        _scrollController.jumpTo((t * pos.maxScrollExtent).clamp(pos.minScrollExtent, pos.maxScrollExtent));
      }
    }

    var revealed = false;
    for (var i = 0; i < 28; i++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || op != _referencedNavOp || _cancelReferencedNav) return;
      ensureIfMounted();
      if (_messageAnchorKeys[want]?.currentContext != null) {
        revealed = true;
        break;
      }

      if (_scrollController.hasClients && i < 24) {
        final p = _scrollController.position;
        final step = p.viewportDimension * 0.42;
        // Ответ обычно на более старое сообщение → в первую очередь тянем вверх по ленте.
        final delta = (i % 4 < 2) ? -step : step * 0.55;
        _scrollController.jumpTo((p.pixels + delta).clamp(p.minScrollExtent, p.maxScrollExtent));
      }
    }

    if (!mounted || op != _referencedNavOp || _cancelReferencedNav) return;
    if (revealed || _messageAnchorKeys[want]?.currentContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || op != _referencedNavOp) return;
        _triggerReferencedPulse(want);
      });
    }
  }

  /// Предыдущее состояние cubit для сравнения хвоста списка в listener.
  ChatThreadState? _previousBlocEmit;

  /// Снимок скролла перед подгрузкой старых сообщений сверху ([loadMore] из ленты).
  ({double pixels, double maxScrollExtent})? _scrollBeforeOlderPage;

  /// Хвост сообщения, для которого показываем входящую анимацию один раз.
  String? _entranceFocusId;

  /// Ответ на сообщение (панель над композером).
  ChatOutgoingReplyDraft? _replyDraft;

  /// [scheduleMarkReadAfterViewingBottom] на каждый [ScrollUpdate] у низа даёт сотни вызовов и шум в [ChatRead] логах.
  /// Ограничиваем частоту; [ScrollEndNotification] всегда пробивает — пользователь отпустил палец у хвоста.
  int _lastMarkReadScheduleMs = 0;

  void _maybeScheduleMarkReadAfterScroll(ScrollNotification n, BuildContext context) {
    if ((n is! ScrollUpdateNotification && n is! ScrollEndNotification) ||
        n.metrics.axis != Axis.vertical ||
        !_chatThreadScrollNearBottomForRead(n.metrics)) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (n is ScrollUpdateNotification) {
      const gapMs = 350;
      if (now - _lastMarkReadScheduleMs < gapMs) return;
    }
    _lastMarkReadScheduleMs = now;
    context.read<ChatThreadCubit>().scheduleMarkReadAfterViewingBottom();
  }

  void _clearReplyDraft() => setState(() => _replyDraft = null);

  void _onReplyToMessage(ChatMessageEnriched data) {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    setState(() => _replyDraft = ChatOutgoingReplyDraft.fromEnriched(data, myId));
  }

  /// Чаты: скролл как обычно (старые сверху), липкая дата цепляется к верху экрана.
  /// Горизонтальные отступы ленты от краёв экрана.
  static const double _bubbleInsetLeft = 11;
  static const double _bubbleInsetRight = 10;

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

  /// Подгрузка истории: пользователь близко к **верху** ленты (старые сообщения).
  static const double _loadOlderLeadPixels = 520;

  /// [ScrollNotification.metrics] часто **не тот же объект**, что [ScrollController.position],
  /// поэтому [identical] ломал подгрузку. Сверяем размеры viewport — того же [Scrollable] достаточно.
  bool _metricsLikelyPrimaryThread(ScrollMetrics m) {
    if (!_scrollController.hasClients) return false;
    final p = _scrollController.position;
    if (m.axis != p.axis || !m.hasViewportDimension) return false;
    const tol = 8.0;
    return (m.viewportDimension - p.viewportDimension).abs() <= tol &&
        (m.minScrollExtent - p.minScrollExtent).abs() <= tol &&
        (m.maxScrollExtent - p.maxScrollExtent).abs() <= tol;
  }

  bool _shouldLoadOlder(ScrollNotification n, bool hasMore, bool isLoadingMore) {
    if (!hasMore || isLoadingMore) return false;
    if (n.metrics.axis != Axis.vertical) return false;
    final m = n.metrics;
    if (!m.hasViewportDimension) return false;
    if (!_metricsLikelyPrimaryThread(m)) return false;

    /// Нет вертикального скролла — лента короче экрана; всё равно подгружаем историю, пока [hasMore].
    if (m.maxScrollExtent <= 0) return true;

    return m.pixels <= _loadOlderLeadPixels;
  }

  void _tryCaptureOlderScrollAnchorAndLoadMore(BuildContext context) {
    if (!_scrollController.hasClients) {
      unawaited(context.read<ChatThreadCubit>().loadMore());
      return;
    }
    final p = _scrollController.position;
    _scrollBeforeOlderPage = (pixels: p.pixels, maxScrollExtent: p.maxScrollExtent);
    unawaited(context.read<ChatThreadCubit>().loadMore());
  }

  void _restoreScrollAfterOlderPageLoaded() {
    final anchor = _scrollBeforeOlderPage;
    if (anchor == null) return;
    _scrollBeforeOlderPage = null;
    final oldPixels = anchor.pixels;
    final oldMax = anchor.maxScrollExtent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final p = _scrollController.position;
      final delta = p.maxScrollExtent - oldMax;
      if (delta <= 1) return;
      _scrollController.jumpTo((oldPixels + delta).clamp(p.minScrollExtent, p.maxScrollExtent));
    });
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
            final p = prev.maybeMap(loaded: (s) => s, orElse: () => null);
            final c = cur.maybeMap(loaded: (s) => s, orElse: () => null);
            return p != null && c != null && p.isLoadingMore && !c.isLoadingMore;
          },
          listener: (context, state) => _restoreScrollAfterOlderPageLoaded(),
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
                                        if (n is ScrollStartNotification && n.dragDetails != null) {
                                          _cancelReferencedNav = true;
                                        }
                                        if (_shouldLoadOlder(n, hasMore, isLoadingMore)) {
                                          _tryCaptureOlderScrollAnchorAndLoadMore(context);
                                        }
                                        _maybeScheduleMarkReadAfterScroll(n, context);
                                        return false;
                                      },
                                      child: CustomScrollView(
                                        controller: _scrollController,
                                        // Чтобы якоря「цитата → оригинал」чаще успели построиться рядом с viewport.
                                        cacheExtent: 1800,
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
                                                    style: AppTextStyle.base(
                                                      14,
                                                      color: AppColors.subTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            ..._buildDaySlivers(
                                              context,
                                              items,
                                              _entranceFocusId,
                                              _referencedPulseKey,
                                              _referencedPulseSeq,
                                            ),
                                          SliverPadding(
                                            padding: EdgeInsets.only(bottom: bottomGap),
                                            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
                                          ),
                                        ],
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
                              final loadingMore = state.maybeMap(
                                loaded: (s) => s.isLoadingMore,
                                orElse: () => false,
                              );
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
      ),
    );
  }

  /// Дни снизу вверх по времени: старые секции выше, «Сегодня» у композера; липкий заголовок — к верху экрана.
  List<Widget> _buildDaySlivers(
    BuildContext context,
    List<ChatThreadItem> items,
    String? entranceFocusId,
    String? referencedPulseKey,
    int referencedPulseSeq,
  ) {
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
            delegate: SliverChildBuilderDelegate((itemContext, i) {
              final item = chronological[i];
              final myId = Supabase.instance.client.auth.currentUser?.id;
              final curKey = item.groupSenderKey(myId);
              final prevKey = i > 0 ? chronological[i - 1].groupSenderKey(myId) : null;
              final nextKey = i + 1 < chronological.length ? chronological[i + 1].groupSenderKey(myId) : null;
              final groupWithPrevious =
                  prevKey != null && curKey != null && prevKey.isNotEmpty && prevKey == curKey;
              final groupWithNext =
                  nextKey != null && curKey != null && nextKey.isNotEmpty && nextKey == curKey;
              final animateEntrance =
                  entranceFocusId != null &&
                  isLastSection &&
                  i == chronological.length - 1 &&
                  item.stableBubbleKey == entranceFocusId;
              final bubbleKeyNorm = _anchorKeyFor(item.stableBubbleKey);
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  _bubbleInsetLeft,
                  groupWithPrevious ? 0 : 2,
                  _bubbleInsetRight,
                  groupWithNext ? 1 : 4,
                ),
                child: ChatReferencedJumpPulse(
                  shouldPulse: referencedPulseKey != null && bubbleKeyNorm == referencedPulseKey,
                  pulseGeneration: referencedPulseSeq,
                  child: ChatThreadMessageEntrance(
                    key: _anchorFor(item.stableBubbleKey),
                    animate: animateEntrance,
                    child: ChatMessageBubble(
                      item: item,
                      groupWithPrevious: groupWithPrevious,
                      groupWithNext: groupWithNext,
                      onRetryOptimistic: (localId) =>
                          itemContext.read<ChatThreadCubit>().retryPending(localId),
                      onReply: _onReplyToMessage,
                      onReferencedMessageTap: (id) => unawaited(_scrollToReferencedMessage(itemContext, id)),
                    ),
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
  /// Запасной REST, если broadcast `peer_read` или postgres_changes не дошли (основной путь — WS broadcast).
  static const _peerCursorPollInterval = Duration(seconds: 90);

  Timer? _peerCursorPoll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _peerCursorPoll = Timer.periodic(_peerCursorPollInterval, (_) {
      if (!mounted) return;
      unawaited(context.read<ChatThreadCubit>().syncPeerReadCursorsOnly());
    });
  }

  @override
  void dispose() {
    _peerCursorPoll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      unawaited(context.read<ChatThreadCubit>().syncPeerReadCursorsOnly());
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

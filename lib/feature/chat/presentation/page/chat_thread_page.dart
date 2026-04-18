import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_circular_progress_indicator.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_attachment_panel_sheet.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_message_bubble.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_composer_bar.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_day_header.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_message_entrance.dart';
import 'package:side_project/feature/chat/presentation/widget/chat_thread_timeline_utils.dart';

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

  /// Предыдущее состояние cubit для сравнения хвоста списка в listener.
  ChatThreadState? _previousBlocEmit;

  /// Хвост сообщения, для которого показываем входящую анимацию один раз.
  String? _entranceFocusId;

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
      providers: [BlocProvider(create: (_) => sl<ChatThreadCubit>()..load(widget.conversationId))],
      child: DefaultStickyHeaderController(
        child: BlocListener<ChatThreadCubit, ChatThreadState>(
          listenWhen: (prev, cur) {
            final loaded = cur.maybeMap(loaded: (s) => s, orElse: () => null);
            if (loaded == null || loaded.items.isEmpty) return false;
            final prevLoaded = prev.maybeMap(loaded: (s) => s, orElse: () => null);
            if (prevLoaded == null) return true;
            // Нельзя полагаться только на длину: при скользящем окне новое сообщение
            // сдвигает окно — счётчик тот же, но хвост другой; без скролла вниз
            // пузырь «не виден», хотя данные уже в state.
            if (loaded.items.length != prevLoaded.items.length) return true;
            return loaded.items.last.stableBubbleKey != prevLoaded.items.last.stableBubbleKey;
          },
          listener: (context, state) {
            final prev = _previousBlocEmit;
            _previousBlocEmit = state;
            state.maybeMap(
              loaded: (loaded) {
                if (loaded.items.isEmpty) {
                  _scrollToBottomAfterFrame();
                  return;
                }
                final prevLoaded = prev?.maybeMap(loaded: (s) => s, orElse: () => null);
                if (prevLoaded == null || prevLoaded.items.isEmpty) {
                  _scrollToBottomAfterFrame();
                  return;
                }
                final tailChanged =
                    loaded.items.last.stableBubbleKey != prevLoaded.items.last.stableBubbleKey;
                // Анимация входа при новом хвосте — и когда окно того же размера «сдвинулось».
                if (tailChanged) {
                  setState(() => _entranceFocusId = loaded.items.last.stableBubbleKey);
                  Future<void>.delayed(const Duration(milliseconds: 260), () {
                    if (mounted) setState(() => _entranceFocusId = null);
                  });
                }
                _scrollToBottomAfterFrame();
              },
              orElse: () => _scrollToBottomAfterFrame(),
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
                return Stack(
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
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    onRefresh: () => context.read<ChatThreadCubit>().refresh(),
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      physics: const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      slivers: [
                                        if (isLoadingMore)
                                          const SliverToBoxAdapter(
                                            child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Center(
                                                child: AppCircularProgressIndicator(
                                                  dimension: 22,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                          ),
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
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ChatThreadComposerBar(
                        key: _composerKey,
                        controller: _composer,
                        conversationId: widget.conversationId,
                        showAttachmentChooser: _showAttachmentChooser,
                      ),
                    ),
                  ],
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
              final animateEntrance =
                  entranceFocusId != null &&
                  isLastSection &&
                  i == chronological.length - 1 &&
                  item.stableBubbleKey == entranceFocusId;
              return Padding(
                padding: EdgeInsets.fromLTRB(_bubbleInsetLeft, 0, _bubbleInsetRight, 4),
                child: ChatThreadMessageEntrance(
                  key: ValueKey(item.stableBubbleKey),
                  animate: animateEntrance,
                  child: ChatMessageBubble(
                    item: item,
                    onRetryOptimistic: (localId) => context.read<ChatThreadCubit>().retryPending(localId),
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

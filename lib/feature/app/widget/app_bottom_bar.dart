import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/presentation/cubit/chat_conversations_list_cubit.dart';
import 'package:side_project/l10n/app_localizations.dart';

/// Сколько диалогов с непрочитанным (не сумма сообщений).
int _unreadConversationsCount(List<ChatConversationEnriched> items) {
  var n = 0;
  for (final e in items) {
    if (e.unreadCount > 0) n++;
  }
  return n;
}

/// 1–9 как есть; с 10 чатов — «9+».
String? _chatTabUnreadBadgeLabel(int unreadChats) {
  if (unreadChats <= 0) return null;
  if (unreadChats > 9) return '9+';
  return '$unreadChats';
}

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key});

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> with SingleTickerProviderStateMixin {
  late AnimationController _jellyController;
  late Animation<double> _jellyAnimation;

  @override
  void initState() {
    super.initState();
    _jellyController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _jellyAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_jellyController);
  }

  void _triggerJelly() {
    HapticFeedback.heavyImpact();

    setState(() {
      _jellyAnimation = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _jellyController, curve: Curves.elasticOut));
    });

    _jellyController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _jellyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabsRouter = AutoTabsRouter.of(context);
    final currentIndex = tabsRouter.activeIndex;

    return AnimatedBuilder(
      animation: _jellyAnimation,
      builder: (context, child) {
        final double scale = _jellyAnimation.value;
        final double vScale = 1.0 + (1.0 - scale) * 0.5;

        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(scale, vScale, 1.0)..setEntry(3, 2, 0.001),
          child: child,
        );
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 104),
        decoration: BoxDecoration(
          color: AppColors.bottomBarColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const tabCount = 3;
            final segmentWidth = constraints.maxWidth / tabCount;
            return BlocBuilder<ChatConversationsListCubit, ChatConversationsListState>(
              buildWhen: (p, c) => p != c,
              builder: (context, convState) {
                final unreadChats = convState.maybeMap(
                  loaded: (s) => _unreadConversationsCount(s.items),
                  orElse: () => 0,
                );
                final chatBadge = _chatTabUnreadBadgeLabel(unreadChats);

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      left: currentIndex * segmentWidth,
                      width: segmentWidth,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: segmentWidth * 0.85,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.bottomBarSegment,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(tabCount, (index) {
                        return _BottomItem(
                          index: index,
                          icon: _getIconForIndex(index),
                          label: _getLabelForIndex(index, l10n),
                          isSelected: currentIndex == index,
                          badgeLabel: index == 1 ? chatBadge : null,
                          onTap: () {
                            if (currentIndex != index) {
                              tabsRouter.setActiveIndex(index);
                              _triggerJelly();
                            }
                          },
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    return switch (index) {
      0 => AppIcons.map.icon,
      1 => AppIcons.chat.icon,
      _ => AppIcons.user.icon,
    };
  }

  String _getLabelForIndex(int index, AppLocalizations l10n) {
    return switch (index) {
      0 => l10n.mapTabLabel,
      1 => l10n.chatTabLabel,
      _ => l10n.profileTabLabel,
    };
  }
}

class _UnreadChatsTabBadge extends StatelessWidget {
  const _UnreadChatsTabBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final two = label.length > 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: two ? 3.5 : 5, vertical: 1.5),
      constraints: const BoxConstraints(minWidth: 17, minHeight: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.bottomBarColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: two ? 8.5 : 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _BottomItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;

  /// Число непрочитанных **диалогов** для вкладки чата (строка уже отформатирована: «3» или «9+»).
  final String? badgeLabel;

  final VoidCallback onTap;

  const _BottomItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeLabel,
  });

  @override
  State<_BottomItem> createState() => _BottomItemState();
}

class _BottomItemState extends State<_BottomItem> with SingleTickerProviderStateMixin {
  late AnimationController _clickController;

  @override
  void initState() {
    super.initState();
    _clickController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  void _handleTap() {
    widget.onTap();
    _clickController.forward().then((_) => _clickController.reverse());
  }

  @override
  void dispose() {
    _clickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.1,
          ).animate(CurvedAnimation(parent: _clickController, curve: Curves.easeOut)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final bool isEntering = child.key == ValueKey(widget.isSelected);
                  final bouncyAnim = CurvedAnimation(
                    parent: animation,
                    curve: isEntering ? Curves.elasticOut : Curves.easeInBack,
                  );

                  return AnimatedBuilder(
                    animation: bouncyAnim,
                    builder: (context, _) {
                      final double val = bouncyAnim.value;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..translateByDouble(0.0, isEntering ? (1 - val) * 10 : 0.0, 0.0, 1.0)
                          ..scaleByDouble(val.clamp(0.0, 1.5), val.clamp(0.0, 1.5), 1.0, 1.0),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                  );
                },
                child: SizedBox(
                  key: ValueKey<bool>(widget.isSelected),
                  width: 34,
                  height: 26,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: widget.isSelected ? 26 : 22,
                        color: widget.isSelected
                            ? AppColors.bottomBarActiveIcon
                            : AppColors.bottomBarInactiveIcon,
                        shadows: widget.isSelected
                            ? [
                                Shadow(
                                  color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      if (widget.badgeLabel != null)
                        Positioned(
                          right: -4,
                          top: -6,
                          child: _UnreadChatsTabBadge(label: widget.badgeLabel!),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 2),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: AppColors.bottomBarActiveIcon,
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.9,
                      shadows: [
                        Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.5), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

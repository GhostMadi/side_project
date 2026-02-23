import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/icons/app_icons.dart';
import 'package:side_project/core/shared/app_size.dart';

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
        height: AppSize.h(8.5),
        margin: EdgeInsets.symmetric(horizontal: AppSize.w(8)),
        decoration: BoxDecoration(
          color: AppColors.bottomBarColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppSize.h(4)),
          border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / 3;
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
                      height: AppSize.h(7),
                      decoration: BoxDecoration(
                        color: AppColors.bottomBarSegment,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(3, (index) {
                    return _BottomItem(
                      index: index,
                      icon: _getIconForIndex(index),
                      label: _getLabelForIndex(index),
                      isSelected: currentIndex == index,
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
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    if (index == 0) return AppIcons.map.icon;
    if (index == 1) return Icons.radar;
    return AppIcons.user.icon;
  }

  String _getLabelForIndex(int index) {
    final labels = ["MAP", "RADAR", "PROFILE"];
    return labels[index];
  }
}

class _BottomItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
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
                child: Icon(
                  widget.icon,
                  key: ValueKey<bool>(widget.isSelected),
                  size: widget.isSelected ? AppSize.h(3.0) : AppSize.h(2.6),
                  color: widget.isSelected ? AppColors.bottomBarActiveIcon : AppColors.bottomBarInactiveIcon,
                  shadows: widget.isSelected
                      ? [Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.6), blurRadius: 10)]
                      : null,
                ),
              ),
              // Секция с анимированным текстом
              if (widget.isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(top: AppSize.h(0.2)),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: AppColors.bottomBarActiveIcon,
                      fontSize: AppSize.h(1.2),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';
import 'package:side_project/core/shared/app_size.dart';

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    final currentIndex = tabsRouter.activeIndex;
    final color = context.appColors;
    return Container(
      height: AppSize.h(8),
      margin: EdgeInsets.only(
        left: AppSize.w(10),
        right: AppSize.w(10),
        bottom: AppSize.h(2),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w(4),
        vertical: AppSize.h(1.2),
      ),
      decoration: BoxDecoration(
        color: color.secondary,
        borderRadius: BorderRadius.circular(AppSize.h(4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / 3;

          return Stack(
            children: [
              // 🔥 ДВИЖУЩАЯСЯ ПОДЛОЖКА ИДЕАЛЬНОГО РАЗМЕРА
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: currentIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _BottomItem(
                      index: 0,
                      icon: Icons.home,
                      isSelected: currentIndex == 0,
                      onTap: () => tabsRouter.setActiveIndex(0),
                    ),
                  ),
                  Expanded(
                    child: _BottomItem(
                      index: 1,
                      icon: Icons.auto_graph,
                      isSelected: currentIndex == 1,
                      onTap: () => tabsRouter.setActiveIndex(1),
                    ),
                  ),
                  Expanded(
                    child: _BottomItem(
                      index: 2,
                      icon: Icons.usb_rounded,
                      isSelected: currentIndex == 2,
                      onTap: () => tabsRouter.setActiveIndex(2),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.index,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  State<_BottomItem> createState() => _BottomItemState();
}

class _BottomItemState extends State<_BottomItem> {
  double bounceOffset = 0;
  int bounceKey = 0;

  void triggerBounce() {
    setState(() {
      bounceKey++;
      bounceOffset = -AppSize.h(1.2);
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          bounceOffset = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dropDistance = AppSize.h(5);
    final color = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap();
        triggerBounce();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(AppSize.h(1.4)),

        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            // 🔻 Серая иконка уходит вниз
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutSine,
              top: widget.isSelected ? dropDistance : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isSelected ? 0 : 1,
                child: Icon(
                  widget.icon,
                  size: AppSize.h(2.6),
                  color: color.primary.withValues(alpha: 0.3),
                ),
              ),
            ),

            // 🔺 Белая иконка выполняет bounce ВСЕГДА
            AnimatedPositioned(
              key: ValueKey(bounceKey),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              top: widget.isSelected ? bounceOffset : -dropDistance,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: widget.isSelected ? 1 : 0,
                child: Icon(
                  widget.icon,
                  size: AppSize.h(2.9),
                  color: color.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

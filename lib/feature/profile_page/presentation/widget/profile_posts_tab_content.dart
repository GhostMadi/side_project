import 'package:flutter/material.dart';

/// Контент под [ProfilePostsTabBar]: **горизонтальный свайп** переключает вкладки (и синхронизируется
/// с [index] из родителя), не только тап по табу.
class ProfilePostsTabContent extends StatelessWidget {
  const ProfilePostsTabContent({
    super.key,
    required this.index,
    required this.onIndexChanged,
    required this.posts,
    required this.markers,
  });

  final int index;
  final ValueChanged<int> onIndexChanged;
  final Widget posts;
  final Widget markers;

  static const double _minFlingSpeed = 320;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onHorizontalDragEnd: (d) {
        final v = d.velocity.pixelsPerSecond;
        // Слабый или явно «вертикальный» жест — не путаем с лентой
        if (v.dx.abs() < _minFlingSpeed) return;
        if (v.dx.abs() < v.dy.abs() * 1.15) return;
        if (v.dx < 0 && index < 1) onIndexChanged(1);
        if (v.dx > 0 && index > 0) onIndexChanged(0);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: index == 0
            ? KeyedSubtree(key: const ValueKey('tab_posts'), child: posts)
            : KeyedSubtree(key: const ValueKey('tab_marked_posts'), child: markers),
      ),
    );
  }
}

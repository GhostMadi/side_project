import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Табы профиля (посты / маркеры): иконка + линия снизу; две **равные** половины. Свайп между
/// вкладками — в [ProfilePostsTabContent] под панелью, не в самой [TabBar].
class ProfilePostsTabBar extends StatefulWidget {
  const ProfilePostsTabBar({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<ProfilePostsTabBar> createState() => _ProfilePostsTabBarState();
}

class _ProfilePostsTabBarState extends State<ProfilePostsTabBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: widget.index.clamp(0, 1), vsync: this);
  }

  @override
  void didUpdateWidget(ProfilePostsTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (_tabController.index == widget.index) return;
    _tabController.animateTo(
      widget.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _iconColor(int i, Color active, Color muted) {
    return _tabController.index == i ? active : muted;
  }

  @override
  Widget build(BuildContext context) {
    final active = AppColors.primary;
    final muted = AppColors.subTextColor.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Material(
        color: AppColors.pageBackground,
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return TabBar(
              controller: _tabController,
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              onTap: widget.onChanged,
              labelColor: active,
              unselectedLabelColor: muted,
              labelPadding: const EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.zero,
              indicatorColor: active,
              indicatorWeight: 1.2,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.borderSoft,
              overlayColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: [
                Tab(
                  height: 44,
                  child: Icon(Icons.grid_on_outlined, size: 26, color: _iconColor(0, active, muted)),
                ),
                Tab(
                  height: 44,
                  child: Icon(Icons.spa_rounded, size: 26, color: _iconColor(1, active, muted)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

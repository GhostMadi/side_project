import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Элемент пилюли: иконка + подпись + действие.
class AppPillNavItem {
  const AppPillNavItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Навигация в виде «пилюли», как [AppBottomBar] в приложении: те же цвета и обводка.
///
/// - **Один** [items] — строка: иконка слева, текст справа (компактная капсула).
/// - **Несколько** — колонка на пункт: иконка сверху, подпись снизу; опциональный слайд подсветки.
class AppPillNavigationBar extends StatefulWidget {
  const AppPillNavigationBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onSelectionChanged,
    this.height,
  });

  final List<AppPillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelectionChanged;

  /// Высота контейнера; по умолчанию меньше для одного пункта, ~85 для нескольких.
  final double? height;

  @override
  State<AppPillNavigationBar> createState() => _AppPillNavigationBarState();
}

class _AppPillNavigationBarState extends State<AppPillNavigationBar> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.selectedIndex.clamp(0, _maxIndex);
  }

  @override
  void didUpdateWidget(covariant AppPillNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _index = widget.selectedIndex.clamp(0, _maxIndex);
    }
  }

  int get _maxIndex => widget.items.isEmpty ? 0 : widget.items.length - 1;

  BoxDecoration get _decoration => BoxDecoration(
    color: AppColors.bottomBarColor.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 10)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    if (items.length == 1) {
      return _buildSingle(items.first);
    }
    return _buildMulti(items);
  }

  Widget _buildSingle(AppPillNavItem item) {
    final h = widget.height ?? 80.0;
    // [Scaffold.bottomNavigationBar] даёт по вертикали размах до ∞ — без фикс. высоты [Center]
    // растягивается на весь экран. Ограничиваем слот по высоте только пилюлей.
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Center(
        child: IntrinsicWidth(
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: h,
              constraints: const BoxConstraints(minWidth: 132),
              decoration: _decoration,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: AppColors.bottomBarActiveIcon,
                          shadows: [
                            Shadow(
                              color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: AppColors.bottomBarActiveIcon,
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMulti(List<AppPillNavItem> items) {
    final h = widget.height ?? 85.0;
    return Container(
      height: h,
      decoration: _decoration,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentW = constraints.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                left: _index * segmentW,
                width: segmentW,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: segmentW * 0.85,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.bottomBarSegment,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final selected = i == _index;
                  return Expanded(
                    child: _PillNavMultiCell(
                      icon: item.icon,
                      label: item.label,
                      selected: selected,
                      onTap: () {
                        item.onTap?.call();
                        setState(() => _index = i);
                        widget.onSelectionChanged?.call(i);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PillNavMultiCell extends StatelessWidget {
  const _PillNavMultiCell({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.bottomBarActiveIcon.withValues(alpha: 0.12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: selected ? 28 : 24,
              color: selected ? AppColors.bottomBarActiveIcon : AppColors.bottomBarInactiveIcon,
              shadows: selected
                  ? [Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.5), blurRadius: 8)]
                  : null,
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.bottomBarActiveIcon,
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.4), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

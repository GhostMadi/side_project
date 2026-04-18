import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Оболочка «пилюли» как у [AppPillNavigationBar] — для компактных кнопок в [AppBar] и т.п.
BoxDecoration appPillBarDecoration() {
  return BoxDecoration(
    color: AppColors.bottomBarColor.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 10)),
    ],
  );
}

/// Иконка в капсуле того же стиля, что [AppPillNavigationBar] — удобно для [AppBar.actions].
class AppPillBarIconAction extends StatelessWidget {
  const AppPillBarIconAction({super.key, required this.icon, this.onPressed, this.tooltip, this.size = 40});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: AppColors.bottomBarActiveIcon,
              shadows: [Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.45), blurRadius: 8)],
            ),
          ),
        ),
      ),
    );

    final capped = Container(decoration: appPillBarDecoration(), child: inner);

    if (tooltip != null && tooltip!.trim().isNotEmpty) {
      return Tooltip(message: tooltip!.trim(), child: capped);
    }
    return capped;
  }
}

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
    final h = widget.height ?? 70.0;
    // Без width: infinity — в [Row] горизонтальный max неограничен, бесконечная ширина ломает layout.
    // Во всю ширину слота центрируйте снаружи ([Center], [Align], [Stack] с bounded width).
    return SizedBox(
      height: h,
      child: IntrinsicWidth(
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: h,
            constraints: const BoxConstraints(minWidth: 132),
            decoration: appPillBarDecoration(),
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
                          Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.45), blurRadius: 8),
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
    );
  }

  Widget _buildMulti(List<AppPillNavItem> items) {
    final h = widget.height ?? 85.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // В [Row] без [Expanded]/[Flexible] родитель даёт maxWidth = ∞ — [Row]+[Expanded] внутри ломаются.
        final maxW = constraints.maxWidth;
        final effectiveW = maxW.isFinite && maxW > 0 ? maxW : MediaQuery.sizeOf(context).width;
        return SizedBox(
          width: effectiveW,
          height: h,
          child: DecoratedBox(
            decoration: appPillBarDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: List.generate(items.length, (i) {
                final item = items[i];
                return Expanded(
                  flex: 1,
                  child: _PillNavMultiCell(
                    icon: item.icon,
                    label: item.label,
                    onTap: () {
                      item.onTap?.call();
                      setState(() => _index = i);
                      widget.onSelectionChanged?.call(i);
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _PillNavMultiCell extends StatelessWidget {
  const _PillNavMultiCell({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: AppColors.bottomBarActiveIcon,
              shadows: [Shadow(color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.45), blurRadius: 6)],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.bottomBarActiveIcon,
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

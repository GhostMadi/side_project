import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

/// Общая нижняя шторка: блюр, «желейное» появление, тап по фону закрывает.
///
/// Возвращает результат [Navigator.pop], если его передали (например выбор в списке).
abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    bool upperCaseTitle = true,
    bool showCloseButton = false,

    /// Фиксированная высота области контента. Если `null` — высота по содержимому
    /// (с ограничением по экрану); для списков задайте [ListView.shrinkWrap] = true.
    double? contentHeight,

    /// Вертикальный зазор между [content] и нижним краем карточки (до [actions]).
    /// Для экранов с основной кнопкой внутри [content] можно поставить `0`, чтобы прижать её вниз.
    double contentBottomSpacing = 32,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(modalContext).bottom),
          child: LayoutBuilder(
            builder: (layoutContext, constraints) {
              final screenW = MediaQuery.sizeOf(layoutContext).width;
              final sheetWidth = min(screenW - 32, 500.0);

              final maxH = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.sizeOf(layoutContext).height - MediaQuery.viewInsetsOf(layoutContext).bottom;

              /// Резерв под ручку, заголовок и отступы карточки (без области [content]).
              const chromeHeight = 200.0;

              Widget body = content;
              if (contentHeight != null) {
                final cap = max(0.0, maxH - chromeHeight);
                body = SizedBox(height: min(contentHeight, cap), child: content);
              } else {
                /// Высота по содержимому: растём до [chromeHeight] + контент, не выше экрана.
                final maxContent = max(0.0, maxH - chromeHeight);
                body = ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxContent),
                  child: content,
                );
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: barrierDismissible ? () => Navigator.pop(modalContext) : null,
                    ),
                  ),
                  _JellySheetWrapper(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: GestureDetector(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: RepaintBoundary(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  width: sheetWidth,
                                  decoration: BoxDecoration(
                                    color: AppColors.bottomBarColor.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.bottomBarInactiveIcon.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (title != null) ...[
                                        _BottomSheetHeader(
                                          title: title,
                                          upperCaseTitle: upperCaseTitle,
                                          showCloseButton: showCloseButton,
                                          onClose: () => Navigator.pop(modalContext),
                                        ),
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: AppColors.border.withValues(alpha: 0.65),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: DefaultTextStyle(
                                          style: AppTextStyle.base(
                                            15,
                                            color: AppColors.textColor,
                                            height: 1.5,
                                          ),
                                          child: body,
                                        ),
                                      ),
                                      SizedBox(height: contentBottomSpacing),
                                      if (actions != null && actions.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                          child: Row(
                                            children: [
                                              for (var i = 0; i < actions.length; i++) ...[
                                                Expanded(child: actions[i]),
                                                if (i < actions.length - 1) const SizedBox(width: 12),
                                              ],
                                            ],
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
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Заголовок слева (нейтральный текст), тонкий акцент бренда, справа — компактное закрытие.
class _BottomSheetHeader extends StatelessWidget {
  const _BottomSheetHeader({
    required this.title,
    required this.upperCaseTitle,
    required this.showCloseButton,
    required this.onClose,
  });

  final String title;
  final bool upperCaseTitle;
  final bool showCloseButton;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final label = upperCaseTitle ? title.toUpperCase() : title;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.base(
                  17,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: upperCaseTitle ? 0.35 : 0,
                ),
              ),
            ),
            if (showCloseButton)
              IconButton(
                onPressed: onClose,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                style: IconButton.styleFrom(foregroundColor: AppColors.subTextColor),
                icon: const Icon(Icons.close_rounded, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _JellySheetWrapper extends StatefulWidget {
  const _JellySheetWrapper({required this.child});

  final Widget child;

  @override
  State<_JellySheetWrapper> createState() => _JellySheetWrapperState();
}

class _JellySheetWrapperState extends State<_JellySheetWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jellyAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _jellyAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _jellyAnim,
      builder: (context, child) {
        final double scale = 0.9 + (_jellyAnim.value * 0.1);
        final double vScale = 1.0 + (1.0 - scale) * 0.8;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(scale, vScale, 1.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

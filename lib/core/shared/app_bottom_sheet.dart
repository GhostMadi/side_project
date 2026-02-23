import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

class AppBottomSheet {
  static Future<void> show({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetWidth = min(screenWidth - 32, 500.0);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Stack(
        children: [
          // Слой для закрытия тапом по фону
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.pop(context)),
          ),

          // Желейная обертка с твоей логикой Transform
          _JellySheetWrapper(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: GestureDetector(
                  onTap: () {}, // Защита от закрытия при тапе на само окно
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
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
                            // Handle
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.bottomBarInactiveIcon.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (title != null) ...[
                              // Заголовок
                              Text(
                                title.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: AppTextStyle.base(
                                  20,
                                  color: AppColors.bottomBarActiveIcon,

                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Контент
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: AppColors.bottomBarActiveIcon.withValues(alpha: 0.7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                                child: content,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Кнопки
                            if (actions != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Row(
                                  children: actions
                                      .expand(
                                        (a) => [
                                          Expanded(child: a),
                                          if (a != actions.last) const SizedBox(width: 12),
                                        ],
                                      )
                                      .toList(),
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
        ],
      ),
    );
  }
}

class _JellySheetWrapper extends StatefulWidget {
  final Widget child;
  const _JellySheetWrapper({required this.child});

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

    // Та же кривая, что и в BottomBar для единства стиля
    _jellyAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
        // Твоя проверенная математика желе
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

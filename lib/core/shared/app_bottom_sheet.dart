import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String emoji,
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
          // 1. Прозрачный слой для закрытия при тапе МИМО контейнера
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: const SizedBox.expand(),
            ),
          ),

          // 2. Обертка с эффектом Желе и самим контентом
          _JellySheetWrapper(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: GestureDetector(
                  // Пустой onTap, чтобы тапы ВНУТРИ контейнера не закрывали его
                  onTap: () {},
                  child: Container(
                    width: sheetWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                          child: Text(emoji, style: const TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: content),
                        const SizedBox(height: 32),
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
        // Та же логика Transform, что и в твоем BottomBar
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

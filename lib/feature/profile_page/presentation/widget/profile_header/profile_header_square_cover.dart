import 'package:flutter/material.dart';
import 'package:side_project/core/shared/jelly_press_controller.dart';
import 'package:side_project/core/shared/app_progressive_network_image.dart';

/// Квадратная обложка с jelly-squash по тапу.
class ProfileHeaderSquareCover extends StatefulWidget {
  const ProfileHeaderSquareCover({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<ProfileHeaderSquareCover> createState() => _ProfileHeaderSquareCoverState();
}

class _ProfileHeaderSquareCoverState extends State<ProfileHeaderSquareCover>
    with SingleTickerProviderStateMixin {
  late final JellyPressController _jelly;
  /// Смена анимации после [trigger] — один тик без [setState] на весь хедер.
  late final ValueNotifier<int> _animationGeneration;

  @override
  void initState() {
    super.initState();
    _animationGeneration = ValueNotifier(0);
    _jelly = JellyPressController(
      vsync: this,
      onAnimationSwap: () => _animationGeneration.value++,
    );
  }

  @override
  void dispose() {
    _jelly.dispose();
    _animationGeneration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _jelly.trigger,
        child: ValueListenableBuilder<int>(
          valueListenable: _animationGeneration,
          builder: (context, _, __) {
            return AnimatedBuilder(
              animation: _jelly.scaleAnimation,
              builder: (context, child) {
                final s = _jelly.scaleAnimation.value;
                final vScale = 1.0 + (1.0 - s) * 0.5;
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.diagonal3Values(s, vScale, 1.0)..setEntry(3, 2, 0.001),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: AppProgressiveNetworkImage(
                    imageUrl: widget.imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

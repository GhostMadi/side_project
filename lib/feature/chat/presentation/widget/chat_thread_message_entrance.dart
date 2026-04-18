import 'package:flutter/material.dart';

/// Одноразовое появление сообщения снизу: opacity + лёгкий подъём (~180 ms).
class ChatThreadMessageEntrance extends StatefulWidget {
  const ChatThreadMessageEntrance({
    super.key,
    required this.animate,
    required this.child,
  });

  /// Обычно только для последнего нового сообщения в списке.
  final bool animate;
  final Widget child;

  @override
  State<ChatThreadMessageEntrance> createState() => _ChatThreadMessageEntranceState();
}

class _ChatThreadMessageEntranceState extends State<ChatThreadMessageEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const double _dy = 10;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    if (widget.animate) {
      _ctrl.forward(from: 0);
    } else {
      _ctrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant ChatThreadMessageEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.animate && widget.animate) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
        final o = widget.animate ? curved.value : 1.0;
        final y = widget.animate ? (1 - curved.value) * _dy : 0.0;
        return Opacity(
          opacity: o.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, y),
            child: widget.child,
          ),
        );
      },
    );
  }
}

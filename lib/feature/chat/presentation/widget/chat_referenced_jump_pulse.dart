import 'dart:async';

import 'package:flutter/material.dart';

/// После перехода к сообщению по цитате — 2–3 коротких «вспышки», чтобы сообщение было заметно.
class ChatReferencedJumpPulse extends StatefulWidget {
  const ChatReferencedJumpPulse({
    super.key,
    required this.child,
    required this.shouldPulse,
    required this.pulseGeneration,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final Widget child;

  /// Эта строка — цель перехода (совпадает нормализованный ключ пузыря).
  final bool shouldPulse;

  /// Увеличивается при каждом успешном переходе (в т.ч. повторный тап на ту же цитату).
  final int pulseGeneration;

  final BorderRadius borderRadius;

  @override
  State<ChatReferencedJumpPulse> createState() => _ChatReferencedJumpPulseState();
}

class _ChatReferencedJumpPulseState extends State<ChatReferencedJumpPulse> {
  int _lastHandledGeneration = 0;
  bool _lit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPulseTrigger());
  }

  @override
  void didUpdateWidget(covariant ChatReferencedJumpPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulseTrigger();
  }

  void _syncPulseTrigger() {
    if (!mounted) return;
    if (!widget.shouldPulse || widget.pulseGeneration <= 0) return;
    if (widget.pulseGeneration == _lastHandledGeneration) return;
    _lastHandledGeneration = widget.pulseGeneration;
    unawaited(_runPulse());
  }

  Future<void> _runPulse() async {
    const flashes = 3;
    for (var i = 0; i < flashes; i++) {
      if (!mounted) return;
      setState(() => _lit = true);
      await Future<void>.delayed(const Duration(milliseconds: 170));
      if (!mounted) return;
      setState(() => _lit = false);
      await Future<void>.delayed(const Duration(milliseconds: 110));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glow = scheme.primary.withValues(alpha: _lit ? 0.2 : 0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: glow,
        boxShadow: _lit
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.42),
                  blurRadius: 14,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );
  }
}

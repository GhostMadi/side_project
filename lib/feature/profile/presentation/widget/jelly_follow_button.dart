import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JellyFollowButton extends StatefulWidget {
  final bool isFollowed;
  final VoidCallback onPressed;
  const JellyFollowButton({super.key, required this.isFollowed, required this.onPressed});

  @override
  State<JellyFollowButton> createState() => _JellyFollowButtonState();
}

class _JellyFollowButtonState extends State<JellyFollowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
  }

  void _trigger() {
    HapticFeedback.mediumImpact();
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: _trigger,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: widget.isFollowed ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(15),
            border: widget.isFollowed ? Border.all(color: Colors.black12) : null,
          ),
          child: Center(
            child: Text(
              widget.isFollowed ? "Following" : "Follow",
              style: TextStyle(color: widget.isFollowed ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_project/feature/profile/models/post_model.dart';

class JellyStackItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;

  const JellyStackItem({super.key, required this.data, required this.isSelected, required this.onTap});

  @override
  State<JellyStackItem> createState() => _JellyStackItemState();
}

class _JellyStackItemState extends State<JellyStackItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jelly;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _jelly = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
  }

  void _trigger() {
    HapticFeedback.heavyImpact();
    _jelly = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final List<PostModel> posts = widget.data['posts'];
    final String img1 = posts.isNotEmpty ? posts[0].media.first : '';
    final String img2 = posts.length > 1 ? posts[1].media.first : img1;
    final String img3 = posts.length > 2 ? posts[2].media.first : img2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double scale = _jelly.value;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scale, 1.0 + (1.0 - scale) * 0.6, 1.0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _trigger,
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildCard(
                angle: widget.isSelected ? -0.3 : -0.15,
                offset: widget.isSelected ? const Offset(-25, -15) : const Offset(-8, -6),
                imageUrl: img3,
              ),
              _buildCard(
                angle: widget.isSelected ? 0.25 : 0.1,
                offset: widget.isSelected ? const Offset(25, -8) : const Offset(8, 2),
                imageUrl: img2,
              ),
              _buildCard(angle: widget.isSelected ? -0.05 : 0, offset: Offset.zero, imageUrl: img1),
              Positioned(
                bottom: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.data['title'].toString().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required double angle, required Offset offset, required String imageUrl}) {
    return AnimatedSlide(
      offset: offset.scale(0.01, 0.01),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: AnimatedRotation(
        turns: angle / (2 * 3.14),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        child: Container(
          width: 100,
          height: 125,
          // padding: const EdgeInsets.fromLTRB(6, 6, 6, 18),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';

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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = (widget.data['posts'] as List<dynamic>?) ?? const [];
    final title = widget.data['title'] as String? ?? '';
    final subtitle = widget.data['subtitle'] as String? ?? '';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? const Color(0xFF8BC34A) : const Color(0xFFE0E0E0),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStackPreview(posts),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.base(
                        16,
                        color: const Color(0xFF1A1D1E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyle.base(
                        13,
                        color: const Color(0xFF6A6A6A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                widget.isSelected ? Icons.check_circle : Icons.chevron_right,
                color: widget.isSelected ? const Color(0xFF8BC34A) : const Color(0xFFBDBDBD),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackPreview(List<dynamic> posts) {
    const size = 56.0;
    if (posts.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.collections, color: Color(0xFFBDBDBD)),
      );
    }
    return SizedBox(
      width: size + 8,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < posts.length.clamp(0, 3); i++)
            Positioned(
              left: i * 6.0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  image: DecorationImage(
                    image: NetworkImage(
                      posts[i] is String ? posts[i] as String : 'https://picsum.photos/seed/${i + 1}/200',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

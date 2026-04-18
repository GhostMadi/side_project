import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/jelly_press_controller.dart';

/// Карточка коллекции / кластера: превью слева, заголовок и опционально подзаголовок; счётчик — компактный чип справа от заголовка.
///
/// Состояния: с обложкой / без, подзаголовок, счётчик, [isSelected].
class ProfileCollectionCard extends StatefulWidget {
  const ProfileCollectionCard({
    super.key,
    this.index = 0,
    required this.imageUrl,
    this.memoryImageBytes,
    required this.title,
    this.collectionSubtitle,
    required this.countLabel,
    required this.isSelected,
    required this.onTap,
  });

  /// Лёгкий вертикальный сдвиг в ряду (ритм).
  final int index;
  final String imageUrl;
  final Uint8List? memoryImageBytes;
  final String title;
  final String? collectionSubtitle;
  final String countLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<ProfileCollectionCard> createState() => _ProfileCollectionCardState();
}

class _ProfileCollectionCardState extends State<ProfileCollectionCard> with SingleTickerProviderStateMixin {
  late final JellyPressController _jelly;

  static const double _kRowHeight = 64;
  static const double _kCardWidth = 212;
  static const double _kThumb = 52;

  @override
  void initState() {
    super.initState();
    _jelly = JellyPressController(vsync: this, onAnimationSwap: () => setState(() {}));
  }

  @override
  void dispose() {
    _jelly.dispose();
    super.dispose();
  }

  void _onTap() {
    _jelly.trigger();
    widget.onTap();
  }

  static const BorderRadius _thumbInnerRadius = BorderRadius.all(Radius.circular(11));

  static Widget _thumbGradientOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 18,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.shadowDark.withValues(alpha: 0.05)],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailChild() {
    final mem = widget.memoryImageBytes;
    if (mem != null && mem.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(mem, fit: BoxFit.cover, gaplessPlayback: true),
          _thumbGradientOverlay(),
        ],
      );
    }

    final url = widget.imageUrl.trim();
    if (url.isEmpty) {
      return const SizedBox.expand();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => ColoredBox(color: AppColors.surfaceSoft),
          errorWidget: (_, __, ___) => ColoredBox(
            color: AppColors.surfaceSoft,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 20,
              color: AppColors.subTextColor.withValues(alpha: 0.35),
            ),
          ),
        ),
        _thumbGradientOverlay(),
      ],
    );
  }

  Widget _thumbFrame({required bool sel, required bool hasThumb}) {
    if (!hasThumb) {
      return const SizedBox.shrink();
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(sel ? 2 : 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: sel ? AppColors.primary.withValues(alpha: 0.85) : AppColors.borderSoft,
          width: sel ? 2 : 1,
        ),
        boxShadow: sel
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: _thumbInnerRadius,
        child: SizedBox(width: _kThumb, height: _kThumb, child: _thumbnailChild()),
      ),
    );
  }

  Widget _countChip(bool sel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withValues(alpha: sel ? 0.16 : 0.1),
      ),
      child: Text(
        widget.countLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.base(
          10,
          color: AppColors.primary.withValues(alpha: sel ? 0.95 : 0.75),
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    final mid = widget.collectionSubtitle?.trim();
    final hasMid = mid != null && mid.isNotEmpty;
    final hasMem = widget.memoryImageBytes != null && widget.memoryImageBytes!.isNotEmpty;
    final hasUrl = widget.imageUrl.trim().isNotEmpty;
    final hasThumb = hasMem || hasUrl;
    final hasCount = widget.countLabel.trim().isNotEmpty;
    final rhythmY = widget.index.isOdd ? 2.0 : 0.0;

    final bg = sel ? AppColors.successSoft.withValues(alpha: 0.5) : AppColors.white;
    final borderColor = sel
        ? AppColors.primary.withValues(alpha: 0.38)
        : AppColors.border.withValues(alpha: 0.55);

    final inner = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: _kCardWidth,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: sel ? 1.15 : 0.85),
        color: bg,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: sel ? 0.07 : 0.04),
            blurRadius: sel ? 14 : 10,
            offset: const Offset(0, 4),
            spreadRadius: sel ? 0 : -1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: SizedBox(
          height: _kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasThumb) ...[
                AnimatedScale(
                  scale: sel ? 1.02 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _thumbFrame(sel: sel, hasThumb: hasThumb),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.base(
                              14,
                              color: sel ? AppColors.primary : AppColors.textColor,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (hasCount) ...[const SizedBox(width: 6), _countChip(sel)],
                      ],
                    ),
                    if (hasMid) ...[
                      const SizedBox(height: 4),
                      Text(
                        mid,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(
                          11,
                          color: AppColors.subTextColor.withValues(alpha: 0.88),
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget card = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _jelly.scaleAnimation,
        builder: (context, child) {
          final s = _jelly.scaleAnimation.value;
          final vScale = 1.0 + (1.0 - s) * 0.12;
          return Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.diagonal3Values(s, vScale, 1.0)..setEntry(3, 2, 0.001),
            child: child,
          );
        },
        child: inner,
      ),
    );

    if (rhythmY == 0) return card;
    return Transform.translate(offset: Offset(0, rhythmY), child: card);
  }
}

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/jelly_press_controller.dart';

/// Карточка коллекции: превью слева, справа заголовок → подпись → количество; jelly при тапе.
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

  /// Для лёгкого вертикального ритма в ряду.
  final int index;
  final String imageUrl;

  /// Локальные байты (обложка из памяти); важнее [imageUrl].
  final Uint8List? memoryImageBytes;
  final String title;

  /// Между [title] и [countLabel].
  final String? collectionSubtitle;
  final String countLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<ProfileCollectionCard> createState() => _ProfileCollectionCardState();
}

class _ProfileCollectionCardState extends State<ProfileCollectionCard>
    with SingleTickerProviderStateMixin {
  late final JellyPressController _jelly;

  @override
  void initState() {
    super.initState();
    _jelly = JellyPressController(
      vsync: this,
      onAnimationSwap: () => setState(() {}),
    );
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

  static const BorderRadius _thumbRadius = BorderRadius.only(
    topLeft: Radius.circular(14),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(14),
    bottomLeft: Radius.circular(10),
  );

  static Widget _thumbGradientOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.shadowDark.withValues(alpha: 0.08),
            ],
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
      return ColoredBox(
        color: AppColors.surfaceSoft,
        child: Icon(
          Icons.photo_library_outlined,
          size: 28,
          color: AppColors.subTextColor.withValues(alpha: 0.35),
        ),
      );
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
              Icons.broken_image_outlined,
              size: 22,
              color: AppColors.subTextColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        _thumbGradientOverlay(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    final mid = widget.collectionSubtitle?.trim();
    final hasMid = mid != null && mid.isNotEmpty;
    final borderIdle = AppColors.border.withValues(alpha: 0.5);
    final borderActive = AppColors.primary.withValues(alpha: 0.5);
    final rhythmY = widget.index.isOdd ? 2.0 : 0.0;

    Widget card = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _jelly.scaleAnimation,
        builder: (context, child) {
          final s = _jelly.scaleAnimation.value;
          final vScale = 1.0 + (1.0 - s) * 0.14;
          return Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.diagonal3Values(s, vScale, 1.0)
              ..setEntry(3, 2, 0.001),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 212,
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel ? borderActive : borderIdle,
              width: sel ? 1.25 : 0.5,
            ),
            color: sel
                ? AppColors.surfaceSoftGreen.withValues(alpha: 0.55)
                : AppColors.surfaceMuted.withValues(alpha: 0.65),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? AppColors.shadowPrimary.withValues(alpha: 0.12)
                    : AppColors.shadowDark.withValues(alpha: 0.04),
                blurRadius: sel ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: sel ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: ClipRRect(
                  borderRadius: _thumbRadius,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: _thumbnailChild(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(
                        14,
                        color: sel
                            ? Color.lerp(
                                AppColors.primary,
                                AppColors.textColor,
                                0.18,
                              )!
                            : AppColors.textColor,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (hasMid) ...[
                      const SizedBox(height: 4),
                      Text(
                        mid,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.base(
                          12,
                          color: AppColors.subTextColor.withValues(alpha: 0.92),
                          height: 1.25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      widget.countLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.base(
                        11,
                        color: AppColors.primary.withValues(
                          alpha: sel ? 0.95 : 0.72,
                        ),
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        // AnimatedContainer must not use double.infinity — lerp in implicit animation asserts.
                        final w = sel ? (maxW.isFinite ? maxW : 120.0) : 28.0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          height: 2.5,
                          width: w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: sel
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.35),
                                    ],
                                  )
                                : null,
                            color: sel
                                ? null
                                : AppColors.border.withValues(alpha: 0.35),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (rhythmY == 0) return card;
    return Transform.translate(offset: Offset(0, rhythmY), child: card);
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/media/media_service.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/app_shimmer.dart';

/// Одна точка входа для превью в сетках: по URL решаем image / video poster (+ play).
///
/// Для полноэкранного видеоплеера в посте используйте отдельный виджет с [VideoPlayer].
class MediaWidget extends StatelessWidget {
  const MediaWidget.previewTile({
    super.key,
    required this.url,
    /// Если с бэка `type: video`, но расширение в URL нестандартное.
    this.treatAsVideoFromModel = false,
    this.fit = BoxFit.cover,
    this.fadeDuration = Duration.zero,
    this.placeholder,
    this.errorWidget,
    this.playIconSize = 44,
    this.playBadgeSize = 22,
    this.showPlayBadge = true,
  });

  /// Публичный URL медиа (`…jpg` или `…mp4` и т.д.).
  final String url;

  /// Совместно с [MediaService.isVideo] определяет режим «постер + play».
  final bool treatAsVideoFromModel;

  final BoxFit fit;
  final Duration fadeDuration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double playIconSize;
  final double playBadgeSize;
  final bool showPlayBadge;

  bool get _useVideoPoster =>
      treatAsVideoFromModel || MediaService.isVideo(url.trim());

  @override
  Widget build(BuildContext context) {
    final raw = url.trim();
    if (raw.isEmpty) {
      return placeholder ?? const PostMediaFramePlaceholder(shimmer: true);
    }

    if (_useVideoPoster) {
      final poster = MediaService.videoPosterUrl(raw);
      if (poster == null || poster.isEmpty) {
        return ColoredBox(
          color: AppColors.inputBackground,
          child: Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              size: playIconSize,
              color: AppColors.subTextColor.withValues(alpha: 0.5),
            ),
          ),
        );
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: poster,
            fit: fit,
            fadeInDuration: fadeDuration,
            fadeOutDuration: fadeDuration,
            useOldImageOnUrlChange: true,
            imageBuilder: (context, provider) => Image(
              image: provider,
              fit: fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
            ),
            placeholder: (_, __) =>
                placeholder ?? ColoredBox(color: AppColors.surfaceSoft),
            errorWidget: (_, __, ___) =>
                errorWidget ??
                ColoredBox(
                  color: AppColors.inputBackground,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.subTextColor.withValues(alpha: 0.45),
                      size: 36,
                    ),
                  ),
                ),
          ),
          if (showPlayBadge)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: playBadgeSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return CachedNetworkImage(
      imageUrl: raw,
      fit: fit,
      fadeInDuration: fadeDuration,
      fadeOutDuration: fadeDuration,
      useOldImageOnUrlChange: true,
      imageBuilder: (context, provider) => Image(
        image: provider,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
      ),
      placeholder: (_, __) => placeholder ?? ColoredBox(color: AppColors.surfaceSoft),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          ColoredBox(
            color: AppColors.inputBackground,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.subTextColor.withValues(alpha: 0.45),
                size: 36,
              ),
            ),
          ),
    );
  }
}

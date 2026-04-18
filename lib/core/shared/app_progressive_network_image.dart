import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Прогрессивная загрузка картинки "как в Instagram":
/// сначала низкое качество/малый размер (thumb), затем поверх — оригинал (hi-res) с fade-in.
///
/// Для Supabase public storage URL (`/storage/v1/object/public/...`) thumb строится автоматически
/// через `/storage/v1/render/image/public/...?...`.
class AppProgressiveNetworkImage extends StatelessWidget {
  const AppProgressiveNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.thumbWidth,
    this.thumbQuality = 20,
    this.fadeInDuration = const Duration(milliseconds: 220),
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  /// Если задано — используем эту ширину для thumb URL.
  /// Если нет — пытаемся вывести из [width] (в px), иначе берём 96.
  final int? thumbWidth;

  /// JPEG quality для thumb (0..100).
  final int thumbQuality;

  final Duration fadeInDuration;

  static String? tryBuildSupabaseThumbUrl(
    String url, {
    required int width,
    required int quality,
  }) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return null;
    }

    const needle = '/storage/v1/object/public/';
    if (!uri.path.contains(needle)) return null;

    final newPath = uri.path.replaceFirst(needle, '/storage/v1/render/image/public/');
    final qp = <String, String>{...uri.queryParameters};
    qp['width'] = width.toString();
    qp['quality'] = quality.toString();
    return uri.replace(path: newPath, queryParameters: qp).toString();
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.inputBackground;
    final effectiveThumbWidth = thumbWidth ?? ((width != null) ? (width!.round().clamp(48, 256)) : 96);
    final thumbUrl = tryBuildSupabaseThumbUrl(
      imageUrl,
      width: effectiveThumbWidth,
      quality: thumbQuality.clamp(1, 100),
    );

    Widget image = Stack(
      fit: StackFit.passthrough,
      children: [
        // Base: thumb (или просто фон, если thumb URL не собрать).
        Positioned.fill(
          child: thumbUrl == null
              ? DecoratedBox(decoration: BoxDecoration(color: bg))
              : CachedNetworkImage(
                  imageUrl: thumbUrl,
                  fadeInDuration: fadeInDuration,
                  fadeOutDuration: const Duration(milliseconds: 80),
                  useOldImageOnUrlChange: true,
                  imageBuilder: (context, provider) => Image(
                    image: provider,
                    width: width,
                    height: height,
                    fit: fit,
                    filterQuality: FilterQuality.low,
                  ),
                  placeholder: (_, __) => DecoratedBox(decoration: BoxDecoration(color: bg)),
                  errorWidget: (_, __, ___) => DecoratedBox(decoration: BoxDecoration(color: bg)),
                ),
        ),
        // Top: hi-res. Когда загрузится — плавно проявится.
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fadeInDuration: fadeInDuration,
            fadeOutDuration: const Duration(milliseconds: 80),
            useOldImageOnUrlChange: true,
            imageBuilder: (context, provider) => Image(
              image: provider,
              width: width,
              height: height,
              fit: fit,
              filterQuality: FilterQuality.high,
            ),
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return SizedBox(width: width, height: height, child: image);
  }
}


import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// JPEG для превью в ленте; несколько попыток, если первый кадр чёрный/пустой.
Future<Uint8List?> captureVideoPosterJpeg(File file, {int preferredTimeMs = 500}) async {
  Future<Uint8List?> once(int ms) async {
    try {
      final b = await VideoThumbnail.thumbnailData(
        video: file.path,
        timeMs: ms.clamp(0, 1 << 30),
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1440,
        quality: 86,
      );
      if (b != null && b.isNotEmpty) {
        return b;
      }
    } catch (_) {}
    return null;
  }

  return await once(preferredTimeMs) ?? await once(0);
}

/// Выбор кадра обложки по таймлайну локального файла.
class PostCreateVideoCoverSheet extends StatefulWidget {
  const PostCreateVideoCoverSheet({super.key, required this.file, this.initialPoster});

  final File file;
  final Uint8List? initialPoster;

  @override
  State<PostCreateVideoCoverSheet> createState() => _PostCreateVideoCoverSheetState();
}

class _PostCreateVideoCoverSheetState extends State<PostCreateVideoCoverSheet> {
  int _durationMs = 1;
  double _t = 0;
  Uint8List? _preview;
  late bool _loadingThumb;
  bool _videoReady = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialPoster;
    _loadingThumb = widget.initialPoster == null;
    final c = VideoPlayerController.file(widget.file)..setVolume(0);
    c.initialize().then((_) async {
      final ms = c.value.duration.inMilliseconds;
      await c.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _durationMs = ms <= 0 ? 1 : ms;
        _videoReady = true;
      });
      unawaited(_refreshThumbAtSlider());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refreshThumbAtSlider() async {
    final ms = (_t * _durationMs).round().clamp(0, _durationMs);
    setState(() => _loadingThumb = true);
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.file.path,
        timeMs: ms,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1080,
        quality: 88,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = data ?? _preview;
        _loadingThumb = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingThumb = false);
      }
    }
  }

  void _onScrub(double v) {
    setState(() => _t = v.clamp(0.0, 1.0));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 140), _refreshThumbAtSlider);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: AppColors.postEditorPanel,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Обложка видео',
              textAlign: TextAlign.center,
              style: AppTextStyle.base(17, fontWeight: FontWeight.w700, color: AppColors.postEditorOnSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Передвиньте ползунок и выберите кадр для превью в ленте.',
              textAlign: TextAlign.center,
              style: AppTextStyle.base(13, color: AppColors.postEditorOnSurfaceMuted, height: 1.35),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: AppColors.postEditorBackground,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_preview != null && _preview!.isNotEmpty)
                        Image.memory(
                          _preview!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                        )
                      else if (!_videoReady)
                        const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      if (_loadingThumb && _preview != null && _preview!.isNotEmpty)
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.12),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_videoReady)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                ),
                child: Slider(
                  value: _t,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.inputBorder,
                  onChanged: _onScrub,
                ),
              )
            else
              const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Отмена',
                      style: AppTextStyle.base(15, fontWeight: FontWeight.w600, color: AppColors.textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (_preview == null || _preview!.isEmpty)
                        ? null
                        : () => Navigator.of(context).pop(_preview),
                    child: Text(
                      'Готово',
                      style: AppTextStyle.base(15, fontWeight: FontWeight.w700, color: AppColors.surface),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

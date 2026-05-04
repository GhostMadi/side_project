import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Прямоугольник кропа в системе [nativeFrameW]×[nativeFrameH] (как в [PostCreateSlot]).
class PostCreateVideoSpatialMeta {
  const PostCreateVideoSpatialMeta({
    required this.nativeFrameW,
    required this.nativeFrameH,
    required this.cropX,
    required this.cropY,
    required this.cropW,
    required this.cropH,
  });

  final int nativeFrameW;
  final int nativeFrameH;
  final int cropX;
  final int cropY;
  final int cropW;
  final int cropH;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostCreateVideoSpatialMeta &&
          nativeFrameW == other.nativeFrameW &&
          nativeFrameH == other.nativeFrameH &&
          cropX == other.cropX &&
          cropY == other.cropY &&
          cropW == other.cropW &&
          cropH == other.cropH;

  @override
  int get hashCode => Object.hash(nativeFrameW, nativeFrameH, cropX, cropY, cropW, cropH);
}

/// Заполнить прямоугольник [constraints] видео с сохранением пропорций источника (cover).
Widget _videoCoverBoxFit({required VideoPlayerController controller, required BoxConstraints constraints}) {
  final w = constraints.maxWidth;
  final h = constraints.maxHeight;
  if (w <= 0 || h <= 0 || !w.isFinite || !h.isFinite) {
    return const SizedBox.shrink();
  }
  final va = controller.value.aspectRatio;
  final videoAr = va > 0 ? va : (16 / 9);
  return ClipRect(
    child: FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(width: w, height: w / videoAr, child: VideoPlayer(controller)),
    ),
  );
}

/// Превью локального видео; при [spatialMeta] показываем ту же область, что выбрали в «Кадре»,
/// переводя прямоугольник в координаты [VideoPlayerController.value.size] через **доли кадра**
/// (не сырые пиксели JPEG — так слой декодера и метаданные слота согласуются лучше).
class PostCreateVideoPreview extends StatefulWidget {
  const PostCreateVideoPreview({
    super.key,
    required this.file,
    this.loopSegmentStart,
    this.loopSegmentEnd,
    this.frameAspectRatio,
    this.spatialMeta,
    this.externalController,
    this.autoPlayOnInit = false,

    /// Доли [0–1] по ширине превью: затемнить слева от start и справа от end (выбранный трим).
    this.trimVisibleFraction,
  });

  final File file;

  final Duration? loopSegmentStart;
  final Duration? loopSegmentEnd;

  /// Рамка по пресету [PostCreateSlot.aspect], если не используем spatial или как fallback.
  final double? frameAspectRatio;

  /// Сохранённый кроп; null — только рамка по [frameAspectRatio].
  final PostCreateVideoSpatialMeta? spatialMeta;

  /// Один контроллер с экрана редактирования — не создаём/не dispose внутри.
  final VideoPlayerController? externalController;

  /// Для встроенного контроллера: автозапуск после инициализации (по умолчанию выкл., как в ТЗ).
  final bool autoPlayOnInit;

  /// start/end — границы видимого сегмента по полной длине файла (для затемнения боков).
  final ({double start, double end})? trimVisibleFraction;

  @override
  State<PostCreateVideoPreview> createState() => _PostCreateVideoPreviewState();
}

class _PostCreateVideoPreviewState extends State<PostCreateVideoPreview> {
  VideoPlayerController? _c;
  bool _ownsController = true;
  Size? _lastVideoPixelSize;

  void _onTick() {
    final c = widget.externalController ?? _c;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    final end = widget.loopSegmentEnd;
    final start = widget.loopSegmentStart ?? Duration.zero;
    if (end == null) {
      return;
    }
    if (c.value.position >= end - const Duration(milliseconds: 40)) {
      c.seekTo(start);
    }
  }

  void _onControllerTickOrVideoSize() {
    _onTick();
    if (widget.spatialMeta == null) {
      return;
    }
    final c = widget.externalController ?? _c;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    final sz = c.value.size;
    if (sz.width > 0 && sz.height > 0 && (_lastVideoPixelSize == null || _lastVideoPixelSize != sz)) {
      _lastVideoPixelSize = sz;
      setState(() {});
    }
  }

  void _attachInternalController(VideoPlayerController c, {required bool bounded}) {
    c.setVolume(0);
    c.setLooping(!bounded);
    c.initialize().then((_) async {
      if (!mounted || _c != c) {
        return;
      }
      c.addListener(_onControllerTickOrVideoSize);
      final st = widget.loopSegmentStart ?? Duration.zero;
      await c.seekTo(st);
      if (!mounted || _c != c) {
        return;
      }
      setState(() {});
      if (widget.autoPlayOnInit) {
        await c.play();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final ext = widget.externalController;
    if (ext != null) {
      _ownsController = false;
      _c = ext;
      ext.addListener(_onControllerTickOrVideoSize);
      // Инициализацию делает владелец контроллера — здесь только подписка на тики.
      if (ext.value.isInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
        if (widget.autoPlayOnInit) {
          unawaited(ext.play());
        }
      }
      return;
    }
    final bounded = widget.loopSegmentEnd != null;
    final created = VideoPlayerController.file(widget.file);
    _c = created;
    _attachInternalController(created, bounded: bounded);
  }

  @override
  void didUpdateWidget(PostCreateVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ext = widget.externalController;
    final oldExt = oldWidget.externalController;
    if (ext != oldExt) {
      oldExt?.removeListener(_onControllerTickOrVideoSize);
      if (_ownsController) {
        _c?.removeListener(_onControllerTickOrVideoSize);
        _c?.dispose();
      }
      _c = ext;
      _ownsController = ext == null;
      if (ext != null) {
        ext.addListener(_onControllerTickOrVideoSize);
        if (ext.value.isInitialized) {
          setState(() {});
        }
      } else {
        final bounded = widget.loopSegmentEnd != null;
        final created = VideoPlayerController.file(widget.file);
        _c = created;
        _attachInternalController(created, bounded: bounded);
      }
      _lastVideoPixelSize = null;
      return;
    }
    if (widget.externalController == null && oldWidget.file.path != widget.file.path) {
      _c?.removeListener(_onControllerTickOrVideoSize);
      _c?.dispose();
      _c = null;
      _lastVideoPixelSize = null;
      final bounded = widget.loopSegmentEnd != null;
      final created = VideoPlayerController.file(widget.file);
      _c = created;
      _attachInternalController(created, bounded: bounded);
      return;
    }
    if (oldWidget.loopSegmentStart != widget.loopSegmentStart ||
        oldWidget.loopSegmentEnd != widget.loopSegmentEnd) {
      final c = widget.externalController ?? _c;
      if (c != null && c.value.isInitialized) {
        final st = widget.loopSegmentStart ?? Duration.zero;
        c.seekTo(st);
      }
    }
    if (oldWidget.spatialMeta != widget.spatialMeta) {
      _lastVideoPixelSize = null;
    }
  }

  @override
  void dispose() {
    final ext = widget.externalController;
    ext?.removeListener(_onControllerTickOrVideoSize);
    if (_ownsController) {
      _c?.removeListener(_onControllerTickOrVideoSize);
      _c?.dispose();
    }
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final c = widget.externalController ?? _c;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildVideoLayoutInCell(VideoPlayerController c, double cellW, double cellH) {
    final spatial = widget.spatialMeta;
    final frameAr = widget.frameAspectRatio;

    if (spatial != null &&
        spatial.cropW > 0 &&
        spatial.cropH > 0 &&
        spatial.nativeFrameW > 0 &&
        spatial.nativeFrameH > 0) {
      return SizedBox(
        width: cellW,
        height: cellH,
        child: Align(
          alignment: Alignment.center,
          child: _SpatialCropMappedView(
            controller: c,
            meta: spatial,
            cellWidth: cellW,
            cellHeight: cellH,
            frameFallbackAr: frameAr ?? (spatial.cropW / spatial.cropH),
          ),
        ),
      );
    }

    if (frameAr != null && frameAr > 0) {
      var boxW = cellW;
      var boxH = boxW / frameAr;
      if (boxH > cellH) {
        boxH = cellH;
        boxW = boxH * frameAr;
      }
      return SizedBox(
        width: boxW,
        height: boxH,
        child: _videoCoverBoxFit(
          controller: c,
          constraints: BoxConstraints.tightFor(width: boxW, height: boxH),
        ),
      );
    }

    final ar = c.value.aspectRatio;
    final va = ar > 0 ? ar : 16 / 9;
    var boxW = cellW;
    var boxH = boxW / va;
    if (boxH > cellH) {
      boxH = cellH;
      boxW = boxH * va;
    }
    return SizedBox(width: boxW, height: boxH, child: VideoPlayer(c));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.externalController ?? _c;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final mq = MediaQuery.sizeOf(context);
    final trim = widget.trimVisibleFraction;
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxW = constraints.maxWidth;
        var maxH = constraints.maxHeight;
        if (!maxW.isFinite || maxW <= 0) {
          maxW = mq.width;
        }
        if (!maxH.isFinite || maxH <= 0) {
          maxH = mq.height;
        }
        final videoCore = Align(alignment: Alignment.center, child: _buildVideoLayoutInCell(c, maxW, maxH));
        Widget stacked = videoCore;
        if (trim != null && trim.end > trim.start) {
          final s = trim.start.clamp(0.0, 1.0);
          final e = trim.end.clamp(s, 1.0);
          final dim = Colors.black.withValues(alpha: 0.52);
          stacked = Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              videoCore,
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: maxW * s,
                child: IgnorePointer(child: ColoredBox(color: dim)),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: maxW * (1.0 - e),
                child: IgnorePointer(child: ColoredBox(color: dim)),
              ),
            ],
          );
        }
        return SizedBox(
          width: maxW,
          height: maxH,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _togglePlayPause, child: stacked),
        );
      },
    );
  }
}

/// Область кропа в координатах слоя [VideoPlayer], через доли относительно метаданных слота.
class _SpatialCropMappedView extends StatelessWidget {
  const _SpatialCropMappedView({
    required this.controller,
    required this.meta,
    required this.cellWidth,
    required this.cellHeight,
    required this.frameFallbackAr,
  });

  final VideoPlayerController controller;
  final PostCreateVideoSpatialMeta meta;
  final double cellWidth;
  final double cellHeight;
  final double frameFallbackAr;

  /// Угол между соотношением кропа и получившимся после маппинга (чем меньше, тем лучше).
  static double _arPenalty(double mappedAr, double targetAr) {
    if (mappedAr <= 0 || targetAr <= 0) {
      return 99;
    }
    final a = math.log(mappedAr);
    final b = math.log(targetAr);
    return (a - b).abs();
  }

  static ({double vx, double vy, double vww, double vhh}) _mapCropToVideoLayer({
    required PostCreateVideoSpatialMeta meta,
    required double vw,
    required double vh,
    required bool transposeAxes,
  }) {
    final nw = meta.nativeFrameW.toDouble();
    final nh = meta.nativeFrameH.toDouble();
    final cx = meta.cropX.toDouble();
    final cy = meta.cropY.toDouble();
    final cw = meta.cropW.toDouble();
    final ch = meta.cropH.toDouble();

    late double vx;
    late double vy;
    late double vww;
    late double vhh;

    if (!transposeAxes) {
      vx = (cx / nw) * vw;
      vy = (cy / nh) * vh;
      vww = (cw / nw) * vw;
      vhh = (ch / nh) * vh;
    } else {
      // Частый случай: превью в редакторе — «портретное», декодер отдаёт кадр в другой ориентации.
      vx = (cy / nh) * vw;
      vy = (cx / nw) * vh;
      vww = (ch / nh) * vw;
      vhh = (cw / nw) * vh;
    }

    vx = vx.clamp(0.0, math.max(0.0, vw - 1));
    vy = vy.clamp(0.0, math.max(0.0, vh - 1));
    vww = vww.clamp(1.0, math.max(1.0, vw - vx));
    vhh = vhh.clamp(1.0, math.max(1.0, vh - vy));
    return (vx: vx, vy: vy, vww: vww, vhh: vhh);
  }

  @override
  Widget build(BuildContext context) {
    final v = controller.value;
    final vw = v.size.width;
    final vh = v.size.height;
    if (vw <= 0 || vh <= 0) {
      return _fallbackCover(context);
    }

    if (meta.nativeFrameW <= 0 || meta.nativeFrameH <= 0 || meta.cropW <= 0 || meta.cropH <= 0) {
      return _fallbackCover(context);
    }

    final targetAr = meta.cropW / meta.cropH;

    final m0 = _mapCropToVideoLayer(meta: meta, vw: vw, vh: vh, transposeAxes: false);
    final m1 = _mapCropToVideoLayer(meta: meta, vw: vw, vh: vh, transposeAxes: true);

    final p0 = _arPenalty(m0.vww / m0.vhh, targetAr);
    final p1 = _arPenalty(m1.vww / m1.vhh, targetAr);

    final use = p1 + 0.02 < p0 ? m1 : m0;
    final vx = use.vx;
    final vy = use.vy;
    final vww = use.vww;
    final vhh = use.vhh;

    final mappedAr = vww / vhh;
    if (targetAr > 0 && mappedAr > 0 && (mappedAr - targetAr).abs() / targetAr > 0.35) {
      return _fallbackCover(context);
    }

    if (vww * vhh < 0.015 * vw * vh) {
      return _fallbackCover(context);
    }

    // Тот же прямоугольник превью, что и без spatial (пресет [aspect] в ячейке), чтобы кадр «встал на место».
    final slotAr = frameFallbackAr > 0 ? frameFallbackAr : targetAr;
    var previewW = cellWidth;
    var previewH = previewW / slotAr;
    if (previewH > cellHeight) {
      previewH = cellHeight;
      previewW = previewH * slotAr;
    }

    // Без Transform над VideoPlayer (текстура пропадает): смещение через Positioned,
    // масштаб через FittedBox(cover) внутри масштабированного слоя vw*scale × vh*scale.
    final scale = math.max(previewW / vww, previewH / vhh);

    return SizedBox(
      width: previewW,
      height: previewH,
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -vx * scale,
              top: -vy * scale,
              width: vw * scale,
              height: vh * scale,
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                child: SizedBox(width: vw, height: vh, child: VideoPlayer(controller)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackCover(BuildContext context) {
    final ar = frameFallbackAr > 0 ? frameFallbackAr : (16 / 9);
    var boxW = cellWidth;
    var boxH = boxW / ar;
    if (boxH > cellHeight) {
      boxH = cellHeight;
      boxW = boxH * ar;
    }
    return SizedBox(
      width: boxW,
      height: boxH,
      child: _videoCoverBoxFit(
        controller: controller,
        constraints: BoxConstraints.tightFor(width: boxW, height: boxH),
      ),
    );
  }
}

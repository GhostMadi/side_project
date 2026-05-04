import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:side_project/feature/post_create_page/domain/post_create_video_constants.dart';

export 'package:side_project/core/shared/ig_edit/ig_edit_models.dart'
    show PostImageEditParams, PostStyleFilter, PostStyleFilterUi;

/// Выбранный файл из галереи (любое соотношение сторон).
///
/// [originalFile] — исходник с устройства; экран обрезки всегда открывается с ним.
/// [displayFile] — то, что видит пользователь (после обрезки и т.д.); цветокор считается с него.
///
/// Для видео: [videoTrimStartMs] — начало отрезка до [kPostCreateMaxVideoPublishMs]; [videoDurationMs]
/// заполняется после probe (для дорожки и FFmpeg).
///
/// Пространственная обрезка кадра: [videoCrop*] и [videoNativeFrame*] в пикселях исходного ролика.
///
/// Для видео: [videoTrimDurationMs] — явная длина фрагмента (мс); `null` = как раньше (максимум до 60 с от старта).
class PostCreateSlot {
  PostCreateSlot({
    required this.originalFile,
    File? displayFile,
    required this.isVideo,
    this.aspect = '1x1',
    this.videoPosterJpeg,
    this.videoTrimStartMs = 0,

    /// Явная длина отрезка; `null` — поведение до двухручкового триммера (окно [publishableVideoWindowMs]).
    this.videoTrimDurationMs,
    this.videoDurationMs,
    this.videoNativeFrameW,
    this.videoNativeFrameH,
    this.videoCropX,
    this.videoCropY,
    this.videoCropW,
    this.videoCropH,
  }) : displayFile = displayFile ?? originalFile;

  /// Полный файл с галереи — не перезаписывается при повторной обрезке.
  final File originalFile;

  /// Текущая версия для UI и пайплайна редактирования.
  final File displayFile;

  final bool isVideo;

  /// Encoded into storage name as `__ar-<aspect>` (e.g. `1x1`, `9x16`).
  final String aspect;

  /// User-selected JPEG cover for video (feed thumbnail); null until chosen or baked default.
  final Uint8List? videoPosterJpeg;

  /// Начало фрагмента для публикации (максимум [kPostCreateMaxVideoPublishMs] подряд).
  final int videoTrimStartMs;

  /// Длина выбранного фрагмента (мс), если пользователь задал двумя ручками; иначе `null`.
  final int? videoTrimDurationMs;

  /// Длительность исходника (мс); null пока не определена.
  final int? videoDurationMs;

  /// Ширина/высота кадра исходника (после spatial crop обязательны вместе с [videoCrop*]).
  final int? videoNativeFrameW;
  final int? videoNativeFrameH;

  final int? videoCropX;
  final int? videoCropY;
  final int? videoCropW;
  final int? videoCropH;

  bool get hasSpatialVideoCrop =>
      videoCropX != null &&
      videoCropY != null &&
      videoCropW != null &&
      videoCropH != null &&
      videoNativeFrameW != null &&
      videoNativeFrameH != null &&
      videoCropW! > 0 &&
      videoCropH! > 0;

  PostCreateSlot copyWithDisplay(File newDisplay) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: newDisplay,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithAspect(String newAspect) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: newAspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithVideoPoster(Uint8List? poster) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: poster,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithVideoTrim(int ms) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: ms,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithVideoTrimDuration(int? ms) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: ms,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithVideoDuration(int? ms) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: ms,
    videoNativeFrameW: videoNativeFrameW,
    videoNativeFrameH: videoNativeFrameH,
    videoCropX: videoCropX,
    videoCropY: videoCropY,
    videoCropW: videoCropW,
    videoCropH: videoCropH,
  );

  PostCreateSlot copyWithVideoSpatialCrop({
    required int nativeFrameW,
    required int nativeFrameH,
    required int cropX,
    required int cropY,
    required int cropW,
    required int cropH,
  }) => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
    videoNativeFrameW: nativeFrameW,
    videoNativeFrameH: nativeFrameH,
    videoCropX: cropX,
    videoCropY: cropY,
    videoCropW: cropW,
    videoCropH: cropH,
  );

  PostCreateSlot clearVideoSpatialCrop() => PostCreateSlot(
    originalFile: originalFile,
    displayFile: displayFile,
    isVideo: isVideo,
    aspect: aspect,
    videoPosterJpeg: videoPosterJpeg,
    videoTrimStartMs: videoTrimStartMs,
    videoTrimDurationMs: videoTrimDurationMs,
    videoDurationMs: videoDurationMs,
  );
}

int _legacyMaxTrimStartMs(int durationMs) {
  final w = durationMs < kPostCreateMaxVideoPublishMs ? durationMs : kPostCreateMaxVideoPublishMs;
  return max(0, durationMs - w);
}

extension PostCreateSlotVideoSegment on PostCreateSlot {
  /// После известной длительности — поджать старт/длину в допустимый диапазон.
  PostCreateSlot withClampedTrim() {
    if (!isVideo || videoDurationMs == null || videoDurationMs! <= 0) {
      return this;
    }
    final nextStart = clampedTrimStartMs();
    final nextDur = clampedTrimDurationMs();
    if (nextStart == videoTrimStartMs && (videoTrimDurationMs == null || nextDur == videoTrimDurationMs)) {
      return this;
    }
    return copyWithVideoTrim(
      nextStart,
    ).copyWithVideoTrimDuration(videoTrimDurationMs != null ? nextDur : null);
  }

  /// Длина публикуемого фрагмента (мс), с учётом лимитов и клампа.
  int clampedTrimDurationMs() {
    if (!isVideo || videoDurationMs == null || videoDurationMs! <= 0) {
      return 0;
    }
    final d = videoDurationMs!;
    final minSeg = min(kPostCreateMinVideoSegmentMs, d);
    final maxSeg = min(kPostCreateMaxVideoPublishMs, d);

    // if (videoTrimDurationMs == null) {
    //   final start = videoTrimStartMs.clamp(0, _legacyMaxTrimStartMs(d));
    //   return publishableVideoWindowMs(durationMs: d, trimStartMs: start);
    // }

    var len = videoTrimDurationMs!.clamp(minSeg, maxSeg);
    final maxStart = max(0, d - len);
    final startClamped = videoTrimStartMs.clamp(0, maxStart);
    len = len.clamp(minSeg, min(maxSeg, d - startClamped));
    return len;
  }

  int clampedTrimStartMs() {
    if (!isVideo || videoDurationMs == null || videoDurationMs! <= 0) {
      return videoTrimStartMs.clamp(0, 1 << 30);
    }
    final d = videoDurationMs!;
    if (videoTrimDurationMs == null) {
      final maxS = _legacyMaxTrimStartMs(d);
      return videoTrimStartMs.clamp(0, maxS);
    }
    final len = clampedTrimDurationMs();
    final maxS = max(0, d - len);
    return videoTrimStartMs.clamp(0, maxS);
  }

  int segmentEndMs() {
    if (!isVideo) {
      return 0;
    }
    final start = clampedTrimStartMs();
    if (videoDurationMs == null || videoDurationMs! <= 0) {
      return start + kPostCreateMaxVideoPublishMs;
    }
    return start + clampedTrimDurationMs();
  }
}

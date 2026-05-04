// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'dart:io';
// import 'dart:math' as math;

// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/media_information.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';

// import 'package:side_project/feature/post_create_page/domain/post_create_video_constants.dart';

// const _kLogName = 'PostCreateVideoTrim';

// /// iPhone .MOV часто содержит data/mebx-стримы; в MP4 их нельзя. Мапим только A/V.
// const _kFfmpegMapVideoAndOptAudio = <String>['-map', '0:v', '-map', '0:a?'];

// void _logFfmpegFailure(
//   String stage,
//   List<String> args,
//   ReturnCode? returnCode,
//   String outputLog,
// ) {
//   final rc = returnCode?.getValue();
//   final argsLine = args.join(' ');
//   developer.log(
//     '[$stage] returnCode=$rc\n$argsLine\n---\n$outputLog',
//     name: _kLogName,
//     level: 1000,
//   );
// }

// /// Длительность локального файла (мс): сначала [VideoPlayer], иначе FFprobe (MOV/HEVC на iOS часто даёт 0/null в плеере).
// Future<int?> probeVideoDurationMs(File file) async {
//   final c = VideoPlayerController.file(file)..setVolume(0);
//   try {
//     await c.initialize();
//     final ms = c.value.duration.inMilliseconds;
//     if (ms > 0) {
//       return ms;
//     }
//   } catch (_) {
//     // fallback ниже
//   } finally {
//     try {
//       await c.dispose();
//     } catch (_) {}
//   }
//   return _probeVideoDurationMsFfprobe(file);
// }

// double? _durationSecondsFromMediaInformation(MediaInformation mi) {
//   final numDur = mi.getNumberFormatProperty(MediaInformation.keyDuration);
//   if (numDur != null && numDur > 0) {
//     return numDur.toDouble();
//   }
//   final ds = mi.getDuration();
//   if (ds != null && ds.isNotEmpty && ds != 'N/A') {
//     final p = double.tryParse(ds.trim());
//     if (p != null && p > 0) {
//       return p;
//     }
//   }
//   for (final st in mi.getStreams()) {
//     if (st.getType() != 'video') {
//       continue;
//     }
//     final sn = st.getNumberProperty('duration');
//     if (sn != null && sn > 0) {
//       return sn.toDouble();
//     }
//     final dd = st.getStringProperty('duration');
//     if (dd != null && dd.isNotEmpty && dd != 'N/A') {
//       final p = double.tryParse(dd.trim());
//       if (p != null && p > 0) {
//         return p;
//       }
//     }
//   }
//   return null;
// }

// Future<int?> _probeVideoDurationMsFfprobeFormatCli(File file) async {
//   try {
//     final session = await FFprobeKit.executeWithArguments([
//       '-v',
//       'error',
//       '-show_entries',
//       'format=duration',
//       '-of',
//       'default=noprint_wrappers=1:nokey=1',
//       file.path,
//     ]);
//     final out = await session.getOutput();
//     if (out == null || out.trim().isEmpty) {
//       return null;
//     }
//     for (final line in out.split('\n')) {
//       final t = line.trim();
//       if (t.isEmpty || t == 'N/A') {
//         continue;
//       }
//       final secs = double.tryParse(t);
//       if (secs != null && secs > 0) {
//         return (secs * 1000).round();
//       }
//     }
//   } catch (e, st) {
//     developer.log(
//       'FFprobe CLI duration failed: $e',
//       name: _kLogName,
//       error: e,
//       stackTrace: st,
//       level: 800,
//     );
//   }
//   return null;
// }

// Future<int?> _probeVideoDurationMsFfprobe(File file) async {
//   try {
//     final session = await FFprobeKit.getMediaInformation(file.path);
//     final mi = session.getMediaInformation();
//     if (mi != null) {
//       final secs = _durationSecondsFromMediaInformation(mi);
//       if (secs != null && secs > 0) {
//         return (secs * 1000).round();
//       }
//     }
//   } catch (e, st) {
//     developer.log(
//       'FFprobe getMediaInformation duration failed: $e',
//       name: _kLogName,
//       error: e,
//       stackTrace: st,
//       level: 800,
//     );
//   }
//   return _probeVideoDurationMsFfprobeFormatCli(file);
// }

// /// Размер **закодированного** видеопотока (как у FFmpeg в фильтре crop), без учёта display rotation.
// Future<({int w, int h})?> probeVideoEncodedStreamSizePx(File file) async {
//   try {
//     final session = await FFprobeKit.getMediaInformation(file.path);
//     final mi = session.getMediaInformation();
//     if (mi == null) {
//       return null;
//     }
//     for (final s in mi.getStreams()) {
//       if (s.getType() == 'video') {
//         final w = s.getWidth();
//         final h = s.getHeight();
//         if (w != null && h != null && w > 0 && h > 0) {
//           return (w: w, h: h);
//         }
//       }
//     }
//   } catch (e, st) {
//     developer.log(
//       'FFprobe stream size failed: $e',
//       name: _kLogName,
//       error: e,
//       stackTrace: st,
//       level: 800,
//     );
//   }
//   return null;
// }

// /// Угол поворота для отображения из метаданных потока (0..359, по часовой), либо `null`.
// ///
// /// Учитывает `side_data` Display Matrix (iPhone HEVC) и тег `rotate`.
// Future<int?> probeVideoDisplayRotationDegrees(File file) async {
//   try {
//     final session = await FFprobeKit.executeWithArguments([
//       '-v',
//       'error',
//       '-select_streams',
//       'v:0',
//       '-show_streams',
//       '-of',
//       'json',
//       file.path,
//     ]);
//     final out = await session.getOutput();
//     if (out == null || out.trim().isEmpty) {
//       return null;
//     }
//     final decoded = jsonDecode(out) as Map<String, dynamic>?;
//     final streams = decoded?['streams'] as List<dynamic>?;
//     if (streams == null || streams.isEmpty) {
//       return null;
//     }
//     final raw = streams.first;
//     if (raw is! Map) {
//       return null;
//     }
//     final stream = Map<String, dynamic>.from(raw);

//     final fromSideData = _parseRotationFromSideData(stream);
//     if (fromSideData != null) {
//       return _normalizeRotationDegrees(fromSideData);
//     }
//     final tagsRaw = stream['tags'];
//     if (tagsRaw is Map) {
//       final tags = Map<String, dynamic>.from(tagsRaw);
//       final rotate = tags['rotate'];
//       if (rotate != null) {
//         final parsed = int.tryParse(rotate.toString());
//         if (parsed != null) {
//           return _normalizeRotationDegrees(parsed);
//         }
//       }
//     }
//   } catch (e, st) {
//     developer.log(
//       'FFprobe rotation failed: $e',
//       name: _kLogName,
//       error: e,
//       stackTrace: st,
//       level: 800,
//     );
//   }
//   return null;
// }

// int _normalizeRotationDegrees(int deg) {
//   var r = deg % 360;
//   if (r < 0) {
//     r += 360;
//   }
//   return r;
// }

// /// Как `libavutil` `av_display_rotation_get`: угол в градусах (может быть −90, 0, …).
// double? _displayRotationDegreesFromMatrix9(List<int> matrix9) {
//   if (matrix9.length != 9) {
//     return null;
//   }
//   double convFp(int x) => x / 65536.0;
//   final m = matrix9;
//   final scale0 = math.sqrt(convFp(m[0]) * convFp(m[0]) + convFp(m[3]) * convFp(m[3]));
//   final scale1 = math.sqrt(convFp(m[1]) * convFp(m[1]) + convFp(m[4]) * convFp(m[4]));
//   if (scale0 == 0 || scale1 == 0) {
//     return double.nan;
//   }
//   final rotation = math.atan2(
//         convFp(m[1]) / scale1,
//         convFp(m[0]) / scale0,
//       ) *
//       180 /
//       math.pi;
//   return -rotation;
// }

// int _hexUint32ToSignedInt32(int u) {
//   final masked = u & 0xffffffff;
//   if (masked > 0x7fffffff) {
//     return masked - 0x100000000;
//   }
//   return masked;
// }

// /// Строка `displaymatrix` из FFprobe JSON: девять 32-bit hex полей (fix16.16).
// int? _rotationDegreesIntFromDisplayMatrixString(String raw) {
//   final cells = RegExp(r'[0-9a-fA-F]{8}')
//       .allMatches(raw)
//       .map((m) => m.group(0)!)
//       .take(9)
//       .toList();
//   if (cells.length < 9) {
//     return null;
//   }
//   final ints = <int>[];
//   for (final h in cells) {
//     final u = int.parse(h, radix: 16);
//     ints.add(_hexUint32ToSignedInt32(u));
//   }
//   final deg = _displayRotationDegreesFromMatrix9(ints);
//   if (deg == null || deg.isNaN) {
//     return null;
//   }
//   return deg.round();
// }

// int? _parseRotationFromSideData(Map<String, dynamic> stream) {
//   final sideList = stream['side_data_list'];
//   if (sideList is! List<dynamic>) {
//     return null;
//   }
//   for (final sd in sideList) {
//     if (sd is! Map) {
//       continue;
//     }
//     final m = Map<String, dynamic>.from(sd);
//     final type = m['side_data_type']?.toString() ?? '';
//     if (!type.contains('Display Matrix')) {
//       continue;
//     }
//     final rot = m['rotation'];
//     if (rot != null) {
//       if (rot is num) {
//         return rot.round();
//       }
//       final p = int.tryParse(rot.toString());
//       if (p != null) {
//         return p;
//       }
//     }
//     final dm = m['displaymatrix'];
//     if (dm != null) {
//       final fromMatrix = _rotationDegreesIntFromDisplayMatrixString(dm.toString());
//       if (fromMatrix != null) {
//         return fromMatrix;
//       }
//     }
//   }
//   return null;
// }

// bool _logLooksLikeCropPadDimensionMismatch(String log) {
//   return log.contains('Invalid too big or non positive size') &&
//       log.contains('Parsed_crop');
// }

// /// Фильтр в начале цепочки: выровнять буфер декодера до закодированного кадра
// /// (`1920×1080`) перед [crop], если в контейнере указан поворот ±90°/270°.
// String _transposeFilterPrefixForRotation(int? rotationDeg) {
//   final t = _transposeFilterTokenForRotation(rotationDeg);
//   if (t.isEmpty) {
//     return '';
//   }
//   return '$t,';
// }

// /// То же для цепочки `crop → transpose`: одна нода без ведущей запятой.
// String _transposeFilterTokenForRotation(int? rotationDeg) {
//   if (rotationDeg == null) {
//     return '';
//   }
//   final r = _normalizeRotationDegrees(rotationDeg);
//   if (r == 0) {
//     return '';
//   }
//   if (r == 90) {
//     return 'transpose=2';
//   }
//   if (r == 270) {
//     return 'transpose=1';
//   }
//   if (r == 180) {
//     return 'transpose=2,transpose=2';
//   }
//   return '';
// }

// /// Размер кадра для UI/маппинга: сначала **FFprobe** (совпадает с FFmpeg crop), иначе VideoPlayer.
// Future<({int w, int h})?> probeVideoFrameSizePx(File file) async {
//   final coded = await probeVideoEncodedStreamSizePx(file);
//   if (coded != null) {
//     return coded;
//   }
//   final c = VideoPlayerController.file(file)..setVolume(0);
//   try {
//     await c.initialize();
//     final sz = c.value.size;
//     final w = sz.width.round();
//     final h = sz.height.round();
//     if (w <= 0 || h <= 0) {
//       return null;
//     }
//     return (w: w, h: h);
//   } catch (_) {
//     return null;
//   } finally {
//     await c.dispose();
//   }
// }

// /// Длина фрагмента для выгрузки (не больше [kPostCreateMaxVideoPublishMs]).
// int publishableVideoWindowMs({required int durationMs, required int trimStartMs}) {
//   final cap = durationMs < kPostCreateMaxVideoPublishMs ? durationMs : kPostCreateMaxVideoPublishMs;
//   final remain = durationMs - trimStartMs;
//   if (remain <= 0) {
//     return 0;
//   }
//   return remain < cap ? remain : cap;
// }

// ({int x, int y, int w, int h}) _evenCropBox({
//   required int x,
//   required int y,
//   required int w,
//   required int h,
//   required int frameW,
//   required int frameH,
// }) {
//   var cx = x.clamp(0, frameW - 2);
//   var cy = y.clamp(0, frameH - 2);
//   var cw = w.clamp(2, frameW - cx);
//   var ch = h.clamp(2, frameH - cy);
//   cx = cx & ~1;
//   cy = cy & ~1;
//   cw = cw & ~1;
//   ch = ch & ~1;
//   if (cw < 2 || ch < 2 || cx + cw > frameW || cy + ch > frameH) {
//     developer.log(
//       'Invalid crop box: x=$x y=$y w=$w h=$h frame=${frameW}x$frameH',
//       name: _kLogName,
//       level: 1000,
//     );
//     throw StateError('Некорректная область обрезки видео');
//   }
//   return (x: cx, y: cy, w: cw, h: ch);
// }

// bool _spatialCropSkippable({
//   required int frameW,
//   required int frameH,
//   required int cx,
//   required int cy,
//   required int cw,
//   required int ch,
// }) {
//   const tol = 6;
//   return cx <= tol &&
//       cy <= tol &&
//       cw >= frameW - tol &&
//       ch >= frameH - tol &&
//       cw <= frameW &&
//       ch <= frameH;
// }

// bool get _useAppleHwVideoEnc {
//   if (Platform.isIOS || Platform.isMacOS) {
//     return true;
//   }
//   return false;
// }

// /// Цепочка аргументов перекодирования видео: на iOS/macOS — VideoToolbox (стабильно с FFmpeg 8.x), иначе libx264.
// List<String> _reencodeVideoCodecArgs() {
//   if (_useAppleHwVideoEnc) {
//     return [
//       '-c:v',
//       'h264_videotoolbox',
//       '-b:v',
//       '8M',
//       '-pix_fmt',
//       'yuv420p',
//     ];
//   }
//   return ['-c:v', 'libx264', '-preset', 'veryfast', '-crf', '23'];
// }

// Future<bool> _execSuccess(List<String> arguments) async {
//   final session = await FFmpegKit.executeWithArguments(arguments);
//   return ReturnCode.isSuccess(await session.getReturnCode());
// }

// /// Обрезка по времени и опционально по кадру → временный MP4.
// ///
// /// [cropX]/[cropY]/[cropW]/[cropH] и [frameWidth]/[frameHeight] задают прямоугольник в пикселях исходника.
// Future<File> trimCropVideoToTempMp4({
//   required File source,
//   required int startMs,
//   required int lengthMs,
//   int? cropX,
//   int? cropY,
//   int? cropW,
//   int? cropH,
//   int? frameWidth,
//   int? frameHeight,
// }) async {
//   if (lengthMs <= 0) {
//     throw ArgumentError.value(lengthMs, 'lengthMs', 'must be > 0');
//   }

//   ({int x, int y, int w, int h})? crop;
//   final cx = cropX;
//   final cy = cropY;
//   final cw = cropW;
//   final ch = cropH;
//   final fw = frameWidth;
//   final fh = frameHeight;
//   var cropThenTransposeLayout = false;
//   if (cx != null && cy != null && cw != null && ch != null && fw != null && fh != null) {
//     crop = _evenCropBox(
//       x: cx,
//       y: cy,
//       w: cw,
//       h: ch,
//       frameW: fw,
//       frameH: fh,
//     );
//     if (_spatialCropSkippable(
//       frameW: fw,
//       frameH: fh,
//       cx: crop.x,
//       cy: crop.y,
//       cw: crop.w,
//       ch: crop.h,
//     )) {
//       crop = null;
//     }
//   }

//   // Слот: размеры как у превью кропа (1080×1920); FFprobe — закодированный кадр (1920×1080).
//   // При повороте 90° оси меняются местами — линейный remap (x*w, y*h) ломает ориентацию.
//   if (crop != null && fw != null && fh != null) {
//     final coded = await probeVideoEncodedStreamSizePx(source);
//     if (coded != null) {
//       final is90Case = coded.w != coded.h && fw == coded.h && fh == coded.w;

//       if (fw != coded.w || fh != coded.h) {
//         if (is90Case) {
//           cropThenTransposeLayout = true;
//           developer.log(
//             'Crop: превью ${fw}x$fh vs coded ${coded.w}x${coded.h} (90°) — без линейного remap; vf: crop → transpose',
//             name: _kLogName,
//             level: 800,
//           );
//           crop = _evenCropBox(
//             x: crop.x,
//             y: crop.y,
//             w: crop.w,
//             h: crop.h,
//             frameW: fw,
//             frameH: fh,
//           );
//         } else {
//           developer.log(
//             'Crop remap: stored native ${fw}x$fh → ffprobe coded ${coded.w}x${coded.h}',
//             name: _kLogName,
//             level: 800,
//           );
//           crop = _evenCropBox(
//             x: (crop.x * coded.w / fw).round(),
//             y: (crop.y * coded.h / fh).round(),
//             w: (crop.w * coded.w / fw).round(),
//             h: (crop.h * coded.h / fh).round(),
//             frameW: coded.w,
//             frameH: coded.h,
//           );
//         }
//       } else {
//         crop = _evenCropBox(
//           x: crop.x,
//           y: crop.y,
//           w: crop.w,
//           h: crop.h,
//           frameW: coded.w,
//           frameH: coded.h,
//         );
//       }
//       final skipW = cropThenTransposeLayout ? fw : coded.w;
//       final skipH = cropThenTransposeLayout ? fh : coded.h;
//       if (_spatialCropSkippable(
//         frameW: skipW,
//         frameH: skipH,
//         cx: crop.x,
//         cy: crop.y,
//         cw: crop.w,
//         ch: crop.h,
//       )) {
//         crop = null;
//       }
//     }
//   }

//   final dir = await getTemporaryDirectory();
//   final out = File('${dir.path}/post_clip_${DateTime.now().microsecondsSinceEpoch}.mp4');
//   final startSec = startMs / 1000.0;
//   final durSec = lengthMs / 1000.0;
//   final inPath = source.path;
//   final outPath = out.path;

//   final startStr = startSec.toString();
//   final durStr = durSec.toString();

//   if (crop == null) {
//     // 1) Быстрый stream copy (-ss до -i).
//     final copyFast = <String>[
//       '-y',
//       '-ss',
//       startStr,
//       '-i',
//       inPath,
//       '-t',
//       durStr,
//       ..._kFfmpegMapVideoAndOptAudio,
//       '-c',
//       'copy',
//       '-movflags',
//       '+faststart',
//       outPath,
//     ];
//     if (await _execSuccess(copyFast)) {
//       return out;
//     }

//     // 2) Точная обрезка по времени (-ss после -i), всё ещё copy.
//     final copyAccurate = <String>[
//       '-y',
//       '-i',
//       inPath,
//       '-ss',
//       startStr,
//       '-t',
//       durStr,
//       ..._kFfmpegMapVideoAndOptAudio,
//       '-c',
//       'copy',
//       '-movflags',
//       '+faststart',
//       outPath,
//     ];
//     if (await _execSuccess(copyAccurate)) {
//       return out;
//     }

//     // 3) Перекодирование (iOS: VideoToolbox; Android: libx264).
//     final reencode = <String>[
//       '-y',
//       '-ss',
//       startStr,
//       '-i',
//       inPath,
//       '-t',
//       durStr,
//       ..._kFfmpegMapVideoAndOptAudio,
//       ..._reencodeVideoCodecArgs(),
//       '-c:a',
//       'aac',
//       '-b:a',
//       '128k',
//       '-movflags',
//       '+faststart',
//       outPath,
//     ];
//     final reSession = await FFmpegKit.executeWithArguments(reencode);
//     final reRc = await reSession.getReturnCode();
//     if (ReturnCode.isSuccess(reRc)) {
//       return out;
//     }
//     final log = await reSession.getLogsAsString();
//     _logFfmpegFailure('reencode_after_copy_failed', reencode, reRc, log);
//     throw StateError(
//       'Не удалось обрезать видео. Последняя попытка (перекодирование): $log',
//     );
//   }

//   // yuv420p: 10-bit HDR/HEVC → 8-bit для libx264 / VideoToolbox; иначе crop может падать на yuv420p10le.
//   // Display Matrix / rotate: декодер может отдавать кадр 1080×1920, пока crop считает закодированный 1920×1080.
//   final displayRotation = await probeVideoDisplayRotationDegrees(source);
//   final transposeAfterToken = _transposeFilterTokenForRotation(displayRotation);
//   var transposePrefix = cropThenTransposeLayout ? '' : _transposeFilterPrefixForRotation(displayRotation);
//   if (!cropThenTransposeLayout && transposePrefix.isNotEmpty) {
//     developer.log(
//       'Crop vf: prepend transpose (displayRotation=$displayRotation°)',
//       name: _kLogName,
//       level: 800,
//     );
//   }

//   final maxTransposeTries = cropThenTransposeLayout ? (transposeAfterToken.isNotEmpty ? 1 : 2) : 2;

//   for (var transposeRetry = 0; transposeRetry < maxTransposeTries; transposeRetry++) {
//     late final String cropExpr;
//     if (cropThenTransposeLayout) {
//       final useToken = transposeAfterToken.isNotEmpty
//           ? transposeAfterToken
//           : (transposeRetry == 0 ? '' : 'transpose=1');
//       cropExpr = useToken.isEmpty
//           ? 'crop=${crop.w}:${crop.h}:${crop.x}:${crop.y},format=yuv420p'
//           : 'crop=${crop.w}:${crop.h}:${crop.x}:${crop.y},$useToken,format=yuv420p';
//     } else {
//       cropExpr =
//           '${transposePrefix}crop=${crop.w}:${crop.h}:${crop.x}:${crop.y},format=yuv420p';
//     }
//     final encCrop = <String>[
//       '-y',
//       '-ss',
//       startStr,
//       '-i',
//       inPath,
//       '-t',
//       durStr,
//       '-vf',
//       cropExpr,
//       ..._kFfmpegMapVideoAndOptAudio,
//       ..._reencodeVideoCodecArgs(),
//       '-c:a',
//       'aac',
//       '-b:a',
//       '128k',
//       '-movflags',
//       '+faststart',
//       outPath,
//     ];
//     final encSession = await FFmpegKit.executeWithArguments(encCrop);
//     final encRc = await encSession.getReturnCode();
//     final encLog = await encSession.getLogsAsString();
//     if (ReturnCode.isSuccess(encRc)) {
//       return out;
//     }

//     // Fallback на Apple: если VideoToolbox не смог — пробуем libx264 из сборки GPL.
//     String lastLog = encLog;
//     ReturnCode? lastRc = encRc;
//     var lastArgs = encCrop;

//     if (_useAppleHwVideoEnc) {
//       final soft = <String>[
//         '-y',
//         '-ss',
//         startStr,
//         '-i',
//         inPath,
//         '-t',
//         durStr,
//         '-vf',
//         cropExpr,
//         ..._kFfmpegMapVideoAndOptAudio,
//         '-c:v',
//         'libx264',
//         '-preset',
//         'veryfast',
//         '-crf',
//         '23',
//         '-c:a',
//         'aac',
//         '-b:a',
//         '128k',
//         '-movflags',
//         '+faststart',
//         outPath,
//       ];
//       final softSession = await FFmpegKit.executeWithArguments(soft);
//       final softRc = await softSession.getReturnCode();
//       final softLog = await softSession.getLogsAsString();
//       if (ReturnCode.isSuccess(softRc)) {
//         return out;
//       }
//       lastLog = softLog;
//       lastRc = softRc;
//       lastArgs = soft;
//     }

//     final mismatch =
//         _logLooksLikeCropPadDimensionMismatch(encLog) || _logLooksLikeCropPadDimensionMismatch(lastLog);
//     if (!cropThenTransposeLayout &&
//         transposeRetry == 0 &&
//         transposePrefix.isEmpty &&
//         mismatch) {
//       transposePrefix = 'transpose=1,';
//       developer.log(
//         'Crop: retry with transpose=1 (rotation metadata missing / crop pad mismatch)',
//         name: _kLogName,
//         level: 800,
//       );
//       continue;
//     }

//     if (_useAppleHwVideoEnc) {
//       _logFfmpegFailure('crop_fallback_libx264', lastArgs, lastRc, lastLog);
//     } else {
//       _logFfmpegFailure('crop_videotoolbox_or_libx264', encCrop, encRc, encLog);
//     }
//     throw StateError('Не удалось обрезать видео (кадр): $lastLog');
//   }

//   throw StateError('Не удалось обрезать видео (кадр)');
// }

// /// @nodoc — совместимость; без пространственного кадра.
// Future<File> trimVideoToTempMp4({
//   required File source,
//   required int startMs,
//   required int lengthMs,
// }) =>
//     trimCropVideoToTempMp4(source: source, startMs: startMs, lengthMs: lengthMs);

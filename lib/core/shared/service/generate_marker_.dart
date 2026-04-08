import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Bitmap-маркеры для карты (Yandex MapKit): эмодзи в спокойном минималистичном круге.
class MarkerGeneratorService {
  static final Map<String, Uint8List> _cache = {};

  static const String _styleRevision = 'v7';

  /// Прямоугольное превью по сети (скруглённые углы, тень) — кэш по URL.
  /// Моментальный снимок: белая рамка, широкое поле снизу, лёгкий наклон, мягкая тень.
  static Future<Uint8List?> createPolaroidPhotoMarkerFromUrl(String url, {bool compact = false}) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final polaroidRev = compact ? 'p6_compact' : 'p5_map';
    final cacheKey = 'photo_polaroid|$polaroidRev|$trimmed';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    ui.Image? decoded;
    try {
      decoded = await _loadNetworkImage(trimmed, maxDecodeSide: compact ? 140 : 384);
      final bytes = compact
          ? await _drawPolaroidPhotoMarkerCompact(decoded, trimmed)
          : await _drawPolaroidPhotoMarker(decoded, trimmed);
      _cache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Ошибка polaroid-маркера $url: $e');
    } finally {
      decoded?.dispose();
    }
    return null;
  }

  static Future<Uint8List?> createPhotoMarkerFromUrl(String url, {bool compact = false}) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    final rev = compact ? '${_styleRevision}_c' : _styleRevision;
    final cacheKey = 'photo_rect|$rev|$trimmed';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    ui.Image? decoded;
    try {
      decoded = await _loadNetworkImage(trimmed, maxDecodeSide: compact ? 140 : 384);
      final bytes = compact ? await _drawRectPhotoMarkerCompact(decoded) : await _drawRectPhotoMarker(decoded);
      _cache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Ошибка фото-маркера $url: $e');
    } finally {
      decoded?.dispose();
    }
    return null;
  }

  static Future<Uint8List> _drawPolaroidPhotoMarker(ui.Image src, String urlForAngle) async {
    // Компактная текстура: на карте масштабируется через PlacemarkIconStyle.scale.
    const imgSize = 168.0;
    const sidePad = 11.0;
    const topPad = 10.0;
    const bottomPad = 34.0;
    final cardW = sidePad + imgSize + sidePad;
    final cardH = topPad + imgSize + bottomPad;

    final tilt = ((urlForAngle.hashCode % 11) - 5) * math.pi / 180;

    const canvasExtent = 368.0;
    final center = Offset(canvasExtent / 2, canvasExtent / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    canvas.translate(-cardW / 2, -cardH / 2);

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, cardW, cardH),
      const Radius.circular(5),
    );

    final shadowPaint = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRRect(cardRect.shift(const Offset(0, 9)), shadowPaint);

    final paper = Paint()..color = const Color(0xFFF7F5F2);
    canvas.drawRRect(cardRect, paper);

    // Лёгкая «наклейка» на карте: внешнее свечение.
    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawRRect(cardRect.inflate(1.2), halo);

    final imgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(sidePad, topPad, imgSize, imgSize),
      const Radius.circular(3.5),
    );
    canvas.save();
    canvas.clipRRect(imgRect);
    paintImage(
      canvas: canvas,
      rect: imgRect.outerRect,
      image: src,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.low,
    );
    canvas.restore();

    final gloss = Paint()
      ..shader = ui.Gradient.linear(
        imgRect.outerRect.topLeft,
        imgRect.outerRect.bottomRight,
        [Colors.white.withValues(alpha: 0.18), Colors.transparent],
      );
    canvas.save();
    canvas.clipRRect(imgRect);
    canvas.drawRect(imgRect.outerRect, gloss);
    canvas.restore();

    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = const Color(0xFF2A2A2A).withValues(alpha: 0.12);
    canvas.drawRRect(imgRect.deflate(0.65), rim);

    final outerRim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFC8CED6).withValues(alpha: 0.55);
    canvas.drawRRect(cardRect.deflate(0.5), outerRim);

    // Мини-«кнопка» в белой полосе — визуальная точка привязки к карте.
    final pinY = topPad + imgSize + bottomPad * 0.42;
    final pinCx = cardW / 2;
    canvas.drawCircle(
      Offset(pinCx, pinY),
      5,
      Paint()..color = const Color(0xFFE2E6EB),
    );
    canvas.drawCircle(
      Offset(pinCx, pinY),
      5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..color = const Color(0xFF9AA3AE).withValues(alpha: 0.65),
    );

    canvas.restore();

    final out = await recorder.endRecording().toImage(canvasExtent.toInt(), canvasExtent.toInt());
    try {
      final byteData = await out.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      out.dispose();
    }
  }

  /// Облегчённый полароид: меньше пикселей → меньше нагрузка на CPU/GPU при сотнях точек.
  static Future<Uint8List> _drawPolaroidPhotoMarkerCompact(ui.Image src, String urlForAngle) async {
    const imgSize = 108.0;
    const sidePad = 8.0;
    const topPad = 8.0;
    const bottomPad = 22.0;
    final cardW = sidePad + imgSize + sidePad;
    final cardH = topPad + imgSize + bottomPad;
    final tilt = ((urlForAngle.hashCode % 11) - 5) * math.pi / 180;
    const canvasExtent = 260.0;
    final center = Offset(canvasExtent / 2, canvasExtent / 2);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    canvas.translate(-cardW / 2, -cardH / 2);
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, cardW, cardH),
      const Radius.circular(4),
    );
    final shadowPaint = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(cardRect.shift(const Offset(0, 6)), shadowPaint);
    canvas.drawRRect(cardRect, Paint()..color = const Color(0xFFF7F5F2));
    final imgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(sidePad, topPad, imgSize, imgSize),
      const Radius.circular(3),
    );
    canvas.save();
    canvas.clipRRect(imgRect);
    paintImage(
      canvas: canvas,
      rect: imgRect.outerRect,
      image: src,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.none,
    );
    canvas.restore();
    canvas.drawRRect(
      imgRect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFC8CED6).withValues(alpha: 0.5),
    );
    final pinY = topPad + imgSize + bottomPad * 0.42;
    canvas.drawCircle(
      Offset(cardW / 2, pinY),
      3.5,
      Paint()..color = const Color(0xFFE2E6EB),
    );
    canvas.restore();
    final out = await recorder.endRecording().toImage(canvasExtent.toInt(), canvasExtent.toInt());
    try {
      final byteData = await out.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      out.dispose();
    }
  }

  /// Ограничиваем декод по пикселям: исходники часто 1080×1080 — для маркера достаточно ~384 px по длинной стороне.
  static Future<ui.Image> _loadNetworkImage(String url, {int maxDecodeSide = 384}) async {
    final provider = ResizeImage(
      NetworkImage(url),
      width: maxDecodeSide,
      height: maxDecodeSide,
      allowUpscaling: false,
    );
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration(devicePixelRatio: 1.0));
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (Object e, StackTrace? st) {
        if (!completer.isCompleted) completer.completeError(e, st);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  static Future<Uint8List> _drawRectPhotoMarker(ui.Image src) async {
    const pad = 26.0;
    const cw = 220.0;
    const ch = 276.0;
    const r = 12.0;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, cw, ch),
      const Radius.circular(r),
    );
    final totalW = pad * 2 + cw;
    final totalH = pad * 2 + ch;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final shadow = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(cardRect.shift(const Offset(0, 6)), shadow);

    canvas.save();
    canvas.clipRRect(cardRect);
    paintImage(
      canvas: canvas,
      rect: cardRect.outerRect,
      image: src,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.low,
    );
    canvas.restore();

    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFC5CCD4);
    canvas.drawRRect(cardRect.deflate(1.25), rim);

    final out = await recorder.endRecording().toImage(totalW.toInt(), totalH.toInt());
    try {
      final byteData = await out.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      out.dispose();
    }
  }

  static Future<Uint8List> _drawRectPhotoMarkerCompact(ui.Image src) async {
    const pad = 12.0;
    const cw = 120.0;
    const ch = 152.0;
    const r = 10.0;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, cw, ch),
      const Radius.circular(r),
    );
    final totalW = pad * 2 + cw;
    final totalH = pad * 2 + ch;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final shadow = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(cardRect.shift(const Offset(0, 4)), shadow);
    canvas.save();
    canvas.clipRRect(cardRect);
    paintImage(
      canvas: canvas,
      rect: cardRect.outerRect,
      image: src,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.none,
    );
    canvas.restore();
    canvas.drawRRect(
      cardRect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFC5CCD4),
    );
    final out = await recorder.endRecording().toImage(totalW.toInt(), totalH.toInt());
    try {
      final byteData = await out.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      out.dispose();
    }
  }

  static Future<Uint8List?> createEmojiMarker(String emoji) async {
    final cacheKey = '$_styleRevision|$emoji';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    try {
      final Uint8List markerBytes = await _drawMarkerWithSystemEmoji(emoji);
      _cache[cacheKey] = markerBytes;
      return markerBytes;
    } catch (e) {
      debugPrint('Ошибка генерации маркера $emoji: $e');
    }
    return null;
  }

  static Future<Uint8List> _drawMarkerWithSystemEmoji(String emoji) async {
    const double size = 280.0;
    const double radius = 86.0;
    const double emojiFontSize = 88.0;
    final center = Offset(size / 2, size / 2 - 4);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Одна мягкая тень снизу — без цветного ореола
    final shadow = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);
    canvas.drawCircle(center.translate(0, 6), radius + 4, shadow);

    // Лёгкая «подложка» под белым (чуть контраста на белой карте)
    final basePaint = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFFF0F2F4);
    canvas.drawCircle(center, radius + 2.5, basePaint);

    // Основной белый диск
    final fill = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFFFCFDFC);
    canvas.drawCircle(center, radius, fill);

    // Тонкая нейтральная обводка (не брендовый зелёный — меньше визуального шума)
    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFC5CCD4);
    canvas.drawCircle(center, radius - 1.25, rim);

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: emojiFontSize,
          height: 1.0,
          fontFamily: _emojiFontFamily(),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radius * 2);

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 1,
      ),
    );

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static String? _emojiFontFamily() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'Apple Color Emoji';
      default:
        return null;
    }
  }
}

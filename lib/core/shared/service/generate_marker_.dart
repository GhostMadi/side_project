import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Bitmap-маркеры для карты (Yandex MapKit): эмодзи в спокойном минималистичном круге.
class MarkerGeneratorService {
  static final Map<String, Uint8List> _cache = {};

  static const String _styleRevision = 'v8';

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

  static Future<Uint8List?> createPhotoMarkerFromUrl(
    String url, {
    bool compact = false,
    /// Бейдж «+N»: ещё посты без попадания в превью (одна карточка для нескольких постов).
    int mapPlusBadge = 0,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    final rev = compact ? '${_styleRevision}_c' : _styleRevision;
    final badge = mapPlusBadge < 0 ? 0 : mapPlusBadge;
    final cacheKey = 'photo_rect|$rev|$badge|$trimmed';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    ui.Image? decoded;
    try {
      decoded = await _loadNetworkImage(trimmed, maxDecodeSide: compact ? 140 : 384);
      final bytes = compact
          ? await _drawRectPhotoMarkerCompact(decoded, mapPlusBadge: badge)
          : await _drawRectPhotoMarker(decoded, mapPlusBadge: badge);
      _cache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Ошибка фото-маркера $url: $e');
    } finally {
      decoded?.dispose();
    }
    return null;
  }

  static void _paintMapCornerPlusBadge(ui.Canvas canvas, RRect photoRect, int plus, {required bool compact}) {
    if (plus <= 0) return;
    final label = plus > 99 ? '+99' : '+$plus';
    final ts = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: compact ? 18 : 21,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final padX = compact ? 7.0 : 9.0;
    final padY = compact ? 5.0 : 6.0;
    final br = Offset(photoRect.outerRect.right - 8, photoRect.outerRect.top + 8);
    final oval = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(br.dx - ts.width / 2 - padX, br.dy + ts.height / 2 + padY * 0.4),
        width: ts.width + padX * 2,
        height: ts.height + padY * 1.1,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(oval, Paint()..color = AppColors.primary.withValues(alpha: 0.93));
    ts.paint(canvas, Offset(oval.outerRect.left + padX * 0.85, oval.outerRect.top + padY * 0.45));
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

  static Future<Uint8List> _drawRectPhotoMarker(ui.Image src, {int mapPlusBadge = 0}) async {
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

    _paintMapCornerPlusBadge(canvas, cardRect, mapPlusBadge, compact: false);

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

  static Future<Uint8List> _drawRectPhotoMarkerCompact(ui.Image src, {int mapPlusBadge = 0}) async {
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
    _paintMapCornerPlusBadge(canvas, cardRect, mapPlusBadge, compact: true);
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

  static const _userMapLocationCacheKey = 'user_map_loc_rings_v1';

  /// Метка «моё положение»: кольца в [AppColors.primary] (как в типичных map UX).
  static Future<Uint8List> createMapUserLocationMarker() async {
    if (_cache.containsKey(_userMapLocationCacheKey)) {
      return _cache[_userMapLocationCacheKey]!;
    }
    const size = 280.0;
    final center = Offset(size / 2, size / 2);
    const primary = AppColors.primary;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Тень
    final shadow = Paint()
      ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(0, 4), 62, shadow);

    // Внешнее кольцо (полупрозрачный «радар»)
    final ringOuter = Paint()
      ..isAntiAlias = true
      ..color = primary.withValues(alpha: 0.2);
    canvas.drawCircle(center, 68, ringOuter);

    final ringMid = Paint()
      ..isAntiAlias = true
      ..color = primary.withValues(alpha: 0.42);
    canvas.drawCircle(center, 50, ringMid);

    // Белая подложка под ядром
    final white = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFFFCFDFC);
    canvas.drawCircle(center, 34, white);
    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFFC5CCD4);
    canvas.drawCircle(center, 33, rim);

    // Ядро — бренд
    final core = Paint()..isAntiAlias = true..color = primary;
    canvas.drawCircle(center, 18, core);

    // Блик
    final glint = Paint()..isAntiAlias = true..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(center.translate(-6, -6), 4.2, glint);

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    try {
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final out = byteData!.buffer.asUint8List();
      _cache[_userMapLocationCacheKey] = out;
      return out;
    } finally {
      img.dispose();
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

  /// Сетка превью 2–4 изображений + опционально бейдж «+N» (постов больше, чем клеток).
  static Future<Uint8List?> createMapMultiPostGridFromUrls(
    List<String> urls, {
    int overflowPlus = 0,
    bool compact = false,
  }) async {
    final cleaned = urls.map((e) => e.trim()).where((e) => e.isNotEmpty).take(4).toList();
    if (cleaned.length < 2) return null;

    final key = 'grid_${compact ? 'c' : 'f'}_${cleaned.length}_${overflowPlus}_${cleaned.join('|')}';
    if (_cache.containsKey(key)) return _cache[key];

    const outer = 284.0;
    const inset = 10.0;
    const radius = Radius.circular(12);

    final cells = await Future.wait(
      cleaned.map((u) => _loadNetworkImage(u, maxDecodeSide: compact ? 96 : 128)),
    );

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final bounds = Rect.fromLTWH(inset, inset, outer - 2 * inset, outer - 2 * inset);

      final shadow = Paint()
        ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds.shift(const Offset(0, 6)), Radius.circular(radius.x)),
        shadow,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(bounds, radius), Paint()..color = const Color(0xFFF7F9FB));
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, radius),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFE9EEF2),
      );

      final n = cleaned.length;

      void clipDraw(Rect r, int i) {
        final img = cells[i];
        canvas.save();
        canvas.clipPath(Path()..addRRect(RRect.fromRectAndCorners(r)));
        paintImage(canvas: canvas, rect: r, image: img, fit: BoxFit.cover, filterQuality: FilterQuality.low);
        canvas.restore();
      }

      if (n == 2) {
        final gap = 2.0;
        final half = (bounds.width - gap) / 2;
        clipDraw(Rect.fromLTWH(bounds.left, bounds.top, half, bounds.height), 0);
        clipDraw(Rect.fromLTWH(bounds.left + half + gap, bounds.top, half, bounds.height), 1);
      } else if (n == 3) {
        const gap = 2.0;
        final tw = bounds.width;
        final topH = (bounds.height - gap) * 0.5;
        final botH = bounds.height - topH - gap;
        final halfW = (tw - gap) / 2;
        clipDraw(Rect.fromLTWH(bounds.left, bounds.top, halfW, topH), 0);
        clipDraw(Rect.fromLTWH(bounds.left + halfW + gap, bounds.top, halfW, topH), 1);
        clipDraw(Rect.fromLTWH(bounds.left, bounds.top + topH + gap, tw, botH), 2);
      } else {
        const gap = 2.0;
        final hw = (bounds.width - gap) / 2;
        final hh = (bounds.height - gap) / 2;
        clipDraw(Rect.fromLTWH(bounds.left, bounds.top, hw, hh), 0);
        clipDraw(Rect.fromLTWH(bounds.left + hw + gap, bounds.top, hw, hh), 1);
        clipDraw(Rect.fromLTWH(bounds.left, bounds.top + hh + gap, hw, hh), 2);
        clipDraw(Rect.fromLTWH(bounds.left + hw + gap, bounds.top + hh + gap, hw, hh), 3);
      }

      if (overflowPlus > 0) {
        final label = overflowPlus > 99 ? '+99' : '+$overflowPlus';
        final ts = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final padH = compact ? 8.0 : 10.0;
        final padW = compact ? 10.0 : 12.0;
        final oval = RRect.fromRectAndRadius(
          Rect.fromLTWH(bounds.right - ts.width - padW * 2 - 10, bounds.top + 8, ts.width + padW * 2, ts.height + padH),
          const Radius.circular(999),
        );
        canvas.drawRRect(oval, Paint()..color = AppColors.primary.withValues(alpha: 0.95));
        ts.paint(canvas, Offset(oval.outerRect.left + padW * 0.85, oval.outerRect.top + padH * 0.4));
      }

      final outImg = await recorder.endRecording().toImage(outer.toInt(), outer.toInt());
      final byteData = await outImg.toByteData(format: ui.ImageByteFormat.png);
      outImg.dispose();
      for (final img in cells) {
        img.dispose();
      }
      final bytes = byteData!.buffer.asUint8List();
      _cache[key] = bytes;
      return bytes;
    } catch (e, st) {
      debugPrint('createMapMultiPostGridFromUrls err: $e $st');
      for (final img in cells) {
        img.dispose();
      }
      return null;
    }
  }

  static Future<Uint8List> _drawMarkerWithLinkedBadge(String emoji, int count) async {
    const double size = 280.0;
    const double radius = 84.0;
    const double emojiFontSize = 74.0;
    final center = Offset(size / 2, size / 2 - 6);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      center.translate(0, 6),
      radius + 4,
      Paint()
        ..color = const Color(0xFF1A1D1E).withValues(alpha: 0.17)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawCircle(center, radius + 2.5, Paint()..color = const Color(0xFFF0F2F4));
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFCFDFC));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFC5CCD4),
    );

    final tpEmoji = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: emojiFontSize, height: 1.0, fontFamily: _emojiFontFamily()),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 2);
    tpEmoji.paint(canvas, Offset(center.dx - tpEmoji.width / 2, center.dy - tpEmoji.height / 2 - 6));

    final lbl = count > 99 ? '99+' : '$count';
    final ct = TextPainter(
      text: TextSpan(
        text: lbl,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeR = math.max(ct.width, ct.height) / 2 + 11;
    // Бейдж частично снаружи белого круга (не «утоплен» внутрь диска).
    final outward = radius + badgeR * 0.38;
    final angle = math.pi * 0.28;
    final badgeCenter = Offset(
      center.dx + outward * math.cos(angle),
      center.dy + outward * math.sin(angle),
    );

    canvas.drawCircle(badgeCenter, badgeR + 1.5, Paint()..color = const Color(0x44000000));
    canvas.drawCircle(badgeCenter, badgeR, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      badgeCenter,
      badgeR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.92),
    );
    ct.paint(canvas, Offset(badgeCenter.dx - ct.width / 2, badgeCenter.dy - ct.height / 2));

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }

  /// Постов несколько / есть контент — но ни у одного превью-URL карта рисуем эмодзи + счётчик.
  static Future<Uint8List?> createEmojiMarkerWithLinkedPostCount(String emoji, {required int linkedPostCount}) async {
    if (linkedPostCount <= 1) return createEmojiMarker(emoji);
    final key = '${_styleRevision}_elc|$emoji|$linkedPostCount';
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final bytes = await _drawMarkerWithLinkedBadge(emoji, linkedPostCount);
      _cache[key] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('createEmojiMarkerWithLinkedPostCount: $e');
    }
    return createEmojiMarker(emoji);
  }

  /// Подпись **над** круглым bitmap (время/счётчик) — якорь карты остаётся в центре круга.
  static Future<({Uint8List bytes, double anchorY})> composePinTopFootLine({
    required Uint8List basePng,
    required String footLine,
  }) async {
    final t = footLine.trim();

    final codec = await ui.instantiateImageCodec(basePng);
    final frame = await codec.getNextFrame();
    final baseImg = frame.image;
    final w = baseImg.width.toDouble();
    final h = baseImg.height.toDouble();
    const topBand = 42.0;
    final totalH = h + topBand;

    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2C3136),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: w - 16);

    final pillW = (tp.width + 22).clamp(48.0, w - 8);
    final pillH = tp.height + 12;
    final pillLeft = (w - pillW) / 2;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillLeft, 6, pillW, pillH),
      const Radius.circular(999),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRRect(r, Paint()..color = const Color(0xFFFCFDFC));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFC5CCD4),
    );
    tp.paint(canvas, Offset(pillLeft + 11, 6 + 6));
    canvas.drawImage(baseImg, Offset(0, topBand), Paint());
    baseImg.dispose();

    final out = await recorder.endRecording().toImage(w.toInt(), totalH.toInt());
    final bd = await out.toByteData(format: ui.ImageByteFormat.png);
    out.dispose();
    final bytes = bd!.buffer.asUint8List();

    final centerY = (h / 2 - 4) + topBand;
    final anchorY = (centerY / totalH).clamp(0.08, 0.92);

    return (bytes: bytes, anchorY: anchorY);
  }
}

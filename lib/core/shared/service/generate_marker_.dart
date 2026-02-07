import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class MarkerGeneratorService {
  static final Map<String, Uint8List> _cache = {};

  static Future<Uint8List?> createEmojiMarker(String emoji) async {
    if (_cache.containsKey(emoji)) return _cache[emoji];

    try {
      final charCodes = emoji.runes.map((rune) => rune.toRadixString(16)).toList();
      final url = 'https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/${charCodes.join('-')}.svg';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Uint8List markerBytes = await _drawMarkerFromSvg(response.bodyBytes);
        _cache[emoji] = markerBytes;
        return markerBytes;
      }
    } catch (e) {
      debugPrint("Ошибка генерации маркера $emoji: $e");
    }
    return null;
  }

  static Future<Uint8List> _drawMarkerFromSvg(Uint8List svgBytes) async {
    // Твои параметры размера
    const double size = 500.0;
    const double radius = 160.0;
    const double emojiSize = 200.0;
    const double strokeWidth = 10.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    // 1. РИСУЕМ ТЕНЬ (для круга)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center.translate(0, 10), radius + strokeWidth, shadowPaint);

    // 2. КОРПУС МАРКЕРА (Черная обводка)
    final paint = Paint()..isAntiAlias = true;
    paint.color = Colors.black;
    canvas.drawCircle(center, radius + strokeWidth, paint);

    // 3. ВНУТРЕННИЙ ФОН (Белый круг)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // 4. РЕНДЕРИНГ SVG ЭМОДЗИ
    final PictureInfo pictureInfo = await vg.loadPicture(SvgBytesLoader(svgBytes), null);
    final double scale = emojiSize / math.max(pictureInfo.size.width, pictureInfo.size.height);

    canvas.save();
    canvas.translate(
      center.dx - (pictureInfo.size.width * scale) / 2,
      center.dy - (pictureInfo.size.height * scale) / 2,
    );
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();

    pictureInfo.picture.dispose();

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

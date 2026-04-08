import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:side_project/core/shared/ig_edit/ig_edit_models.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_presets.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_style_matrix.dart';

/// Полный пайплайн: тени/света → экспозиция/яркость/контраст/насыщенность → тепло → резкость.
Uint8List bakePostImageEdit(Uint8List bytes, PostImageEditParams p) {
  if (p.isNeutral) {
    return bytes;
  }
  final style = p.styleFilter;
  final w = mergeStylePresetIntoUser(p);
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return bytes;
  }
  final out = decoded.clone();
  _applyShadowsAndHighlights(out, w.shadows, w.highlights);
  img.adjustColor(
    out,
    exposure: (w.exposure * 0.85).clamp(-2.5, 2.5),
    brightness: (1.0 + w.brightness * 0.38).clamp(0.15, 2.8),
    contrast: (1.0 + w.contrast * 0.52).clamp(0.05, 1.98),
    saturation: (1.0 + w.saturation * 0.62).clamp(0.0, 2.6),
  );
  _applyWarmth(out, w.warmth);
  _applySharpen(out, w.sharpness);
  _applyColorMatrix4x5(out, postStylePostProcessMatrix4x5(style));
  return Uint8List.fromList(img.encodeJpg(out, quality: 92));
}

/// Превью в редакторе: при нейтральных слайдерах без изменений (полное качество).
/// С коррекцией — даунскейл по длинной стороне и JPEG.
Uint8List bakePostImageEditPreview(
  Uint8List bytes,
  PostImageEditParams p, {
  int maxSide = 1600,
  int jpegQuality = 92,
  bool skipSharpen = false,
  img.Interpolation resizeInterpolation = img.Interpolation.cubic,
}) {
  if (p.isNeutral) {
    return bytes;
  }
  final style = p.styleFilter;
  final w = mergeStylePresetIntoUser(p);
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return bytes;
  }
  final small = _resizeLongestSide(decoded.clone(), maxSide, interpolation: resizeInterpolation);
  _applyShadowsAndHighlights(small, w.shadows, w.highlights);
  img.adjustColor(
    small,
    exposure: (w.exposure * 0.85).clamp(-2.5, 2.5),
    brightness: (1.0 + w.brightness * 0.38).clamp(0.15, 2.8),
    contrast: (1.0 + w.contrast * 0.52).clamp(0.05, 1.98),
    saturation: (1.0 + w.saturation * 0.62).clamp(0.0, 2.6),
  );
  _applyWarmth(small, w.warmth);
  if (!skipSharpen) {
    _applySharpen(small, w.sharpness);
  }
  _applyColorMatrix4x5(small, postStylePostProcessMatrix4x5(style));
  return Uint8List.fromList(img.encodeJpg(small, quality: jpegQuality));
}

void _applyColorMatrix4x5(img.Image image, List<double> m) {
  assert(m.length == 20);
  for (final frame in image.frames) {
    for (final p in frame) {
      final r = p.rNormalized;
      final g = p.gNormalized;
      final b = p.bNormalized;
      final a = p.aNormalized;
      final r2 = m[0] * r + m[1] * g + m[2] * b + m[3] * a + m[4];
      final g2 = m[5] * r + m[6] * g + m[7] * b + m[8] * a + m[9];
      final b2 = m[10] * r + m[11] * g + m[12] * b + m[13] * a + m[14];
      final a2 = m[15] * r + m[16] * g + m[17] * b + m[18] * a + m[19];
      p
        ..rNormalized = r2.clamp(0.0, 1.0)
        ..gNormalized = g2.clamp(0.0, 1.0)
        ..bNormalized = b2.clamp(0.0, 1.0)
        ..aNormalized = a2.clamp(0.0, 1.0);
    }
  }
}

img.Image _resizeLongestSide(
  img.Image src,
  int maxSide, {
  img.Interpolation interpolation = img.Interpolation.cubic,
}) {
  final w = src.width;
  final h = src.height;
  final long = math.max(w, h);
  if (long <= maxSide) {
    return src;
  }
  final scale = maxSide / long;
  final nw = (w * scale).round();
  final nh = (h * scale).round();
  return img.copyResize(src, width: nw, height: nh, interpolation: interpolation);
}

void _applyShadowsAndHighlights(img.Image image, double shadows, double highlights) {
  if (shadows == 0 && highlights == 0) {
    return;
  }
  final sClamped = shadows.clamp(-1.0, 1.0);
  final hClamped = highlights.clamp(-1.0, 1.0);
  for (final frame in image.frames) {
    for (final p in frame) {
      var r = p.rNormalized;
      var g = p.gNormalized;
      var b = p.bNormalized;
      final lum = 0.299 * r + 0.587 * g + 0.114 * b;

      if (shadows != 0) {
        final s = sClamped;
        if (s > 0) {
          final lift = s * 0.42 * math.pow(1 - lum, 1.75);
          r = (r + lift).clamp(0.0, 1.0);
          g = (g + lift).clamp(0.0, 1.0);
          b = (b + lift).clamp(0.0, 1.0);
        } else {
          final crush = (-s) * 0.28 * math.pow(1 - lum, 1.3);
          r = (r * (1 - crush)).clamp(0.0, 1.0);
          g = (g * (1 - crush)).clamp(0.0, 1.0);
          b = (b * (1 - crush)).clamp(0.0, 1.0);
        }
      }

      if (highlights != 0) {
        final h = hClamped;
        final t = lum;
        if (h > 0) {
          final damp = h * 0.45 * (t * t);
          r = (r * (1 - damp)).clamp(0.0, 1.0);
          g = (g * (1 - damp)).clamp(0.0, 1.0);
          b = (b * (1 - damp)).clamp(0.0, 1.0);
        } else {
          final lift = (-h) * 0.3 * (t * t);
          r = (r + lift).clamp(0.0, 1.0);
          g = (g + lift).clamp(0.0, 1.0);
          b = (b + lift).clamp(0.0, 1.0);
        }
      }

      p
        ..rNormalized = r
        ..gNormalized = g
        ..bNormalized = b;
    }
  }
}

void _applyWarmth(img.Image image, double warmth) {
  final w = warmth.clamp(-1.0, 1.0);
  if (w == 0) {
    return;
  }
  final wr = 1.0 + w * 0.14;
  final wb = 1.0 - w * 0.14;
  for (final frame in image.frames) {
    for (final p in frame) {
      p
        ..rNormalized = (p.rNormalized * wr).clamp(0.0, 1.0)
        ..bNormalized = (p.bNormalized * wb).clamp(0.0, 1.0);
    }
  }
}

void _applySharpen(img.Image image, double sharpness) {
  final s = sharpness.clamp(0.0, 1.0);
  if (s <= 0.001) {
    return;
  }
  final k = s * 0.55;
  img.convolution(
    image,
    filter: <num>[
      0, -k, 0,
      -k, 1 + 4 * k, -k,
      0, -k, 0,
    ],
    div: 1,
    offset: 0,
    amount: 1,
  );
}


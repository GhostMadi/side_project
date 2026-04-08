import 'dart:io';

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_presets.dart';
import 'package:side_project/core/shared/ig_edit/ig_edit_style_matrix.dart';
import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';

/// Превью коррекции на **GPU**: одна матрица [ColorFiltered] вместо цепочки фильтров.
///
/// **Резкость** в превью — лёгкая имитация (микроконтраст), чтобы не гонять CPU/isolate.
/// Точная резкость — в [bakePostImageEdit] при публикации.
List<double> _identity4x5() => <double>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];

/// Расширение 4×5 (Flutter [ColorFilter.matrix]) до однородной 5×5, строка-major.
List<double> _extend4x5To5x5(List<double> m) {
  assert(m.length == 20);
  return <double>[
    m[0],
    m[1],
    m[2],
    m[3],
    m[4],
    m[5],
    m[6],
    m[7],
    m[8],
    m[9],
    m[10],
    m[11],
    m[12],
    m[13],
    m[14],
    m[15],
    m[16],
    m[17],
    m[18],
    m[19],
    0,
    0,
    0,
    0,
    1,
  ];
}

List<double> _flatten5x5Top4(List<double> m) {
  assert(m.length == 25);
  return List<double>.from(m.sublist(0, 20));
}

List<double> _multiply5x5(List<double> a, List<double> b) {
  assert(a.length == 25 && b.length == 25);
  final out = List<double>.filled(25, 0);
  for (var i = 0; i < 5; i++) {
    for (var j = 0; j < 5; j++) {
      var s = 0.0;
      for (var k = 0; k < 5; k++) {
        s += a[i * 5 + k] * b[k * 5 + j];
      }
      out[i * 5 + j] = s;
    }
  }
  return out;
}

/// Одна 4×5 матрица: слайдеры + пресет ([mergeStylePresetIntoUser]) + пост-матрица (тинт / teal-orange / виньетка).
List<double> postEditCombinedColorMatrix(PostImageEditParams params) {
  final style = params.styleFilter;
  final merged = mergeStylePresetIntoUser(params);

  if (merged.isNeutral && style == PostStyleFilter.none) {
    return _identity4x5();
  }

  final exp = (merged.exposure * 0.85).clamp(-1.0, 1.0);
  final exposureScale = (1.0 + exp * 0.42).clamp(0.35, 2.2);
  final brightMul = (1.0 + merged.brightness * 0.38).clamp(0.2, 2.8);
  final scale = exposureScale * brightMul;

  var acc = _extend4x5To5x5(_saturationMatrix(merged.saturation));
  acc = _multiply5x5(_extend4x5To5x5(_contrastMatrix(merged.contrast)), acc);
  acc = _multiply5x5(_extend4x5To5x5(_rgbScaleMatrix(scale)), acc);
  acc = _multiply5x5(_extend4x5To5x5(_warmthMatrix(merged.warmth)), acc);
  acc = _multiply5x5(_extend4x5To5x5(_shadowHighlightMatrix(merged.shadows, merged.highlights)), acc);
  acc = _multiply5x5(_extend4x5To5x5(_pseudoSharpnessMatrix(merged.sharpness)), acc);

  acc = _multiply5x5(_extend4x5To5x5(postStylePostProcessMatrix4x5(style)), acc);

  return _flatten5x5Top4(acc);
}

class PostEditGpuPreview extends StatefulWidget {
  const PostEditGpuPreview({
    super.key,
    required this.file,
    required this.params,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.low,
  });

  final File file;
  final PostImageEditParams params;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  State<PostEditGpuPreview> createState() => _PostEditGpuPreviewState();
}

class _PostEditGpuPreviewState extends State<PostEditGpuPreview> {
  List<double>? _matrix;

  @override
  void initState() {
    super.initState();
    _syncMatrixFromParams();
  }

  @override
  void didUpdateWidget(covariant PostEditGpuPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.params != widget.params) {
      _syncMatrixFromParams();
    }
  }

  void _syncMatrixFromParams() {
    if (widget.params.isNeutral) {
      _matrix = null;
    } else {
      _matrix = postEditCombinedColorMatrix(widget.params);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final decodeW = (mq.size.width * mq.devicePixelRatio).round().clamp(480, 1400);

    if (widget.params.isNeutral) {
      return Image.file(
        widget.file,
        fit: widget.fit,
        filterQuality: widget.filterQuality,
        isAntiAlias: true,
        cacheWidth: decodeW,
        gaplessPlayback: true,
      );
    }

    final matrix = _matrix ?? postEditCombinedColorMatrix(widget.params);
    return RepaintBoundary(
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: Image.file(
          widget.file,
          fit: widget.fit,
          filterQuality: widget.filterQuality,
          isAntiAlias: true,
          gaplessPlayback: true,
          cacheWidth: decodeW,
        ),
      ),
    );
  }
}

/// Миниатюра в ленте пресетов: тот же [postEditCombinedColorMatrix], что и основное превью.
///
/// [baseParams] — текущие слайдеры; для плитки подставляется только [chipStyle], чтобы видеть
/// каждый пресет при тех же ручных правках.
class PostStyleFilterThumbnail extends StatelessWidget {
  const PostStyleFilterThumbnail({
    super.key,
    required this.file,
    required this.baseParams,
    required this.chipStyle,
    this.side = 54,
  });

  final File file;
  final PostImageEditParams baseParams;
  final PostStyleFilter chipStyle;
  final double side;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (side * dpr).round().clamp(72, 220);

    final params = baseParams.copyWith(styleFilter: chipStyle);
    final showFilter = !params.isNeutral;

    Widget img = Image.file(
      file,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      isAntiAlias: true,
      cacheWidth: cacheW,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: AppColors.surfaceMuted,
        child: Icon(Icons.broken_image_outlined, color: AppColors.iconMuted, size: side * 0.4),
      ),
    );

    if (showFilter) {
      img = ColorFiltered(colorFilter: ColorFilter.matrix(postEditCombinedColorMatrix(params)), child: img);
    }

    return SizedBox(width: side, height: side, child: img);
  }
}

List<double> _saturationMatrix(double saturationSlider) {
  final s = (1.0 + saturationSlider * 0.62).clamp(0.0, 2.6);
  const lr = 0.2126;
  const lg = 0.7152;
  const lb = 0.0722;
  final inv = 1.0 - s;
  return <double>[
    lr * inv + s,
    lg * inv,
    lb * inv,
    0,
    0,
    lr * inv,
    lg * inv + s,
    lb * inv,
    0,
    0,
    lr * inv,
    lg * inv,
    lb * inv + s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _contrastMatrix(double contrastSlider) {
  final c = (1.0 + contrastSlider * 0.52).clamp(0.2, 1.95);
  final t = 0.5 * (1.0 - c);
  return <double>[c, 0, 0, 0, t, 0, c, 0, 0, t, 0, 0, c, 0, t, 0, 0, 0, 1, 0];
}

List<double> _rgbScaleMatrix(double scale) => <double>[
  scale,
  0,
  0,
  0,
  0,
  0,
  scale,
  0,
  0,
  0,
  0,
  0,
  scale,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

List<double> _warmthMatrix(double warmth) {
  final w = warmth.clamp(-1.0, 1.0);
  if (w == 0) {
    return _identity4x5();
  }
  final wr = 1.0 + w * 0.14;
  final wb = 1.0 - w * 0.14;
  return <double>[wr, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, wb, 0, 0, 0, 0, 0, 1, 0];
}

/// Визуально «подтягивает» середину тонов — плавно и без свёртки.
List<double> _pseudoSharpnessMatrix(double sharpness) {
  final s = sharpness.clamp(0.0, 1.0);
  if (s <= 0.001) {
    return _identity4x5();
  }
  final c = 1.0 + s * 0.16;
  final t = 0.5 * (1.0 - c);
  return <double>[c, 0, 0, 0, t, 0, c, 0, 0, t, 0, 0, c, 0, t, 0, 0, 0, 1, 0];
}

List<double> _shadowHighlightMatrix(double shadows, double highlights) {
  final sh = shadows.clamp(-1.0, 1.0);
  final hi = highlights.clamp(-1.0, 1.0);
  if (sh == 0 && hi == 0) {
    return _identity4x5();
  }
  final lift = sh > 0 ? sh * 0.08 : sh * 0.04;
  final hiScale = hi > 0 ? 1.0 - hi * 0.12 : 1.0 + (-hi) * 0.06;
  final bias = lift + (hi < 0 ? (-hi) * 0.04 : 0.0);
  return <double>[hiScale, 0, 0, 0, bias, 0, hiScale, 0, 0, bias, 0, 0, hiScale, 0, bias, 0, 0, 0, 1, 0];
}

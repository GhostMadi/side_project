import 'package:side_project/core/shared/ig_edit/ig_edit_models.dart';

/// Дельты пресета в шкале слайдеров: контраст/тени/света/температура из таблицы ÷100;
/// экспозиция — как в таблице (−1…1); vibrance частично в [saturation].
PostImageEditParams stylePresetDelta(PostStyleFilter f) {
  return switch (f) {
    PostStyleFilter.none => const PostImageEditParams(),
    PostStyleFilter.goldenInstagram => const PostImageEditParams(
        exposure: 0.30,
        contrast: 0.20,
        highlights: 0.40,
        shadows: 0.30,
        warmth: 0.12,
        saturation: 0.35,
      ),
    PostStyleFilter.moodyDark => const PostImageEditParams(
        exposure: -0.40,
        contrast: 0.30,
        highlights: 0.50,
        shadows: -0.28,
        warmth: -0.05,
        saturation: -0.15,
        sharpness: 0.14,
      ),
    PostStyleFilter.vintageFilm => const PostImageEditParams(
        exposure: 0.20,
        contrast: -0.10,
        highlights: 0.30,
        shadows: 0.25,
        warmth: 0.08,
        saturation: -0.05,
        brightness: 0.06,
      ),
    PostStyleFilter.brightAiry => const PostImageEditParams(
        exposure: 0.60,
        contrast: -0.10,
        highlights: 0.40,
        shadows: 0.45,
        brightness: 0.10,
        warmth: 0.04,
        saturation: -0.05,
      ),
    PostStyleFilter.tealOrange => const PostImageEditParams(
        contrast: 0.25,
        highlights: 0.35,
        shadows: 0.10,
        warmth: 0.08,
        saturation: 0.10,
      ),
    PostStyleFilter.cinematicDark => const PostImageEditParams(
        exposure: -0.20,
        contrast: 0.40,
        highlights: 0.60,
        shadows: -0.22,
        saturation: -0.10,
        sharpness: 0.18,
        brightness: -0.06,
      ),
    PostStyleFilter.softPortrait => const PostImageEditParams(
        exposure: 0.40,
        contrast: -0.08,
        highlights: 0.35,
        shadows: 0.30,
        warmth: 0.06,
        saturation: -0.05,
      ),
    PostStyleFilter.travelBoost => const PostImageEditParams(
        exposure: 0.20,
        contrast: 0.24,
        highlights: 0.30,
        shadows: 0.20,
        saturation: 0.45,
        sharpness: 0.14,
      ),
    PostStyleFilter.urbanStreet => const PostImageEditParams(
        exposure: -0.10,
        contrast: 0.41,
        highlights: 0.40,
        shadows: -0.05,
        saturation: -0.20,
        sharpness: 0.20,
      ),
    PostStyleFilter.cleanPro => const PostImageEditParams(
        exposure: 0.10,
        contrast: 0.15,
        highlights: 0.20,
        shadows: 0.15,
        brightness: 0.04,
        saturation: 0.12,
      ),
  };
}

/// Доп. резкость (мягкий портрет — texture/clarity в минус).
double stylePresetSharpnessDelta(PostStyleFilter f) {
  return switch (f) {
    PostStyleFilter.softPortrait => -0.12,
    _ => 0.0,
  };
}

/// Сумма пользовательских правок и пресета; [styleFilter] сбрасывается.
PostImageEditParams mergeStylePresetIntoUser(PostImageEditParams u) {
  if (u.styleFilter == PostStyleFilter.none) {
    return u;
  }
  final d = stylePresetDelta(u.styleFilter);
  final sd = stylePresetSharpnessDelta(u.styleFilter);
  return PostImageEditParams(
    exposure: (u.exposure + d.exposure).clamp(-1.0, 1.0),
    brightness: (u.brightness + d.brightness).clamp(-1.0, 1.0),
    contrast: (u.contrast + d.contrast).clamp(-1.0, 1.0),
    saturation: (u.saturation + d.saturation).clamp(-1.0, 1.0),
    warmth: (u.warmth + d.warmth).clamp(-1.0, 1.0),
    shadows: (u.shadows + d.shadows).clamp(-1.0, 1.0),
    highlights: (u.highlights + d.highlights).clamp(-1.0, 1.0),
    sharpness: (u.sharpness + d.sharpness + sd).clamp(0.0, 1.0),
    styleFilter: PostStyleFilter.none,
  );
}


import 'dart:io';

/// Готовые стили поверх ручных коррекций (как пресеты в сторис).
enum PostStyleFilter {
  none,
  goldenInstagram,
  moodyDark,
  vintageFilm,
  brightAiry,
  tealOrange,
  cinematicDark,
  softPortrait,
  travelBoost,
  urbanStreet,
  cleanPro,
}

extension PostStyleFilterUi on PostStyleFilter {
  String get label => switch (this) {
        PostStyleFilter.none => 'Оригинал',
        PostStyleFilter.goldenInstagram => 'Golden ☀️',
        PostStyleFilter.moodyDark => 'Moody 🌑',
        PostStyleFilter.vintageFilm => 'Vintage 🎞',
        PostStyleFilter.brightAiry => 'Airy ☁️',
        PostStyleFilter.tealOrange => 'Teal&O 🎬',
        PostStyleFilter.cinematicDark => 'Cine 🎥',
        PostStyleFilter.softPortrait => 'Portrait 👤',
        PostStyleFilter.travelBoost => 'Travel 🌍',
        PostStyleFilter.urbanStreet => 'Street 🏙',
        PostStyleFilter.cleanPro => 'Clean 📷',
      };

  String get hint => switch (this) {
        PostStyleFilter.none => 'Без пресета',
        PostStyleFilter.goldenInstagram => 'Тёплый инстаграм',
        PostStyleFilter.moodyDark => 'Тёмный атмосферный',
        PostStyleFilter.vintageFilm => 'Плёнка, ретро',
        PostStyleFilter.brightAiry => 'Светлый блогерский',
        PostStyleFilter.tealOrange => 'Киношный teal & orange',
        PostStyleFilter.cinematicDark => 'Глубокий кино-контраст',
        PostStyleFilter.softPortrait => 'Мягко для лиц',
        PostStyleFilter.travelBoost => 'Природа и путешествия',
        PostStyleFilter.urbanStreet => 'Стрит',
        PostStyleFilter.cleanPro => 'Нейтральный про-стиль',
      };
}

/// Выбранный файл из галереи (любое соотношение сторон).
///
/// [originalFile] — исходник с устройства; экран обрезки всегда открывается с ним.
/// [displayFile] — то, что видит пользователь (после обрезки и т.д.); цветокор считается с него.
class PostCreateSlot {
  PostCreateSlot({required this.originalFile, File? displayFile, required this.isVideo})
      : displayFile = displayFile ?? originalFile;

  /// Полный файл с галереи — не перезаписывается при повторной обрезке.
  final File originalFile;

  /// Текущая версия для UI и пайплайна редактирования.
  final File displayFile;

  final bool isVideo;

  PostCreateSlot copyWithDisplay(File newDisplay) =>
      PostCreateSlot(originalFile: originalFile, displayFile: newDisplay, isVideo: isVideo);
}

/// Параметры цветокора и резкости для одного кадра (фото). Для видео не используется.
class PostImageEditParams {
  const PostImageEditParams({
    this.exposure = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.warmth = 0,
    this.shadows = 0,
    this.highlights = 0,
    this.sharpness = 0,
    this.styleFilter = PostStyleFilter.none,
  });

  /// Слайдеры в диапазоне примерно [-1, 1], кроме резкости [0, 1].
  final double exposure;
  final double brightness;
  final double contrast;
  final double saturation;
  final double warmth;
  final double shadows;
  final double highlights;
  final double sharpness;
  final PostStyleFilter styleFilter;

  bool get isNeutral =>
      styleFilter == PostStyleFilter.none &&
      exposure == 0 &&
      brightness == 0 &&
      contrast == 0 &&
      saturation == 0 &&
      warmth == 0 &&
      shadows == 0 &&
      highlights == 0 &&
      sharpness == 0;

  PostImageEditParams copyWith({
    double? exposure,
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
    double? shadows,
    double? highlights,
    double? sharpness,
    PostStyleFilter? styleFilter,
  }) {
    return PostImageEditParams(
      exposure: exposure ?? this.exposure,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      warmth: warmth ?? this.warmth,
      shadows: shadows ?? this.shadows,
      highlights: highlights ?? this.highlights,
      sharpness: sharpness ?? this.sharpness,
      styleFilter: styleFilter ?? this.styleFilter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostImageEditParams &&
          runtimeType == other.runtimeType &&
          exposure == other.exposure &&
          brightness == other.brightness &&
          contrast == other.contrast &&
          saturation == other.saturation &&
          warmth == other.warmth &&
          shadows == other.shadows &&
          highlights == other.highlights &&
          sharpness == other.sharpness &&
          styleFilter == other.styleFilter;

  @override
  int get hashCode => Object.hash(
        exposure,
        brightness,
        contrast,
        saturation,
        warmth,
        shadows,
        highlights,
        sharpness,
        styleFilter,
      );
}


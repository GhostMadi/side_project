/// Пресеты соотношения сторон для кадрирования (как в редакторе поста).
enum MediaAspectPreset { ratio9x16, ratio1x1, ratio3x4, ratio16x9 }

extension MediaAspectPresetX on MediaAspectPreset {
  String get label => switch (this) {
    MediaAspectPreset.ratio9x16 => '9:16',
    MediaAspectPreset.ratio1x1 => '1:1',
    MediaAspectPreset.ratio3x4 => '3:4',
    MediaAspectPreset.ratio16x9 => '16:9',
  };

  /// Кодируется в имя файла: `__ar-<aspect>`.
  String get fileAspect => switch (this) {
    MediaAspectPreset.ratio9x16 => '9x16',
    MediaAspectPreset.ratio1x1 => '1x1',
    MediaAspectPreset.ratio3x4 => '3x4',
    MediaAspectPreset.ratio16x9 => '16x9',
  };

  double get aspectRatio => switch (this) {
    MediaAspectPreset.ratio9x16 => 9 / 16,
    MediaAspectPreset.ratio1x1 => 1.0,
    MediaAspectPreset.ratio3x4 => 3 / 4,
    MediaAspectPreset.ratio16x9 => 16 / 9,
  };
}

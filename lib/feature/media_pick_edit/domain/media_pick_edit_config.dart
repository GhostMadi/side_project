import 'package:side_project/feature/media_pick_edit/domain/media_aspect_preset.dart';

/// Настройки переиспользуемого потока «галерея → правки → (опционально свой шаг)».
///
/// [cropPresets] — какие форматы показывать при инструменте «Кадр»; порядок = порядок чипов.
/// Пустой список недопустим — при нормализации подставляется [MediaAspectPreset.values].
class MediaPickEditConfig {
  const MediaPickEditConfig({
    this.maxSelection = 10,
    this.allowVideo = true,
    this.cropPresets = MediaAspectPreset.values,
  });

  /// Максимум выбранных медиа на шаге галереи.
  final int maxSelection;

  /// Разрешить выбор видео (иначе только фото).
  final bool allowVideo;

  /// Доступные пресеты кадра на шаге редактирования.
  final List<MediaAspectPreset> cropPresets;

  /// Конфиг по умолчанию для создания поста (пока только фото — без видео).
  static const MediaPickEditConfig postDefault = MediaPickEditConfig(allowVideo: false);

  /// Нормализованный список пресетов (не пустой).
  List<MediaAspectPreset> get resolvedCropPresets =>
      cropPresets.isEmpty ? MediaAspectPreset.values : cropPresets;
}

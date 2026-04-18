import 'dart:typed_data';

import 'package:side_project/feature/post_create_page/presentation/page/post_create_models.dart';

/// Результат после шагов выбора и редактирования медиа (перед произвольным третьим шагом или публикацией).
class MediaPickEditOutcome {
  const MediaPickEditOutcome({
    required this.slots,
    required this.editParams,
    required this.bakedImageBytes,
  });

  final List<PostCreateSlot> slots;

  /// Параметры цветокоррекции по каждому слоту (для изображений; для видео без изменений).
  final List<PostImageEditParams> editParams;

  /// Запечённые JPEG для каждого слота; `null` для видео или при ошибке запекания.
  final List<Uint8List?> bakedImageBytes;
}

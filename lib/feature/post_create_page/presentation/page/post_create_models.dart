import 'dart:io';

export 'package:side_project/core/shared/ig_edit/ig_edit_models.dart'
    show PostImageEditParams, PostStyleFilter, PostStyleFilterUi;

/// Выбранный файл из галереи (любое соотношение сторон).
///
/// [originalFile] — исходник с устройства; экран обрезки всегда открывается с ним.
/// [displayFile] — то, что видит пользователь (после обрезки и т.д.); цветокор считается с него.
class PostCreateSlot {
  PostCreateSlot({
    required this.originalFile,
    File? displayFile,
    required this.isVideo,
    this.aspect = '1x1',
  }) : displayFile = displayFile ?? originalFile;

  /// Полный файл с галереи — не перезаписывается при повторной обрезке.
  final File originalFile;

  /// Текущая версия для UI и пайплайна редактирования.
  final File displayFile;

  final bool isVideo;

  /// Encoded into storage name as `__ar-<aspect>` (e.g. `1x1`, `9x16`).
  final String aspect;

  PostCreateSlot copyWithDisplay(File newDisplay) =>
      PostCreateSlot(originalFile: originalFile, displayFile: newDisplay, isVideo: isVideo, aspect: aspect);

  PostCreateSlot copyWithAspect(String newAspect) => PostCreateSlot(
        originalFile: originalFile,
        displayFile: displayFile,
        isVideo: isVideo,
        aspect: newAspect,
      );
}

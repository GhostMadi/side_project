import 'dart:io';
import 'dart:typed_data';

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
    this.videoPosterJpeg,
  }) : displayFile = displayFile ?? originalFile;

  /// Полный файл с галереи — не перезаписывается при повторной обрезке.
  final File originalFile;

  /// Текущая версия для UI и пайплайна редактирования.
  final File displayFile;

  final bool isVideo;

  /// Encoded into storage name as `__ar-<aspect>` (e.g. `1x1`, `9x16`).
  final String aspect;

  /// User-selected JPEG cover for video (feed thumbnail); null until chosen or baked default.
  final Uint8List? videoPosterJpeg;

  PostCreateSlot copyWithDisplay(File newDisplay) => PostCreateSlot(
        originalFile: originalFile,
        displayFile: newDisplay,
        isVideo: isVideo,
        aspect: aspect,
        videoPosterJpeg: videoPosterJpeg,
      );

  PostCreateSlot copyWithAspect(String newAspect) => PostCreateSlot(
        originalFile: originalFile,
        displayFile: displayFile,
        isVideo: isVideo,
        aspect: newAspect,
        videoPosterJpeg: videoPosterJpeg,
      );

  PostCreateSlot copyWithVideoPoster(Uint8List? poster) => PostCreateSlot(
        originalFile: originalFile,
        displayFile: displayFile,
        isVideo: isVideo,
        aspect: aspect,
        videoPosterJpeg: poster,
      );
}

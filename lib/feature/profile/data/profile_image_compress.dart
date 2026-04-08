import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Лимит как у бакетов Storage (`file_size_limit` = 10 MiB).
const int kProfileImageMaxBytes = 10485760;

/// Если [bytes] больше [maxBytes], снижаем качество и размер до тех пор, пока не уложимся в лимит.
/// Вызывать с основного изолята (ограничение `flutter_image_compress`).
Future<Uint8List> compressProfileImageToMaxBytes(
  Uint8List bytes, {
  int maxBytes = kProfileImageMaxBytes,
}) async {
  if (bytes.length <= maxBytes) return bytes;

  var quality = 88;
  var minSide = 2400;
  var current = bytes;

  for (var round = 0; round < 28; round++) {
    final next = await FlutterImageCompress.compressWithList(
      current,
      quality: quality,
      minWidth: minSide,
      minHeight: minSide,
      format: CompressFormat.jpeg,
    );
    if (next.length <= maxBytes) return next;
    current = next;
    if (quality > 42) {
      quality -= 6;
    } else if (minSide > 640) {
      minSide = (minSide * 0.82).round();
      quality = (quality - 4).clamp(28, 88);
    } else {
      break;
    }
  }

  if (current.length <= maxBytes) return current;

  throw const ProfileImageTooLargeException();
}

/// Не удалось уложить файл в [kProfileImageMaxBytes] после сжатия.
class ProfileImageTooLargeException implements Exception {
  const ProfileImageTooLargeException();

  @override
  String toString() =>
      'Не удалось сжать изображение до 10 МБ. Выберите другое фото или уменьшите разрешение.';
}

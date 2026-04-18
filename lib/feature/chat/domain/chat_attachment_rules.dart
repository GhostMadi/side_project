/// Client-side rules for chat albums / file messages (aligned with Storage bucket + product).
abstract final class ChatAttachmentRules {
  static const int maxCount = 10;
  static const int maxBytesPerFile = 10 * 1024 * 1024; // 10 MB

  static const Set<String> imageMimes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'image/heic',
  };

  static const Set<String> otherMimes = {
    'application/pdf',
    'application/octet-stream',
    'video/mp4',
    'video/quicktime',
    'audio/mpeg',
    'audio/mp4',
    'audio/mp3',
    'audio/aac',
    'audio/x-m4a',
    'audio/wav',
    'audio/webm',
    'audio/ogg',
    'audio/flac',
  };

  static bool isImageMime(String? m) {
    final v = m?.toLowerCase().trim();
    if (v == null || v.isEmpty) return false;
    return imageMimes.contains(v);
  }

  static bool isAllowedMime(String? m) {
    final v = m?.toLowerCase().trim();
    if (v == null || v.isEmpty) return false;
    return imageMimes.contains(v) || otherMimes.contains(v);
  }

  /// Только фото → `kind=media`; есть документы/видео → `kind=file` (альбом как «смешанное» сообщение).
  static String rpcKindForMimes(List<String> mimes) {
    final resolved = mimes.map((e) => e.toLowerCase().trim()).where((e) => e.isNotEmpty).toList();
    if (resolved.isEmpty) return 'file';
    return resolved.every(isImageMime) ? 'media' : 'file';
  }

  /// Если `mime` неизвестен — пробуем по имени файла; иначе `application/octet-stream`.
  static String inferMime(String filename, String? mimeFromPicker) {
    final trimmed = mimeFromPicker?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed.toLowerCase();

    final dot = filename.lastIndexOf('.');
    if (dot <= 0 || dot >= filename.length - 1) return 'application/octet-stream';
    final ext = filename.substring(dot + 1).toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
      case 'qt':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
      case 'aac':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
      case 'oga':
        return 'audio/ogg';
      case 'flac':
        return 'audio/flac';
      default:
        return 'application/octet-stream';
    }
  }

  static String? validateByteSize(int bytes) {
    if (bytes <= 0) return 'Файл пустой';
    if (bytes > maxBytesPerFile) {
      return 'Максимум ${maxBytesPerFile ~/ (1024 * 1024)} МБ на файл';
    }
    return null;
  }
}

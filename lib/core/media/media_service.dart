/// Разбор URL медиа без HTTP: только путь (`Instagram-style`).
abstract final class MediaService {
  MediaService._();

  static String _pathLower(String url) {
    final t = url.trim();
    if (t.isEmpty) return '';
    final uri = Uri.tryParse(t);
    if (uri == null) return t.toLowerCase();
    return uri.path.toLowerCase();
  }

  /// Ролик по расширению пути (query не мешает).
  static bool isVideo(String url) {
    final p = _pathLower(url);
    return p.endsWith('.mp4') ||
        p.endsWith('.mov') ||
        p.endsWith('.m4v') ||
        p.endsWith('.webm');
  }

  static bool isImage(String url) {
    final p = _pathLower(url);
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif') ||
        p.endsWith('__poster.jpg');
  }

  /// JPEG постера рядом с видео в Storage: `{stem}__poster.jpg`.
  /// Поддержка `{uuid}.{ext}` и legacy `{uuid}__ar-preset.{ext}`.
  static String? videoPosterUrl(String videoPublicUrl) {
    final trimmed = videoPublicUrl.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    final path = uri.path;
    final slash = path.lastIndexOf('/');
    if (slash < 0 || slash >= path.length - 1) return null;
    final file = path.substring(slash + 1);
    final lower = file.toLowerCase();
    if (lower.endsWith('__poster.jpg')) return trimmed;

    final uuidHead = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
      caseSensitive: false,
    );
    if (file.contains('__')) {
      final head = file.split('__').first;
      if (uuidHead.hasMatch(head)) {
        final posterFile = '${head}__poster.jpg';
        final newPath = '${path.substring(0, slash + 1)}$posterFile';
        return uri.replace(path: newPath).toString();
      }
    }

    final basePath = path.replaceAll(RegExp(r'\.[^/.]+$'), '');
    if (basePath.isEmpty || basePath == path) return null;
    return uri.replace(path: '${basePath}__poster.jpg').toString();
  }
}

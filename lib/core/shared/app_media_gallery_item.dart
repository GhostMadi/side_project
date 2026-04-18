import 'package:flutter/foundation.dart';

/// Элемент полноэкранной галереи (картинка или видео по URL).
@immutable
class AppMediaGalleryItem {
  const AppMediaGalleryItem({
    required this.url,
    required this.isVideo,
  });

  final String url;
  final bool isVideo;
}

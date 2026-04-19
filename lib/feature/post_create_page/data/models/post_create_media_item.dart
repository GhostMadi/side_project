import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_create_media_item.freezed.dart';

@freezed
abstract class PostCreateMediaItem with _$PostCreateMediaItem {
  const factory PostCreateMediaItem.image({
    required Uint8List bytes,
    @Default('image/jpeg') String mime,
    @Default('jpg') String ext,
    String? aspect,
  }) = _Image;

  const factory PostCreateMediaItem.video({
    required Uint8List bytes,
    required String mime,
    required String ext,
    String? aspect,
    /// JPEG frame for feed/cover; optional (server may accept null for legacy).
    Uint8List? posterJpeg,
  }) = _Video;
}


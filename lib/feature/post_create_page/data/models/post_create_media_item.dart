import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_create_media_item.freezed.dart';

@freezed
abstract class PostCreateMediaItem with _$PostCreateMediaItem {
  const factory PostCreateMediaItem.image({
    required Uint8List bytes,
    @Default('image/jpeg') String mime,
    @Default('jpg') String ext,
  }) = _Image;

  const factory PostCreateMediaItem.video({
    required Uint8List bytes,
    required String mime,
    required String ext,
  }) = _Video;
}


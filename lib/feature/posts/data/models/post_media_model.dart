import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/core/media/media_service.dart';
import 'package:side_project/feature/posts/data/models/post_media_type.dart';

part 'post_media_model.freezed.dart';
part 'post_media_model.g.dart';

@freezed
abstract class PostMediaModel with _$PostMediaModel {
  const factory PostMediaModel({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    required String url,
    @JsonKey(fromJson: PostMediaType.fromJson, toJson: _postMediaTypeToJson)
    required PostMediaType type,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PostMediaModel;

  factory PostMediaModel.fromJson(Map<String, dynamic> json) => _$PostMediaModelFromJson(json);
}

Object _postMediaTypeToJson(PostMediaType t) => t.toJson();

/// Правило превью в сетках (профиль, сохранённое и т.д.).
extension PostMediaModelGridPreview on PostMediaModel {
  bool get treatsAsVideoTile =>
      type == PostMediaType.video || MediaService.isVideo(url);

  /// URL статичной картинки для плитки; для видео — постер через [MediaService.videoPosterUrl].
  String? get gridStaticImageUrl {
    if (treatsAsVideoTile) {
      return MediaService.videoPosterUrl(url);
    }
    final u = url.trim();
    return u.isEmpty ? null : u;
  }
}

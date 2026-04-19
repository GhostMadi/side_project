import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/posts/data/models/post_media_type.dart';

part 'post_media_model.freezed.dart';
part 'post_media_model.g.dart';

@freezed
abstract class PostMediaModel with _$PostMediaModel {
  const factory PostMediaModel({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    required String url,
    @JsonKey(name: 'poster_url') String? posterUrl,
    @JsonKey(fromJson: PostMediaType.fromJson, toJson: _postMediaTypeToJson)
    required PostMediaType type,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PostMediaModel;

  factory PostMediaModel.fromJson(Map<String, dynamic> json) => _$PostMediaModelFromJson(json);
}

Object _postMediaTypeToJson(PostMediaType t) => t.toJson();


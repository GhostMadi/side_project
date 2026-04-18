import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
abstract class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'cluster_id') String? clusterId,
    String? title,
    String? subtitle,
    String? description,
    @JsonKey(name: 'is_archived') required bool isArchived,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    @JsonKey(name: 'likes_count') required int likesCount,
    @JsonKey(name: 'dislikes_count') required int dislikesCount,
    @JsonKey(name: 'comments_count') required int commentsCount,
    @JsonKey(name: 'saves_count') required int savesCount,
    @JsonKey(name: 'sends_count') required int sendsCount,
    @JsonKey(name: 'views_count') required int viewsCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'post_media') @Default([]) List<PostMediaModel> media,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
}

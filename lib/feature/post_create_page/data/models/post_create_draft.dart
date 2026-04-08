import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_media_item.dart';

part 'post_create_draft.freezed.dart';

@freezed
abstract class PostCreateDraft with _$PostCreateDraft {
  const factory PostCreateDraft({
    String? title,
    String? subtitle,
    String? description,
    String? clusterId,
    @Default([]) List<PostCreateMediaItem> media,
  }) = _PostCreateDraft;
}


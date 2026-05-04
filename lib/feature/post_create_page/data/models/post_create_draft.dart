import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_media_item.dart';

part 'post_create_draft.freezed.dart';

@freezed
abstract class PostCreateDraft with _$PostCreateDraft {
  const factory PostCreateDraft({
    /// Optional marker to attach this post to (`markers.post_id`).
    String? markerId,
    /// Optional per-post session time (within marker lifetime).
    DateTime? eventTime,

    /// Optional per-post session duration in minutes (<= 24h).
    int? durationMinutes,
    String? title,
    String? description,
    String? clusterId,
    @Default([]) List<PostCreateMediaItem> media,
  }) = _PostCreateDraft;
}


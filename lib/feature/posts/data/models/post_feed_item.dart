import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/posts/data/models/post_model.dart';

part 'post_feed_item.freezed.dart';

@freezed
abstract class PostFeedItem with _$PostFeedItem {
  const factory PostFeedItem({
    required PostModel post,
    String? authorUsername,
    String? authorAvatarUrl,
    /// `like` | `dislike` | null
    String? myReactionKind,
    @Default(false) bool mySaved,
  }) = _PostFeedItem;
}

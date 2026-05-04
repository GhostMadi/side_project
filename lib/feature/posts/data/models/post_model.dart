import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature/posts/data/models/post_linked_marker_model.dart';
import 'package:side_project/feature/posts/data/models/post_media_model.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
abstract class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'cluster_id') String? clusterId,
    /// Обратная ссылка на маркер (пара с [markers.post_id]).
    @JsonKey(name: 'marker_id') String? markerId,
    String? title,
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
    /// Опциональное окно сессии поста (внутри lifetime маркера). См. миграцию `posts_event_session_time`.
    @JsonKey(name: 'event_time') DateTime? eventTime,
    @JsonKey(name: 'end_time') DateTime? endTime,
    @JsonKey(name: 'post_media') @Default([]) List<PostMediaModel> media,
    /// См. [get_post_enriched] (join [markers]).
    PostLinkedMarker? marker,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
}

extension PostModelMarkerEventWindow on PostModel {
  /// Окно времени для карточки события: свои [eventTime]/[endTime] поста, иначе маркер.
  ({DateTime start, DateTime end}) get resolvedMarkerEventWindow {
    final m = marker;
    if (m == null) {
      throw StateError('resolvedMarkerEventWindow requires marker');
    }
    final s = eventTime;
    final e = endTime;
    if (s != null && e != null) {
      return (start: s, end: e);
    }
    return (start: m.eventTime, end: m.endTime);
  }
}

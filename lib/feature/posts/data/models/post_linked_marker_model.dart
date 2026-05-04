import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_linked_marker_model.freezed.dart';
part 'post_linked_marker_model.g.dart';

/// Фрагмент [markers] из [get_post_enriched] (без гео), для UI «события».
@freezed
abstract class PostLinkedMarker with _$PostLinkedMarker {
  const factory PostLinkedMarker({
    required String id,
    @JsonKey(name: 'text_emoji') String? textEmoji,
    @JsonKey(name: 'address_text') String? addressText,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'event_time') required DateTime eventTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    /// `upcoming` | `active` | `finished` | `cancelled`
    required String status,
  }) = _PostLinkedMarker;

  factory PostLinkedMarker.fromJson(Map<String, dynamic> json) => _$PostLinkedMarkerFromJson(json);
}

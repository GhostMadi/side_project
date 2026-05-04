import 'package:freezed_annotation/freezed_annotation.dart';

part 'marker_create_draft.freezed.dart';

@freezed
abstract class MarkerCreateDraft with _$MarkerCreateDraft {
  const factory MarkerCreateDraft({
    @Default(<String>{}) Set<String> tagKeys,
    String? emoji,
    double? lat,
    double? lng,
    String? address,
    DateTime? eventTime,
    @Default(120) int durationMinutes,
  }) = _MarkerCreateDraft;
}


import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:side_project/feature_draft/announcments/data/model/announcement_model.dart';

part 'announcement_state.freezed.dart';

@freezed
abstract class AnnouncementState with _$AnnouncementState {
  const factory AnnouncementState({
    /// грузимся ли сейчас
    @Default(false) bool isLoading,

    /// список всех объявлений
    @Default(<Announcement>[]) List<Announcement> items,

    /// выбранное/детальное объявление
    Announcement? selected,

    /// текст ошибки (если была)
    String? error,
  }) = _AnnouncementState;
}

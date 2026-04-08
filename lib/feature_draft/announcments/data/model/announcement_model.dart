import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
abstract class Announcement with _$Announcement {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Announcement({
    /// id объявления
    String? id,

    /// id создателя объявления
    String? creatorId,

    /// заголовок
    String? title,

    /// тип объявления (например: news, update, promo)
    String? type,

    /// категория (например: system, user, marketing)
    String? category,

    /// список ссылок на картинки
    @Default(<String>[]) List<String> imageUrls,

    /// список описаний
    @Default(<AnnouncementDescription>[])
    List<AnnouncementDescription> descriptions,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}

@freezed
abstract class AnnouncementDescription with _$AnnouncementDescription {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AnnouncementDescription({
    /// id описания
    String? id,

    /// ссылка на id объявления (idAnnouncement)
    String? announcementId,

    /// текст описания
    String? description,

    /// ссылка на картинку
    String? imageUrl,
  }) = _AnnouncementDescription;

  factory AnnouncementDescription.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementDescriptionFromJson(json);
}

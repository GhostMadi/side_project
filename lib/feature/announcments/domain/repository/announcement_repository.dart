import 'package:side_project/feature/announcments/data/model/announcement_model.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

/// Абстрактный репозиторий объявлений
abstract class AnnouncementRepository {
  /// Получить все объявления
  Future<List<Announcement>> getAnnouncements();

  /// Получить одно объявление по id
  Future<Announcement?> getAnnouncementById(String id);

  /// Создать новое объявление (ожидает, что imageUrls уже заполнены)
  Future<Announcement> createAnnouncement(Announcement announcement);

  /// Обновить объявление
  ///
  /// [announcement.id] должен быть не null.
  Future<Announcement> updateAnnouncement(Announcement announcement);

  /// Загрузить картинки в Storage и вернуть их URL-ы
  Future<List<String>> uploadImages(List<XFile> images);

  /// Удобный метод:
  /// 1) загружает картинки в Storage
  /// 2) создаёт Announcement с этими URL
  Future<Announcement> createAnnouncementWithImages({
    required String creatorId,
    required String title,
    String? type,
    String? category,
    required List<XFile> images,
    List<AnnouncementDescription> descriptions,
  });
}

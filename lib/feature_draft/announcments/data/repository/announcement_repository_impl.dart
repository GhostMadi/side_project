import 'package:image_picker/image_picker.dart';
import 'package:side_project/feature_draft/announcments/data/model/announcement_model.dart';
import 'package:side_project/feature_draft/announcments/domain/repository/announcement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final SupabaseClient _client;

  /// название bucket-а в Storage
  static const String _bucketName = 'announcements';

  AnnouncementRepositoryImpl({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  // ===================== PUBLIC METHODS ===================== //

  @override
  Future<List<Announcement>> getAnnouncements() async {
    final response = await _client.from('announcements').select('''
      id,
      creator_id,
      title,
      type,
      category,
      image_urls,
      descriptions:announcement_descriptions (
        id,
        announcement_id,
        description,
        image_url
      )
    ''');

    final list = (response as List<dynamic>)
        .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
        .toList();

    return list;
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    final response = await _client
        .from('announcements')
        .select('''
          id,
          creator_id,
          title,
          type,
          category,
          image_urls,
          descriptions:announcement_descriptions (
            id,
            announcement_id,
            description,
            image_url
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return Announcement.fromJson(response);
  }

  @override
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    // 1. создаём запись в announcements
    final inserted = await _client
        .from('announcements')
        .insert({
          'creator_id': announcement.creatorId,
          'title': announcement.title,
          'type': announcement.type,
          'category': announcement.category,
          'image_urls': announcement.imageUrls,
        })
        .select()
        .single();

    final String announcementId = inserted['id'] as String;

    // 2. descriptions
    if (announcement.descriptions.isNotEmpty) {
      final descRows = announcement.descriptions.map((d) {
        return {
          'announcement_id': announcementId,
          'description': d.description,
          'image_url': d.imageUrl,
        };
      }).toList();

      await _client.from('announcement_descriptions').insert(descRows);
    }

    // 3. возвращаем объект уже с релейшенами
    final result = await getAnnouncementById(announcementId);
    return result ?? announcement.copyWith(id: announcementId);
  }

  @override
  Future<Announcement> updateAnnouncement(Announcement announcement) async {
    if (announcement.id == null) {
      throw ArgumentError('announcement.id must not be null for update');
    }
    final String announcementId = announcement.id!;

    // 1. обновляем запись в announcements
    await _client
        .from('announcements')
        .update({
          'creator_id': announcement.creatorId,
          'title': announcement.title,
          'type': announcement.type,
          'category': announcement.category,
          'image_urls': announcement.imageUrls,
        })
        .eq('id', announcementId);

    // 2. пересоздаём descriptions
    await _client
        .from('announcement_descriptions')
        .delete()
        .eq('announcement_id', announcementId);

    if (announcement.descriptions.isNotEmpty) {
      final descRows = announcement.descriptions.map((d) {
        return {
          'announcement_id': announcementId,
          'description': d.description,
          'image_url': d.imageUrl,
        };
      }).toList();

      await _client.from('announcement_descriptions').insert(descRows);
    }

    // 3. возвращаем обновлённую сущность
    final result = await getAnnouncementById(announcementId);
    return result ?? announcement;
  }

  // ---------- Storage часть (всё в этом же репозитории) ---------- //

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    final List<String> urls = [];

    for (final image in images) {
      final url = await _uploadSingleImage(image);
      urls.add(url);
    }

    return urls;
  }

  @override
  Future<Announcement> createAnnouncementWithImages({
    required String creatorId,
    required String title,
    String? type,
    String? category,
    required List<XFile> images,
    List<AnnouncementDescription> descriptions = const [],
  }) async {
    // 1. Загружаем картинки в Storage
    final imageUrls = await uploadImages(images);

    // 2. Собираем модель
    final announcement = Announcement(
      creatorId: creatorId,
      title: title,
      type: type,
      category: category,
      imageUrls: imageUrls,
      descriptions: descriptions,
    );

    // 3. Сохраняем в БД
    return createAnnouncement(announcement);
  }

  // ===================== PRIVATE HELPERS ===================== //

  Future<String> _uploadSingleImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last;

    // можно сделать уникальное имя
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$ext';

    final filePath = 'images/$fileName';

    await _client.storage
        .from(_bucketName)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = _client.storage.from(_bucketName).getPublicUrl(filePath);

    return publicUrl;
  }
}

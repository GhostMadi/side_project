import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_draft.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_media_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostResponse {
  const CreatePostResponse({required this.postId});

  final String postId;
}

abstract class PostCreateRepository {
  Future<List<ClusterModel>> listMyClusters(String ownerId);
  Future<CreatePostResponse> createPost(PostCreateDraft draft);
}

@LazySingleton(as: PostCreateRepository)
class PostCreateRepositoryImpl implements PostCreateRepository {
  PostCreateRepositoryImpl(this._client, this._clusters);

  final SupabaseClient _client;
  final ClusterRepository _clusters;

  static const _bucket = 'post_media';

  @override
  Future<List<ClusterModel>> listMyClusters(String ownerId) => _clusters.listActiveByOwnerId(ownerId);

  @override
  Future<CreatePostResponse> createPost(PostCreateDraft draft) async {
    if (draft.media.isEmpty) {
      throw ArgumentError('media must not be empty');
    }

    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw StateError('Требуется вход в аккаунт');
    }

    developer.log('create_post: client-side Storage upload, media=${draft.media.length}', name: 'PostCreate');

    final markerId = draft.markerId?.trim();
    final eventTime = draft.eventTime;
    final durationMinutes = draft.durationMinutes;
    if (durationMinutes != null && (durationMinutes <= 0 || durationMinutes > 24 * 60)) {
      throw ArgumentError('durationMinutes must be within (0..1440]');
    }

    // Двусторонняя связь: posts.marker_id при вставке + markers.post_id после.
    final postInsert = <String, dynamic>{
      'user_id': uid,
      if (draft.title != null && draft.title!.trim().isNotEmpty) 'title': draft.title!.trim(),
      if (draft.description != null && draft.description!.trim().isNotEmpty)
        'description': draft.description!.trim(),
      if (draft.clusterId != null && draft.clusterId!.trim().isNotEmpty) 'cluster_id': draft.clusterId!.trim(),
      if (markerId != null && markerId.isNotEmpty) 'marker_id': markerId,
      if (eventTime != null) 'event_time': eventTime.toUtc().toIso8601String(),
      if (durationMinutes != null) 'duration': '$durationMinutes minutes',
    };

    final postRes = await _client.from('posts').insert(postInsert).select('id').single();
    final postId = postRes['id'] as String?;
    if (postId == null || postId.isEmpty) {
      throw StateError('create_post: не получен id поста');
    }

    /// Связка маркер ↔ пост: `posts.marker_id` + триггеры заполняют `marker_posts` и денормализованный `markers.post_id`.
    /// Отдельный PATCH на `markers` не делаем — иначе затирается «главный» пост при добавлении следующих постов к событию.

    final uploadedPaths = <String>[];
    final mediaRows = <Map<String, dynamic>>[];

    try {
      for (var i = 0; i < draft.media.length; i++) {
        await draft.media[i].map(
          image: (img) async {
            final fileId = _newMediaFileId();
            final extClean = _sanitizeExt(img.ext);
            if (extClean.isEmpty) {
              throw StateError('create_post: пустое расширение файла (image)');
            }
            final stem = _storageStem(fileId, img.aspect);
            final path = 'posts/$postId/$stem.$extClean';
            await _uploadBytes(path, img.bytes, img.mime);
            uploadedPaths.add(path);
            final imageUrl = _client.storage.from(_bucket).getPublicUrl(path);
            mediaRows.add({
              'post_id': postId,
              'url': imageUrl,
              'type': 'image',
              'sort_order': i,
            });
          },
          video: (vid) async {
            final fileId = _newMediaFileId();
            final extClean = _sanitizeExt(vid.ext);
            if (extClean.isEmpty) {
              throw StateError('create_post: пустое расширение файла (video)');
            }
            final stem = _storageStem(fileId, vid.aspect);
            final path = 'posts/$postId/$stem.$extClean';
            await _uploadBytes(path, vid.bytes, vid.mime);
            uploadedPaths.add(path);

            final poster = vid.posterJpeg;
            if (poster != null && poster.isNotEmpty) {
              final posterPath = 'posts/$postId/${fileId}__poster.jpg';
              await _uploadBytes(posterPath, poster, 'image/jpeg');
              uploadedPaths.add(posterPath);
            }

            final url = _client.storage.from(_bucket).getPublicUrl(path);
            mediaRows.add({
              'post_id': postId,
              'url': url,
              'type': 'video',
              'sort_order': i,
            });
          },
        );
      }

      await _client.from('post_media').insert(mediaRows);
    } catch (e, st) {
      developer.log('create_post failed: $e', name: 'PostCreate', stackTrace: st);
      try {
        if (uploadedPaths.isNotEmpty) {
          await _client.storage.from(_bucket).remove(uploadedPaths);
        }
      } catch (_) {}
      try {
        await _client.from('posts').delete().eq('id', postId);
      } catch (_) {}
      rethrow;
    }

    return CreatePostResponse(postId: postId);
  }

  Future<void> _uploadBytes(String path, Uint8List bytes, String contentType) async {
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
  }
}

String _sanitizeExt(String raw) => raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Суффикс `__ar-<preset>` в имени файла (совпадает с разбором в ленте / [MediaService]).
String _storageStem(String fileId, String? aspect) {
  final a = aspect?.trim();
  if (a == null || a.isEmpty) {
    return fileId;
  }
  return '${fileId}__ar-$a';
}

/// Имя файла в Storage (`posts/{post_id}/{uuid}.ext`).
String _newMediaFileId() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  const h = '0123456789abcdef';
  String o(int x) => '${h[x >> 4]}${h[x & 15]}';
  return '${o(b[0])}${o(b[1])}${o(b[2])}${o(b[3])}-'
      '${o(b[4])}${o(b[5])}-'
      '${o(b[6])}${o(b[7])}-'
      '${o(b[8])}${o(b[9])}-'
      '${o(b[10])}${o(b[11])}${o(b[12])}${o(b[13])}${o(b[14])}${o(b[15])}';
}

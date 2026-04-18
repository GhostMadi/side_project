import 'dart:convert';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:side_project/core/network/supabase_edge_functions_invoker.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_draft.dart';
import 'package:side_project/feature/post_create_page/data/models/post_create_media_item.dart';

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
  PostCreateRepositoryImpl(this._functions, this._clusters);

  final SupabaseEdgeFunctionsInvoker _functions;
  final ClusterRepository _clusters;

  @override
  Future<List<ClusterModel>> listMyClusters(String ownerId) => _clusters.listActiveByOwnerId(ownerId);

  @override
  Future<CreatePostResponse> createPost(PostCreateDraft draft) async {
    if (draft.media.isEmpty) {
      throw ArgumentError('media must not be empty');
    }

    final body = <String, dynamic>{
      if (draft.title != null && draft.title!.trim().isNotEmpty) 'title': draft.title!.trim(),
      if (draft.subtitle != null && draft.subtitle!.trim().isNotEmpty) 'subtitle': draft.subtitle!.trim(),
      if (draft.description != null && draft.description!.trim().isNotEmpty)
        'description': draft.description!.trim(),
      if (draft.clusterId != null && draft.clusterId!.trim().isNotEmpty) 'cluster_id': draft.clusterId!.trim(),
      'media': draft.media.map(_mediaToJson).toList(growable: false),
    };

    developer.log(
      'create_post draft: media=${draft.media.length}',
      name: 'PostCreate',
    );

    final res = await _functions.invoke('create_post', body: body);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('create_post: unexpected response');
    }
    final id = data['post_id'] as String?;
    if (id == null || id.isEmpty) {
      throw StateError('create_post: missing post_id');
    }
    return CreatePostResponse(postId: id);
  }

  Map<String, dynamic> _mediaToJson(PostCreateMediaItem item) {
    return item.when(
      image: (bytes, mime, ext, aspect) => {
        'type': 'image',
        'mime': mime,
        'ext': ext,
        'base64': base64Encode(bytes),
        if (aspect != null && aspect.trim().isNotEmpty) 'aspect': aspect.trim(),
      },
      video: (bytes, mime, ext, aspect) => {
        'type': 'video',
        'mime': mime,
        'ext': ext,
        'base64': base64Encode(bytes),
        if (aspect != null && aspect.trim().isNotEmpty) 'aspect': aspect.trim(),
      },
    );
  }
}


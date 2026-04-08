import 'package:flutter/material.dart';
import 'package:side_project/feature_draft/profile/models/post_model.dart';

/// Placeholder for post detail navigation from the draft profile grid.
class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Center(
        child: post.media.isEmpty
            ? const Text('No media')
            : Image.network(post.media.first, fit: BoxFit.contain),
      ),
    );
  }
}

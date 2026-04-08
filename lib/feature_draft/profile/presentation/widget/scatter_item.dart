import 'package:flutter/material.dart';
import 'package:side_project/feature_draft/profile/models/post_model.dart';

class ScatterItem extends StatelessWidget {
  final PostModel post;
  final int index;

  const ScatterItem({super.key, required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    final url = post.media.isNotEmpty ? post.media.first : 'https://picsum.photos/seed/${post.id}/400';
    return GestureDetector(
      onTap: () {
        // Draft: full-screen detail can be wired later
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

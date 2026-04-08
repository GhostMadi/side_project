import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Превью локального видео (без цветокора).
class PostCreateVideoPreview extends StatefulWidget {
  const PostCreateVideoPreview({super.key, required this.file});

  final File file;

  @override
  State<PostCreateVideoPreview> createState() => _PostCreateVideoPreviewState();
}

class _PostCreateVideoPreviewState extends State<PostCreateVideoPreview> {
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(widget.file)
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _c?.play();
        }
      });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final ar = c.value.aspectRatio;
    return Center(
      child: AspectRatio(
        aspectRatio: ar > 0 ? ar : 16 / 9,
        child: VideoPlayer(c),
      ),
    );
  }
}

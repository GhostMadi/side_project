class PostModel {
  final String id;
  final List<String> media;
  final bool isVideo;

  PostModel({required this.id, required this.media, this.isVideo = false});
}
enum PostMediaType {
  image,
  video;

  static PostMediaType fromJson(Object? value) {
    final s = value?.toString();
    return switch (s) {
      'image' => PostMediaType.image,
      'video' => PostMediaType.video,
      _ => throw ArgumentError('Unknown PostMediaType: $value'),
    };
  }

  String toJson() => name;
}


class ProfileMarkerModel {
  ProfileMarkerModel({
    required this.id,
    required this.ownerId,
    this.textEmoji,
    this.addressText,
    required this.eventTime,
    required this.endTime,
    required this.status,
    this.postId,
  });

  final String id;
  final String ownerId;
  final String? textEmoji;
  final String? addressText;
  final DateTime eventTime;
  final DateTime endTime;

  /// `marker_status` as string: upcoming|active|finished|cancelled
  final String status;

  final String? postId;

  factory ProfileMarkerModel.fromJson(Map<String, dynamic> json) {
    return ProfileMarkerModel(
      id: (json['id'] as String).trim(),
      ownerId: (json['owner_id'] as String).trim(),
      textEmoji: (json['text_emoji'] as String?)?.trim(),
      addressText: (json['address_text'] as String?)?.trim(),
      eventTime: DateTime.parse(json['event_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: (json['status'] as String).trim(),
      postId: (json['post_id'] as String?)?.trim(),
    );
  }
}


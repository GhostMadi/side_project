import 'dart:typed_data';

/// Один файл для отправки в чат (байты уже в памяти — после валидации размера).
class ChatOutgoingAttachment {
  const ChatOutgoingAttachment({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

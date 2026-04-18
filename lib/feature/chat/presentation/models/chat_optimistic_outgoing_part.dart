import 'dart:typed_data';

/// Локальный черновик вложения для оптимистичного пузыря (байты уже в памяти).
class ChatOptimisticOutgoingPart {
  const ChatOptimisticOutgoingPart({
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });

  final String filename;
  final String mimeType;
  final Uint8List bytes;
}

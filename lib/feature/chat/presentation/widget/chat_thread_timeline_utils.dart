import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';

/// Группа сообщений одного календарного дня (локальное время).
class ChatDaySection {
  ChatDaySection({required this.day, required List<ChatThreadItem> messages})
      : messagesAsc = List<ChatThreadItem>.from(messages);

  /// Дата без времени (локальная).
  final DateTime day;

  /// От старых к новым внутри дня.
  final List<ChatThreadItem> messagesAsc;
}

DateTime _asLocalDay(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

DateTime? _itemTime(ChatThreadItem item) {
  return item.when(
    server: (d) => d.message.createdAt.toLocal(),
    optimisticText: (_, __, ___, createdAt, ____, _____) => createdAt.toLocal(),
    optimisticAttachments: (_, __, createdAt, ___, ____, _____, ______) => createdAt.toLocal(),
  );
}

/// Сообщения с сервера приходят по времени возрастания (старые первыми).
List<ChatDaySection> splitChatItemsByDay(List<ChatThreadItem> itemsChronoAsc) {
  if (itemsChronoAsc.isEmpty) return [];
  final out = <ChatDaySection>[];
  for (final it in itemsChronoAsc) {
    final t = _itemTime(it);
    if (t == null) continue;
    final d = _asLocalDay(t);
    if (out.isEmpty || _asLocalDay(out.last.day) != d) {
      out.add(ChatDaySection(day: d, messages: [it]));
    } else {
      out.last.messagesAsc.add(it);
    }
  }
  return out;
}

String formatChatTime(DateTime t) => DateFormat('HH:mm').format(t.toLocal());

/// Плашка «Сегодня» / «Вчера» / полная дата (RU).
String formatChatDayHeader(DateTime day, {Locale? locale}) {
  final loc = locale ?? const Locale('ru');
  final today = _asLocalDay(DateTime.now());
  final y = today.subtract(const Duration(days: 1));
  final d = _asLocalDay(day);
  if (d == today) return 'Сегодня';
  if (d == y) return 'Вчера';
  return DateFormat.yMMMMd(loc.toString()).format(d);
}

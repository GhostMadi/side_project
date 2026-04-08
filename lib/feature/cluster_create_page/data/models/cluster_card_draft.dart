import 'package:flutter/foundation.dart';

/// Заголовок на карточке, пока пользователь ещё не ввёл название.
const String kClusterDraftPlaceholderTitle = 'Название кластера';

/// Черновик кластера для превью в профиле и на экране создания.
@immutable
class ClusterCardDraft {
  const ClusterCardDraft({required this.title, required this.subtitle, this.coverBytes});

  final String title;
  final String subtitle;
  final Uint8List? coverBytes;
}

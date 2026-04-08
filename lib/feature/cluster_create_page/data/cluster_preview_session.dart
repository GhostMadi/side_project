import 'package:flutter/foundation.dart';
import 'package:side_project/feature/cluster_create_page/data/models/cluster_card_draft.dart';

export 'models/cluster_card_draft.dart';

/// Временное состояние до сохранения в БД: превью «как будет в профиле».
abstract final class ClusterPreviewSession {
  static final ValueNotifier<ClusterCardDraft?> draftNotifier = ValueNotifier<ClusterCardDraft?>(null);

  static void update({required String title, required String subtitle, Uint8List? coverBytes}) {
    draftNotifier.value = ClusterCardDraft(title: title, subtitle: subtitle, coverBytes: coverBytes);
  }

  static void clear() {
    draftNotifier.value = null;
  }
}

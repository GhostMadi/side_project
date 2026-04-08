import 'package:flutter/foundation.dart';

/// Увеличить после создания/удаления кластера, чтобы [OwnerClustersStrip] перезагрузил данные.
final ValueNotifier<int> clusterListRefreshTick = ValueNotifier<int>(0);

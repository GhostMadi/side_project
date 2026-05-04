import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/marker_tag/domain/marker_tag_dictionary.dart';

part 'map_filters_cubit.freezed.dart';

@freezed
sealed class MapFiltersState with _$MapFiltersState {
  const factory MapFiltersState({
    /// Календарный день фильтра (12:00 локально) — у клиента дальше сужаем по дате `event_time` маркера; для RPC: `p_at_time`.
    required DateTime atTime,
    @Default([]) List<MarkerTagKey> selectedTagKeys,
  }) = _MapFiltersState;
}

@injectable
class MapFiltersCubit extends Cubit<MapFiltersState> {
  MapFiltersCubit() : super(_initial);

  static MapFiltersState get _initial {
    final n = DateTime.now();
    return MapFiltersState(atTime: DateTime(n.year, n.month, n.day, 12), selectedTagKeys: const []);
  }

  void setAtTimeCenterOfDay(DateTime d) {
    final local = d.toLocal();
    emit(state.copyWith(atTime: DateTime(local.year, local.month, local.day, 12)));
  }

  void setAtTimeNow() {
    emit(state.copyWith(atTime: DateTime.now()));
  }

  void toggleTag(MarkerTagKey key) {
    final next = List<MarkerTagKey>.from(state.selectedTagKeys);
    final i = next.indexWhere((e) => e == key);
    if (i >= 0) {
      next.removeAt(i);
    } else {
      next.add(key);
    }
    emit(state.copyWith(selectedTagKeys: next));
  }

  void clearTags() {
    if (state.selectedTagKeys.isEmpty) return;
    emit(state.copyWith(selectedTagKeys: const []));
  }

  void replaceAll({required DateTime atTime, required List<MarkerTagKey> tagKeys}) {
    final next = List<MarkerTagKey>.from(tagKeys);
    final prev = state.selectedTagKeys;
    if (atTime == state.atTime && _sameTagSet(prev, next)) {
      return;
    }
    log('replaceAll: atTime: $atTime, tagKeys: $next');
    emit(state.copyWith(atTime: atTime, selectedTagKeys: next));
  }
}

bool _sameTagSet(List<MarkerTagKey> a, List<MarkerTagKey> b) {
  if (a.length != b.length) return false;
  return a.toSet().containsAll(b) && b.toSet().containsAll(a);
}

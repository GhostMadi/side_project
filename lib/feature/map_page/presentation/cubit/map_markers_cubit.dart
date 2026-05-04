import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/shared/app_map.dart';
import 'package:side_project/feature/map_page/data/repository/map_markers_repository.dart';
import 'package:side_project/feature/map_page/presentation/almaty_demo_markers.dart' show almatyCenterLat, almatyCenterLng;
import 'package:side_project/feature/map_page/presentation/cubit/map_filters_cubit.dart';
import 'package:side_project/feature/map_page/presentation/map_geo_defaults.dart';
import 'package:side_project/feature/marker_tag/domain/marker_tag_dictionary.dart';
import 'package:side_project/feature/posts/data/repository/posts_repository.dart';

part 'map_markers_cubit.freezed.dart';

@injectable
class MapMarkersCubit extends Cubit<MapMarkersState> {
  MapMarkersCubit(this._repository, this._posts) : super(const MapMarkersState.initial());

  final MapMarkersRepository _repository;
  final PostsRepository _posts;

  static const double _lat = almatyCenterLat;
  static const double _lng = almatyCenterLng;
  static const double _radiusM = kMapViewDefaultRadiusM;

  /// Загрузка с учётом [MapFiltersState] (дата, теги). Центр/radius — дефолт до трекинга камеры.
  Future<void> load(MapFiltersState filters) async {
    emit(const MapMarkersState.loading());
    try {
      final tagKeys = filters.selectedTagKeys.map((e) => e.dbKey).toList();
      final list = await _repository.listForMapView(
        lat: _lat,
        lng: _lng,
        radiusM: _radiusM,
        atTime: filters.atTime,
        tagDbKeys: tagKeys,
      );
      emit(MapMarkersState.loaded(markers: list));

      // Prefetch heavy layer in background: ближайшие 10–20 post_id.
      final ids = <String>[];
      for (final m in list) {
        final meta = m.metadata;
        final pid = (meta != null && meta['postId'] is String) ? (meta['postId'] as String).trim() : '';
        if (pid.isNotEmpty) ids.add(pid);
        if (ids.length >= 20) break;
      }
      if (ids.isNotEmpty) {
        // best-effort; не блокируем UX
        // ignore: unawaited_futures
        _posts.prefetchPostsByIds(ids);
      }
    } catch (e) {
      emit(MapMarkersState.error(e.toString()));
    }
  }
}

@freezed
sealed class MapMarkersState with _$MapMarkersState {
  const factory MapMarkersState.initial() = _Initial;
  const factory MapMarkersState.loading() = _Loading;
  const factory MapMarkersState.loaded({required List<MapMarker> markers}) = _Loaded;
  const factory MapMarkersState.error(String message) = _Error;
}

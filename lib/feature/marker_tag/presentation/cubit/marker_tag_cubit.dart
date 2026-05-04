import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:side_project/feature/marker_tag/data/repository/marker_tag_repository.dart';

part 'marker_tag_cubit.freezed.dart';

@injectable
class MarkerTagCubit extends Cubit<MarkerTagState> {
  MarkerTagCubit(this._repository) : super(const MarkerTagState.initial());

  final MarkerTagRepository _repository;

  Future<void> loadTags() async {
    emit(const MarkerTagState.loading());
    try {
      final tags = await _repository.listTags();
      emit(MarkerTagState.tagsLoaded(tags: tags));
    } catch (e) {
      emit(MarkerTagState.error('$e'));
    }
  }

  Future<void> loadMarkersMap({
    required double lat,
    required double lng,
    required double radiusM,
    DateTime? atTime,
    String? emoji,
    List<String>? tagKeys,
    int limit = 200,
    int offset = 0,
  }) async {
    emit(const MarkerTagState.loading());
    try {
      final markers = await _repository.listMarkersMap(
        lat: lat,
        lng: lng,
        radiusM: radiusM,
        atTime: atTime,
        emoji: emoji,
        tagKeys: tagKeys,
        limit: limit,
        offset: offset,
      );
      emit(MarkerTagState.markersLoaded(markers: markers));
    } catch (e) {
      emit(MarkerTagState.error('$e'));
    }
  }
}

@freezed
sealed class MarkerTagState with _$MarkerTagState {
  const factory MarkerTagState.initial() = _Initial;
  const factory MarkerTagState.loading() = _Loading;
  const factory MarkerTagState.tagsLoaded({required List<MarkerTagModel> tags}) = _TagsLoaded;
  const factory MarkerTagState.markersLoaded({required List<MarkerMapItemModel> markers}) = _MarkersLoaded;
  const factory MarkerTagState.error(String message) = _Error;
}


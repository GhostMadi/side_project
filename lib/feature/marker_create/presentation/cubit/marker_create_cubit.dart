import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/marker_create/data/models/marker_create_draft.dart';
import 'package:side_project/feature/marker_create/data/repository/marker_create_repository.dart';
import 'package:side_project/feature/marker_tag/data/models/marker_models.dart';
import 'package:side_project/feature/marker_tag/data/repository/marker_tag_repository.dart';

part 'marker_create_cubit.freezed.dart';

enum MarkerCreateStep { tags, emoji, location, address, done }

@injectable
class MarkerCreateCubit extends Cubit<MarkerCreateState> {
  MarkerCreateCubit(this._tagsRepo, this._createRepo) : super(const MarkerCreateState.initial());

  final MarkerTagRepository _tagsRepo;
  final MarkerCreateRepository _createRepo;

  List<MarkerTagModel> _allTags = const [];

  Future<void> start() async {
    emit(const MarkerCreateState.loading());
    try {
      _allTags = await _tagsRepo.listTags();
      emit(
        MarkerCreateState.editing(
          step: MarkerCreateStep.tags,
          tags: _allTags,
          draft: const MarkerCreateDraft(),
          isSubmitting: false,
        ),
      );
    } catch (e) {
      emit(MarkerCreateState.error('$e'));
    }
  }

  void setStep(MarkerCreateStep step) {
    final s = state;
    if (s is! _Editing) return;
    emit(s.copyWith(step: step));
  }

  void toggleTagKey(String key) {
    final s = state;
    if (s is! _Editing) return;
    final set = {...s.draft.tagKeys};
    if (!set.add(key)) set.remove(key);
    emit(s.copyWith(draft: s.draft.copyWith(tagKeys: set)));
  }

  void setEmoji(String emoji) {
    final s = state;
    if (s is! _Editing) return;
    emit(s.copyWith(draft: s.draft.copyWith(emoji: emoji.trim())));
  }

  void setLocation({required double lat, required double lng}) {
    final s = state;
    if (s is! _Editing) return;
    emit(s.copyWith(draft: s.draft.copyWith(lat: lat, lng: lng)));
  }

  void setAddress(String address) {
    final s = state;
    if (s is! _Editing) return;
    emit(s.copyWith(draft: s.draft.copyWith(address: address)));
  }

  void setEventTime(DateTime time) {
    final s = state;
    if (s is! _Editing) return;
    emit(s.copyWith(draft: s.draft.copyWith(eventTime: time)));
  }

  void setDurationMinutes(int minutes) {
    final s = state;
    if (s is! _Editing) return;
    final clamped = minutes.clamp(15, 24 * 60);
    emit(s.copyWith(draft: s.draft.copyWith(durationMinutes: clamped)));
  }

  Future<void> submit() async {
    final s = state;
    if (s is! _Editing) return;
    final d = s.draft;
    final emoji = d.emoji?.trim() ?? '';
    final address = d.address?.trim() ?? '';
    if (emoji.isEmpty) {
      emit(s.copyWith(step: MarkerCreateStep.emoji));
      return;
    }
    if (d.lat == null || d.lng == null) {
      emit(s.copyWith(step: MarkerCreateStep.location));
      return;
    }
    if (address.isEmpty) {
      emit(s.copyWith(step: MarkerCreateStep.address));
      return;
    }

    emit(s.copyWith(isSubmitting: true));
    try {
      await _createRepo.createMarker(
        emoji: emoji,
        lat: d.lat!,
        lng: d.lng!,
        address: address,
        allTags: _allTags,
        selectedTagKeys: d.tagKeys,
        eventTime: d.eventTime ?? DateTime.now(),
        duration: Duration(minutes: d.durationMinutes),
      );
      emit(s.copyWith(isSubmitting: false, step: MarkerCreateStep.done));
    } catch (e) {
      emit(MarkerCreateState.error('$e'));
      emit(s.copyWith(isSubmitting: false));
    }
  }
}

@freezed
sealed class MarkerCreateState with _$MarkerCreateState {
  const factory MarkerCreateState.initial() = _Initial;
  const factory MarkerCreateState.loading() = _Loading;
  const factory MarkerCreateState.editing({
    required MarkerCreateStep step,
    required List<MarkerTagModel> tags,
    required MarkerCreateDraft draft,
    required bool isSubmitting,
  }) = _Editing;
  const factory MarkerCreateState.error(String message) = _Error;
}


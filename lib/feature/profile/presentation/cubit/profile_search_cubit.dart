import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';

part 'profile_search_cubit.freezed.dart';

@freezed
abstract class ProfileSearchState with _$ProfileSearchState {
  const factory ProfileSearchState({
    @Default('') String query,
    @Default(<ProfileSearchHit>[]) List<ProfileSearchHit> results,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProfileSearchState;
}

@injectable
class ProfileSearchCubit extends Cubit<ProfileSearchState> {
  ProfileSearchCubit(this._repository) : super(const ProfileSearchState());

  final ProfileRepository _repository;
  Timer? _debounce;
  String? _inFlightQuery;

  void onQueryChanged(String raw) {
    _debounce?.cancel();
    final q = raw.trim();
    emit(state.copyWith(query: raw, errorMessage: null));
    if (q.isEmpty) {
      _inFlightQuery = null;
      emit(state.copyWith(results: const [], isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true));
    _debounce = Timer(const Duration(milliseconds: 360), () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    _inFlightQuery = q;
    try {
      final list = await _repository.searchProfilesForTagging(query: q);
      if (isClosed || _inFlightQuery != q) {
        return;
      }
      emit(state.copyWith(results: list, isLoading: false, errorMessage: null));
    } catch (e) {
      if (isClosed || _inFlightQuery != q) {
        return;
      }
      emit(state.copyWith(isLoading: false, errorMessage: '$e', results: const []));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/profile_page/data/models/profile_marker_model.dart';
import 'package:side_project/feature/profile_page/data/repository/profile_markers_repository.dart';

part 'profile_markers_cubit.freezed.dart';

@injectable
class ProfileMarkersCubit extends Cubit<ProfileMarkersState> {
  ProfileMarkersCubit(this._repo) : super(const ProfileMarkersState.initial());

  final ProfileMarkersRepository _repo;
  String? _lastOwnerId;

  Future<void> load(String ownerId) async {
    _lastOwnerId = ownerId;
    emit(const ProfileMarkersState.loading());
    try {
      final items = await _repo.listOwnerMarkers(ownerId: ownerId);
      emit(ProfileMarkersState.loaded(items: items));
    } catch (e) {
      emit(ProfileMarkersState.error('$e'));
    }
  }

  /// Повторная подгрузка для того же владельца (например, после удаления поста).
  Future<void> reloadIfLoadedOwner() async {
    final o = _lastOwnerId;
    if (o == null || o.isEmpty) return;
    return load(o);
  }

  Future<void> deleteMarker(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    try {
      await _repo.deleteMarker(id);
    } finally {
      await reloadIfLoadedOwner();
    }
  }

  Future<void> archiveMarker(String markerId) async {
    final id = markerId.trim();
    if (id.isEmpty) return;
    try {
      await _repo.setMarkerArchived(markerId: id, archived: true);
    } finally {
      await reloadIfLoadedOwner();
    }
  }
}

@freezed
sealed class ProfileMarkersState with _$ProfileMarkersState {
  const factory ProfileMarkersState.initial() = _Initial;
  const factory ProfileMarkersState.loading() = _Loading;
  const factory ProfileMarkersState.loaded({required List<ProfileMarkerModel> items}) = _Loaded;
  const factory ProfileMarkersState.error(String message) = _Error;
}


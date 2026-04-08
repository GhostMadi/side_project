import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';

part 'clusters_list_cubit.freezed.dart';

@injectable
class ClustersListCubit extends Cubit<ClustersListState> {
  ClustersListCubit(this._repository) : super(const ClustersListState.initial());

  final ClusterRepository _repository;

  Future<void> load(String ownerId) async {
    if (isClosed) return;
    emit(const ClustersListState.loading());
    try {
      final items = await _repository.listActiveByOwnerId(ownerId);
      if (isClosed) return;
      emit(ClustersListState.loaded(items));
    } catch (e) {
      if (isClosed) return;
      emit(ClustersListState.error('$e'));
    }
  }
}

@freezed
class ClustersListState with _$ClustersListState {
  const factory ClustersListState.initial() = _Initial;
  const factory ClustersListState.loading() = _Loading;
  const factory ClustersListState.loaded(List<ClusterModel> items) = _Loaded;
  const factory ClustersListState.error(String message) = _Error;
}

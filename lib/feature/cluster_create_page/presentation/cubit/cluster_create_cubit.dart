import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/cluster/data/models/cluster_model.dart';
import 'package:side_project/feature/cluster/data/repository/cluster_repository.dart';

part 'cluster_create_cubit.freezed.dart';

@injectable
class ClusterCreateCubit extends Cubit<ClusterCreateState> {
  ClusterCreateCubit(this._repository) : super(const ClusterCreateState.editing());

  final ClusterRepository _repository;

  Future<void> submit({
    required String title,
    String? subtitle,
    Uint8List? coverBytes,
  }) async {
    emit(const ClusterCreateState.submitting());
    try {
      final cluster = await _repository.createCluster(
        title: title,
        subtitle: subtitle,
        coverBytes: coverBytes,
      );
      emit(ClusterCreateState.success(cluster));
    } catch (e) {
      emit(ClusterCreateState.error('$e'));
    }
  }

  /// После показа ошибки вернуть форму в режим редактирования.
  void acknowledgeError() {
    emit(const ClusterCreateState.editing());
  }
}

@freezed
class ClusterCreateState with _$ClusterCreateState {
  const factory ClusterCreateState.editing() = _Editing;
  const factory ClusterCreateState.submitting() = _Submitting;
  const factory ClusterCreateState.success(ClusterModel cluster) = _Success;
  const factory ClusterCreateState.error(String message) = _Error;
}

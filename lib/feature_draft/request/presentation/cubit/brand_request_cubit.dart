import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature_draft/request/data/models/brand_request_model.dart';
import 'package:side_project/feature_draft/request/domain/repository/brand_request_repository.dart';

part 'brand_request_cubit.freezed.dart';

@freezed
class BrandRequestState with _$BrandRequestState {
  const factory BrandRequestState.initial() = _Initial;
  const factory BrandRequestState.loading() = _Loading;
  const factory BrandRequestState.submitting() = _Submitting;
  const factory BrandRequestState.loaded(List<BrandRequestModel> requests) =
      _Loaded;
  const factory BrandRequestState.success() = _Success;
  const factory BrandRequestState.error(String message) = _Error;
}

@injectable
class BrandRequestCubit extends Cubit<BrandRequestState> {
  final BrandRequestRepository _repository;

  BrandRequestCubit(this._repository)
    : super(const BrandRequestState.initial());

  /// 1. Загрузить все (Pull)
  Future<void> loadMyRequests() async {
    emit(const BrandRequestState.loading());
    try {
      final requests = await _repository.getMyRequests();
      emit(BrandRequestState.loaded(requests));
    } catch (e) {
      emit(BrandRequestState.error(e.toString()));
    }
  }

  /// 2. Удалить конкретную (Delete)
  Future<void> deleteItem(String requestId) async {
    emit(const BrandRequestState.loading());
    try {
      await _repository.deleteRequest(requestId);
      // После удаления обновляем список
      loadMyRequests();
    } catch (e) {
      emit(BrandRequestState.error(e.toString()));
    }
  }

  /// 3. Обновить конкретную (Update)
  Future<void> updateItem({
    required String requestId,
    required String fullName,
    required String taxId,
    required String phone,
    required String email,
    File? newIdFrontFile,
    File? newIdBackFile,
    String? currentFrontPath,
    String? currentBackPath,
  }) async {
    emit(const BrandRequestState.submitting());
    try {
      String? frontPath = currentFrontPath;
      String? backPath = currentBackPath;

      if (newIdFrontFile != null) {
        frontPath = await _repository.uploadDocument(newIdFrontFile, 'front');
      }
      if (newIdBackFile != null) {
        backPath = await _repository.uploadDocument(newIdBackFile, 'back');
      }

      final updatedRequest = BrandRequestModel(
        id: requestId,
        userId: '',
        fullName: fullName,
        taxId: taxId,
        phone: phone,
        email: email,
        idFrontUrl: frontPath,
        idBackUrl: backPath,
        status: BrandRequestStatus.pending,
      );

      await _repository.updateRequest(updatedRequest);

      emit(const BrandRequestState.success());
      // Сразу перезагружаем список, чтобы пользователь увидел изменения
      loadMyRequests();
    } catch (e) {
      emit(BrandRequestState.error(e.toString()));
    }
  }

  /// 4. Создать новую (Create)
  Future<void> submitApplication({
    required String fullName,
    required String taxId,
    required String phone,
    required String email,
    required File? idFrontFile,
    required File? idBackFile,
  }) async {
    emit(const BrandRequestState.submitting());
    try {
      String? frontPath;
      String? backPath;

      if (idFrontFile != null) {
        frontPath = await _repository.uploadDocument(idFrontFile, 'front');
      }
      if (idBackFile != null) {
        backPath = await _repository.uploadDocument(idBackFile, 'back');
      }

      final newRequest = BrandRequestModel(
        id: '',
        userId: '',
        fullName: fullName,
        taxId: taxId,
        phone: phone,
        email: email,
        idFrontUrl: frontPath,
        idBackUrl: backPath,
        status: BrandRequestStatus.pending,
      );

      await _repository.createRequest(newRequest);

      emit(const BrandRequestState.success());
      loadMyRequests();
    } catch (e) {
      emit(BrandRequestState.error(e.toString()));
    }
  }
}

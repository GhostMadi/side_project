import 'dart:io';

import 'package:side_project/feature/request/data/models/brand_request_model.dart';

abstract class BrandRequestRepository {
  Future<List<BrandRequestModel>> getMyRequests();

  Future<void> createRequest(BrandRequestModel request);

  Future<void> updateRequest(BrandRequestModel request);

  Future<void> deleteRequest(String requestId);

  Future<String> uploadDocument(File file, String docType);

  Future<String> getViewUrl(String path);
}

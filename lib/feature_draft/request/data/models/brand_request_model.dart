import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_request_model.freezed.dart';
part 'brand_request_model.g.dart';

@freezed
abstract class BrandRequestModel with _$BrandRequestModel {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory BrandRequestModel({
    required String id,
    required String userId,
    required String fullName,
    required String taxId,
    required String phone,
    required String email,
    String? idFrontUrl,
    String? idBackUrl,

    // Используем Enum и задаем дефолтное значение
    @Default(BrandRequestStatus.pending) BrandRequestStatus status,

    @Default([]) List<ModeratorHistoryItem> moderatorHistory,
    String? moderatorName,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BrandRequestModel;

  factory BrandRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BrandRequestModelFromJson(json);
}

/// Модель элемента истории (внутри JSONB)
@freezed
abstract class ModeratorHistoryItem with _$ModeratorHistoryItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ModeratorHistoryItem({
    DateTime? date,
    String? comment,
    String? moderator,
  }) = _ModeratorHistoryItem;

  factory ModeratorHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ModeratorHistoryItemFromJson(json);
}

enum BrandRequestStatus {
  @JsonValue('pending')
  pending,

  @JsonValue('approved')
  approved,

  @JsonValue('rejected')
  rejected,

  @JsonValue('changes_requested')
  changesRequested;

  bool get isPending => this == BrandRequestStatus.pending;
}

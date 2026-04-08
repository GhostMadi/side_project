// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrandRequestModel _$BrandRequestModelFromJson(Map<String, dynamic> json) =>
    _BrandRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      taxId: json['tax_id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      idFrontUrl: json['id_front_url'] as String?,
      idBackUrl: json['id_back_url'] as String?,
      status:
          $enumDecodeNullable(_$BrandRequestStatusEnumMap, json['status']) ??
          BrandRequestStatus.pending,
      moderatorHistory:
          (json['moderator_history'] as List<dynamic>?)
              ?.map(
                (e) => ModeratorHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      moderatorName: json['moderator_name'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BrandRequestModelToJson(_BrandRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'tax_id': instance.taxId,
      'phone': instance.phone,
      'email': instance.email,
      'id_front_url': instance.idFrontUrl,
      'id_back_url': instance.idBackUrl,
      'status': _$BrandRequestStatusEnumMap[instance.status]!,
      'moderator_history': instance.moderatorHistory
          .map((e) => e.toJson())
          .toList(),
      'moderator_name': instance.moderatorName,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$BrandRequestStatusEnumMap = {
  BrandRequestStatus.pending: 'pending',
  BrandRequestStatus.approved: 'approved',
  BrandRequestStatus.rejected: 'rejected',
  BrandRequestStatus.changesRequested: 'changes_requested',
};

_ModeratorHistoryItem _$ModeratorHistoryItemFromJson(
  Map<String, dynamic> json,
) => _ModeratorHistoryItem(
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  comment: json['comment'] as String?,
  moderator: json['moderator'] as String?,
);

Map<String, dynamic> _$ModeratorHistoryItemToJson(
  _ModeratorHistoryItem instance,
) => <String, dynamic>{
  'date': instance.date?.toIso8601String(),
  'comment': instance.comment,
  'moderator': instance.moderator,
};

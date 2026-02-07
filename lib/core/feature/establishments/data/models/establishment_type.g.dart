// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'establishment_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EstablishmentType _$EstablishmentTypeFromJson(Map<String, dynamic> json) =>
    _EstablishmentType(
      code: $enumDecode(
        _$EstablishmentCodeEnumMap,
        json['code'],
        unknownValue: EstablishmentCode.unknown,
      ),
    );

Map<String, dynamic> _$EstablishmentTypeToJson(_EstablishmentType instance) =>
    <String, dynamic>{'code': _$EstablishmentCodeEnumMap[instance.code]!};

const _$EstablishmentCodeEnumMap = {
  EstablishmentCode.restaurant: 'restaurant',
  EstablishmentCode.gym: 'gym',
  EstablishmentCode.cafe: 'cafe',
  EstablishmentCode.hotel: 'hotel',
  EstablishmentCode.shop: 'shop',
  EstablishmentCode.salon: 'salon',
  EstablishmentCode.unknown: 'unknown',
};

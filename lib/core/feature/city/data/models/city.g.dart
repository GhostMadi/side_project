// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_City _$CityFromJson(Map<String, dynamic> json) => _City(
  id: (json['id'] as num).toInt(),
  countryCode: json['country_code'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$CityToJson(_City instance) => <String, dynamic>{
  'id': instance.id,
  'country_code': instance.countryCode,
  'code': instance.code,
};

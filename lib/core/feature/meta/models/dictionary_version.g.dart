// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DictionaryVersion _$DictionaryVersionFromJson(Map<String, dynamic> json) =>
    _DictionaryVersion(
      tableName: json['table_name'] as String,
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$DictionaryVersionToJson(_DictionaryVersion instance) =>
    <String, dynamic>{
      'table_name': instance.tableName,
      'version': instance.version,
    };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_version.freezed.dart';
part 'dictionary_version.g.dart';

@freezed
abstract class DictionaryVersion with _$DictionaryVersion {
  const factory DictionaryVersion({
    @JsonKey(name: 'table_name') required String tableName,
    required int version,
  }) = _DictionaryVersion;

  factory DictionaryVersion.fromJson(Map<String, dynamic> json) =>
      _$DictionaryVersionFromJson(json);
}

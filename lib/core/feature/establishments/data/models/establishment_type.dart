import 'package:freezed_annotation/freezed_annotation.dart';

part 'establishment_type.freezed.dart';
part 'establishment_type.g.dart';

@freezed
abstract class EstablishmentType with _$EstablishmentType {
  const factory EstablishmentType({
    // Маппим поле 'code' из базы в наш Enum.
    // Если придет значение, которого нет в Enum, подставится unknown.
    @JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown)
    required EstablishmentCode code,

    // В будущем сюда можно легко добавить поля, например:
    // String? name,
    // String? iconUrl,
  }) = _EstablishmentType;

  factory EstablishmentType.fromJson(Map<String, dynamic> json) =>
      _$EstablishmentTypeFromJson(json);
}

enum EstablishmentCode {
  @JsonValue('restaurant')
  restaurant,
  @JsonValue('gym')
  gym,
  @JsonValue('cafe')
  cafe,
  @JsonValue('hotel')
  hotel,
  @JsonValue('shop')
  shop,
  @JsonValue('salon')
  salon,

  /// Фолбэк на случай, если придет что-то новое
  @JsonValue('unknown')
  unknown,
}

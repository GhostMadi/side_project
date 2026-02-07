// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'establishment_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstablishmentType {

// Маппим поле 'code' из базы в наш Enum.
// Если придет значение, которого нет в Enum, подставится unknown.
@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown) EstablishmentCode get code;
/// Create a copy of EstablishmentType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstablishmentTypeCopyWith<EstablishmentType> get copyWith => _$EstablishmentTypeCopyWithImpl<EstablishmentType>(this as EstablishmentType, _$identity);

  /// Serializes this EstablishmentType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstablishmentType&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'EstablishmentType(code: $code)';
}


}

/// @nodoc
abstract mixin class $EstablishmentTypeCopyWith<$Res>  {
  factory $EstablishmentTypeCopyWith(EstablishmentType value, $Res Function(EstablishmentType) _then) = _$EstablishmentTypeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown) EstablishmentCode code
});




}
/// @nodoc
class _$EstablishmentTypeCopyWithImpl<$Res>
    implements $EstablishmentTypeCopyWith<$Res> {
  _$EstablishmentTypeCopyWithImpl(this._self, this._then);

  final EstablishmentType _self;
  final $Res Function(EstablishmentType) _then;

/// Create a copy of EstablishmentType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as EstablishmentCode,
  ));
}

}


/// Adds pattern-matching-related methods to [EstablishmentType].
extension EstablishmentTypePatterns on EstablishmentType {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstablishmentType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstablishmentType() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstablishmentType value)  $default,){
final _that = this;
switch (_that) {
case _EstablishmentType():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstablishmentType value)?  $default,){
final _that = this;
switch (_that) {
case _EstablishmentType() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown)  EstablishmentCode code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstablishmentType() when $default != null:
return $default(_that.code);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown)  EstablishmentCode code)  $default,) {final _that = this;
switch (_that) {
case _EstablishmentType():
return $default(_that.code);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown)  EstablishmentCode code)?  $default,) {final _that = this;
switch (_that) {
case _EstablishmentType() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstablishmentType implements EstablishmentType {
  const _EstablishmentType({@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown) required this.code});
  factory _EstablishmentType.fromJson(Map<String, dynamic> json) => _$EstablishmentTypeFromJson(json);

// Маппим поле 'code' из базы в наш Enum.
// Если придет значение, которого нет в Enum, подставится unknown.
@override@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown) final  EstablishmentCode code;

/// Create a copy of EstablishmentType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstablishmentTypeCopyWith<_EstablishmentType> get copyWith => __$EstablishmentTypeCopyWithImpl<_EstablishmentType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstablishmentTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstablishmentType&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'EstablishmentType(code: $code)';
}


}

/// @nodoc
abstract mixin class _$EstablishmentTypeCopyWith<$Res> implements $EstablishmentTypeCopyWith<$Res> {
  factory _$EstablishmentTypeCopyWith(_EstablishmentType value, $Res Function(_EstablishmentType) _then) = __$EstablishmentTypeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code', unknownEnumValue: EstablishmentCode.unknown) EstablishmentCode code
});




}
/// @nodoc
class __$EstablishmentTypeCopyWithImpl<$Res>
    implements _$EstablishmentTypeCopyWith<$Res> {
  __$EstablishmentTypeCopyWithImpl(this._self, this._then);

  final _EstablishmentType _self;
  final $Res Function(_EstablishmentType) _then;

/// Create a copy of EstablishmentType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_EstablishmentType(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as EstablishmentCode,
  ));
}


}

// dart format on

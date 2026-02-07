// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DictionaryVersion {

@JsonKey(name: 'table_name') String get tableName; int get version;
/// Create a copy of DictionaryVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryVersionCopyWith<DictionaryVersion> get copyWith => _$DictionaryVersionCopyWithImpl<DictionaryVersion>(this as DictionaryVersion, _$identity);

  /// Serializes this DictionaryVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryVersion&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableName,version);

@override
String toString() {
  return 'DictionaryVersion(tableName: $tableName, version: $version)';
}


}

/// @nodoc
abstract mixin class $DictionaryVersionCopyWith<$Res>  {
  factory $DictionaryVersionCopyWith(DictionaryVersion value, $Res Function(DictionaryVersion) _then) = _$DictionaryVersionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'table_name') String tableName, int version
});




}
/// @nodoc
class _$DictionaryVersionCopyWithImpl<$Res>
    implements $DictionaryVersionCopyWith<$Res> {
  _$DictionaryVersionCopyWithImpl(this._self, this._then);

  final DictionaryVersion _self;
  final $Res Function(DictionaryVersion) _then;

/// Create a copy of DictionaryVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tableName = null,Object? version = null,}) {
  return _then(_self.copyWith(
tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryVersion].
extension DictionaryVersionPatterns on DictionaryVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryVersion value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryVersion value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'table_name')  String tableName,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryVersion() when $default != null:
return $default(_that.tableName,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'table_name')  String tableName,  int version)  $default,) {final _that = this;
switch (_that) {
case _DictionaryVersion():
return $default(_that.tableName,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'table_name')  String tableName,  int version)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryVersion() when $default != null:
return $default(_that.tableName,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryVersion implements DictionaryVersion {
  const _DictionaryVersion({@JsonKey(name: 'table_name') required this.tableName, required this.version});
  factory _DictionaryVersion.fromJson(Map<String, dynamic> json) => _$DictionaryVersionFromJson(json);

@override@JsonKey(name: 'table_name') final  String tableName;
@override final  int version;

/// Create a copy of DictionaryVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryVersionCopyWith<_DictionaryVersion> get copyWith => __$DictionaryVersionCopyWithImpl<_DictionaryVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryVersion&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableName,version);

@override
String toString() {
  return 'DictionaryVersion(tableName: $tableName, version: $version)';
}


}

/// @nodoc
abstract mixin class _$DictionaryVersionCopyWith<$Res> implements $DictionaryVersionCopyWith<$Res> {
  factory _$DictionaryVersionCopyWith(_DictionaryVersion value, $Res Function(_DictionaryVersion) _then) = __$DictionaryVersionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'table_name') String tableName, int version
});




}
/// @nodoc
class __$DictionaryVersionCopyWithImpl<$Res>
    implements _$DictionaryVersionCopyWith<$Res> {
  __$DictionaryVersionCopyWithImpl(this._self, this._then);

  final _DictionaryVersion _self;
  final $Res Function(_DictionaryVersion) _then;

/// Create a copy of DictionaryVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tableName = null,Object? version = null,}) {
  return _then(_DictionaryVersion(
tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

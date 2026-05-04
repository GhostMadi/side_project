// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_create_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkerCreateDraft {

 Set<String> get tagKeys; String? get emoji; double? get lat; double? get lng; String? get address; DateTime? get eventTime; int get durationMinutes;
/// Create a copy of MarkerCreateDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerCreateDraftCopyWith<MarkerCreateDraft> get copyWith => _$MarkerCreateDraftCopyWithImpl<MarkerCreateDraft>(this as MarkerCreateDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerCreateDraft&&const DeepCollectionEquality().equals(other.tagKeys, tagKeys)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.address, address) || other.address == address)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tagKeys),emoji,lat,lng,address,eventTime,durationMinutes);

@override
String toString() {
  return 'MarkerCreateDraft(tagKeys: $tagKeys, emoji: $emoji, lat: $lat, lng: $lng, address: $address, eventTime: $eventTime, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class $MarkerCreateDraftCopyWith<$Res>  {
  factory $MarkerCreateDraftCopyWith(MarkerCreateDraft value, $Res Function(MarkerCreateDraft) _then) = _$MarkerCreateDraftCopyWithImpl;
@useResult
$Res call({
 Set<String> tagKeys, String? emoji, double? lat, double? lng, String? address, DateTime? eventTime, int durationMinutes
});




}
/// @nodoc
class _$MarkerCreateDraftCopyWithImpl<$Res>
    implements $MarkerCreateDraftCopyWith<$Res> {
  _$MarkerCreateDraftCopyWithImpl(this._self, this._then);

  final MarkerCreateDraft _self;
  final $Res Function(MarkerCreateDraft) _then;

/// Create a copy of MarkerCreateDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagKeys = null,Object? emoji = freezed,Object? lat = freezed,Object? lng = freezed,Object? address = freezed,Object? eventTime = freezed,Object? durationMinutes = null,}) {
  return _then(_self.copyWith(
tagKeys: null == tagKeys ? _self.tagKeys : tagKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkerCreateDraft].
extension MarkerCreateDraftPatterns on MarkerCreateDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkerCreateDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkerCreateDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkerCreateDraft value)  $default,){
final _that = this;
switch (_that) {
case _MarkerCreateDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkerCreateDraft value)?  $default,){
final _that = this;
switch (_that) {
case _MarkerCreateDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> tagKeys,  String? emoji,  double? lat,  double? lng,  String? address,  DateTime? eventTime,  int durationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkerCreateDraft() when $default != null:
return $default(_that.tagKeys,_that.emoji,_that.lat,_that.lng,_that.address,_that.eventTime,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> tagKeys,  String? emoji,  double? lat,  double? lng,  String? address,  DateTime? eventTime,  int durationMinutes)  $default,) {final _that = this;
switch (_that) {
case _MarkerCreateDraft():
return $default(_that.tagKeys,_that.emoji,_that.lat,_that.lng,_that.address,_that.eventTime,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> tagKeys,  String? emoji,  double? lat,  double? lng,  String? address,  DateTime? eventTime,  int durationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _MarkerCreateDraft() when $default != null:
return $default(_that.tagKeys,_that.emoji,_that.lat,_that.lng,_that.address,_that.eventTime,_that.durationMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _MarkerCreateDraft implements MarkerCreateDraft {
  const _MarkerCreateDraft({final  Set<String> tagKeys = const <String>{}, this.emoji, this.lat, this.lng, this.address, this.eventTime, this.durationMinutes = 120}): _tagKeys = tagKeys;
  

 final  Set<String> _tagKeys;
@override@JsonKey() Set<String> get tagKeys {
  if (_tagKeys is EqualUnmodifiableSetView) return _tagKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_tagKeys);
}

@override final  String? emoji;
@override final  double? lat;
@override final  double? lng;
@override final  String? address;
@override final  DateTime? eventTime;
@override@JsonKey() final  int durationMinutes;

/// Create a copy of MarkerCreateDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerCreateDraftCopyWith<_MarkerCreateDraft> get copyWith => __$MarkerCreateDraftCopyWithImpl<_MarkerCreateDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerCreateDraft&&const DeepCollectionEquality().equals(other._tagKeys, _tagKeys)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.address, address) || other.address == address)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tagKeys),emoji,lat,lng,address,eventTime,durationMinutes);

@override
String toString() {
  return 'MarkerCreateDraft(tagKeys: $tagKeys, emoji: $emoji, lat: $lat, lng: $lng, address: $address, eventTime: $eventTime, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class _$MarkerCreateDraftCopyWith<$Res> implements $MarkerCreateDraftCopyWith<$Res> {
  factory _$MarkerCreateDraftCopyWith(_MarkerCreateDraft value, $Res Function(_MarkerCreateDraft) _then) = __$MarkerCreateDraftCopyWithImpl;
@override @useResult
$Res call({
 Set<String> tagKeys, String? emoji, double? lat, double? lng, String? address, DateTime? eventTime, int durationMinutes
});




}
/// @nodoc
class __$MarkerCreateDraftCopyWithImpl<$Res>
    implements _$MarkerCreateDraftCopyWith<$Res> {
  __$MarkerCreateDraftCopyWithImpl(this._self, this._then);

  final _MarkerCreateDraft _self;
  final $Res Function(_MarkerCreateDraft) _then;

/// Create a copy of MarkerCreateDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagKeys = null,Object? emoji = freezed,Object? lat = freezed,Object? lng = freezed,Object? address = freezed,Object? eventTime = freezed,Object? durationMinutes = null,}) {
  return _then(_MarkerCreateDraft(
tagKeys: null == tagKeys ? _self._tagKeys : tagKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,eventTime: freezed == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

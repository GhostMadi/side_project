// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_filters_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapFiltersState {

/// Календарный день фильтра (12:00 локально) — у клиента дальше сужаем по дате `event_time` маркера; для RPC: `p_at_time`.
 DateTime get atTime; List<MarkerTagKey> get selectedTagKeys;
/// Create a copy of MapFiltersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapFiltersStateCopyWith<MapFiltersState> get copyWith => _$MapFiltersStateCopyWithImpl<MapFiltersState>(this as MapFiltersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapFiltersState&&(identical(other.atTime, atTime) || other.atTime == atTime)&&const DeepCollectionEquality().equals(other.selectedTagKeys, selectedTagKeys));
}


@override
int get hashCode => Object.hash(runtimeType,atTime,const DeepCollectionEquality().hash(selectedTagKeys));

@override
String toString() {
  return 'MapFiltersState(atTime: $atTime, selectedTagKeys: $selectedTagKeys)';
}


}

/// @nodoc
abstract mixin class $MapFiltersStateCopyWith<$Res>  {
  factory $MapFiltersStateCopyWith(MapFiltersState value, $Res Function(MapFiltersState) _then) = _$MapFiltersStateCopyWithImpl;
@useResult
$Res call({
 DateTime atTime, List<MarkerTagKey> selectedTagKeys
});




}
/// @nodoc
class _$MapFiltersStateCopyWithImpl<$Res>
    implements $MapFiltersStateCopyWith<$Res> {
  _$MapFiltersStateCopyWithImpl(this._self, this._then);

  final MapFiltersState _self;
  final $Res Function(MapFiltersState) _then;

/// Create a copy of MapFiltersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? atTime = null,Object? selectedTagKeys = null,}) {
  return _then(_self.copyWith(
atTime: null == atTime ? _self.atTime : atTime // ignore: cast_nullable_to_non_nullable
as DateTime,selectedTagKeys: null == selectedTagKeys ? _self.selectedTagKeys : selectedTagKeys // ignore: cast_nullable_to_non_nullable
as List<MarkerTagKey>,
  ));
}

}


/// Adds pattern-matching-related methods to [MapFiltersState].
extension MapFiltersStatePatterns on MapFiltersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapFiltersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapFiltersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapFiltersState value)  $default,){
final _that = this;
switch (_that) {
case _MapFiltersState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapFiltersState value)?  $default,){
final _that = this;
switch (_that) {
case _MapFiltersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime atTime,  List<MarkerTagKey> selectedTagKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapFiltersState() when $default != null:
return $default(_that.atTime,_that.selectedTagKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime atTime,  List<MarkerTagKey> selectedTagKeys)  $default,) {final _that = this;
switch (_that) {
case _MapFiltersState():
return $default(_that.atTime,_that.selectedTagKeys);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime atTime,  List<MarkerTagKey> selectedTagKeys)?  $default,) {final _that = this;
switch (_that) {
case _MapFiltersState() when $default != null:
return $default(_that.atTime,_that.selectedTagKeys);case _:
  return null;

}
}

}

/// @nodoc


class _MapFiltersState implements MapFiltersState {
  const _MapFiltersState({required this.atTime, final  List<MarkerTagKey> selectedTagKeys = const []}): _selectedTagKeys = selectedTagKeys;
  

/// Календарный день фильтра (12:00 локально) — у клиента дальше сужаем по дате `event_time` маркера; для RPC: `p_at_time`.
@override final  DateTime atTime;
 final  List<MarkerTagKey> _selectedTagKeys;
@override@JsonKey() List<MarkerTagKey> get selectedTagKeys {
  if (_selectedTagKeys is EqualUnmodifiableListView) return _selectedTagKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagKeys);
}


/// Create a copy of MapFiltersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapFiltersStateCopyWith<_MapFiltersState> get copyWith => __$MapFiltersStateCopyWithImpl<_MapFiltersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapFiltersState&&(identical(other.atTime, atTime) || other.atTime == atTime)&&const DeepCollectionEquality().equals(other._selectedTagKeys, _selectedTagKeys));
}


@override
int get hashCode => Object.hash(runtimeType,atTime,const DeepCollectionEquality().hash(_selectedTagKeys));

@override
String toString() {
  return 'MapFiltersState(atTime: $atTime, selectedTagKeys: $selectedTagKeys)';
}


}

/// @nodoc
abstract mixin class _$MapFiltersStateCopyWith<$Res> implements $MapFiltersStateCopyWith<$Res> {
  factory _$MapFiltersStateCopyWith(_MapFiltersState value, $Res Function(_MapFiltersState) _then) = __$MapFiltersStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime atTime, List<MarkerTagKey> selectedTagKeys
});




}
/// @nodoc
class __$MapFiltersStateCopyWithImpl<$Res>
    implements _$MapFiltersStateCopyWith<$Res> {
  __$MapFiltersStateCopyWithImpl(this._self, this._then);

  final _MapFiltersState _self;
  final $Res Function(_MapFiltersState) _then;

/// Create a copy of MapFiltersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? atTime = null,Object? selectedTagKeys = null,}) {
  return _then(_MapFiltersState(
atTime: null == atTime ? _self.atTime : atTime // ignore: cast_nullable_to_non_nullable
as DateTime,selectedTagKeys: null == selectedTagKeys ? _self._selectedTagKeys : selectedTagKeys // ignore: cast_nullable_to_non_nullable
as List<MarkerTagKey>,
  ));
}


}

// dart format on

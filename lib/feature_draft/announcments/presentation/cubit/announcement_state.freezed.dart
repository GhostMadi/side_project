// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnnouncementState {

/// грузимся ли сейчас
 bool get isLoading;/// список всех объявлений
 List<Announcement> get items;/// выбранное/детальное объявление
 Announcement? get selected;/// текст ошибки (если была)
 String? get error;
/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementStateCopyWith<AnnouncementState> get copyWith => _$AnnouncementStateCopyWithImpl<AnnouncementState>(this as AnnouncementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnouncementState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(items),selected,error);

@override
String toString() {
  return 'AnnouncementState(isLoading: $isLoading, items: $items, selected: $selected, error: $error)';
}


}

/// @nodoc
abstract mixin class $AnnouncementStateCopyWith<$Res>  {
  factory $AnnouncementStateCopyWith(AnnouncementState value, $Res Function(AnnouncementState) _then) = _$AnnouncementStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Announcement> items, Announcement? selected, String? error
});


$AnnouncementCopyWith<$Res>? get selected;

}
/// @nodoc
class _$AnnouncementStateCopyWithImpl<$Res>
    implements $AnnouncementStateCopyWith<$Res> {
  _$AnnouncementStateCopyWithImpl(this._self, this._then);

  final AnnouncementState _self;
  final $Res Function(AnnouncementState) _then;

/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? items = null,Object? selected = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Announcement>,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Announcement?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $AnnouncementCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnnouncementState].
extension AnnouncementStatePatterns on AnnouncementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnouncementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnouncementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnouncementState value)  $default,){
final _that = this;
switch (_that) {
case _AnnouncementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnouncementState value)?  $default,){
final _that = this;
switch (_that) {
case _AnnouncementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Announcement> items,  Announcement? selected,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnouncementState() when $default != null:
return $default(_that.isLoading,_that.items,_that.selected,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Announcement> items,  Announcement? selected,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AnnouncementState():
return $default(_that.isLoading,_that.items,_that.selected,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Announcement> items,  Announcement? selected,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AnnouncementState() when $default != null:
return $default(_that.isLoading,_that.items,_that.selected,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AnnouncementState implements AnnouncementState {
  const _AnnouncementState({this.isLoading = false, final  List<Announcement> items = const <Announcement>[], this.selected, this.error}): _items = items;
  

/// грузимся ли сейчас
@override@JsonKey() final  bool isLoading;
/// список всех объявлений
 final  List<Announcement> _items;
/// список всех объявлений
@override@JsonKey() List<Announcement> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// выбранное/детальное объявление
@override final  Announcement? selected;
/// текст ошибки (если была)
@override final  String? error;

/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementStateCopyWith<_AnnouncementState> get copyWith => __$AnnouncementStateCopyWithImpl<_AnnouncementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnouncementState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_items),selected,error);

@override
String toString() {
  return 'AnnouncementState(isLoading: $isLoading, items: $items, selected: $selected, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementStateCopyWith<$Res> implements $AnnouncementStateCopyWith<$Res> {
  factory _$AnnouncementStateCopyWith(_AnnouncementState value, $Res Function(_AnnouncementState) _then) = __$AnnouncementStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Announcement> items, Announcement? selected, String? error
});


@override $AnnouncementCopyWith<$Res>? get selected;

}
/// @nodoc
class __$AnnouncementStateCopyWithImpl<$Res>
    implements _$AnnouncementStateCopyWith<$Res> {
  __$AnnouncementStateCopyWithImpl(this._self, this._then);

  final _AnnouncementState _self;
  final $Res Function(_AnnouncementState) _then;

/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? items = null,Object? selected = freezed,Object? error = freezed,}) {
  return _then(_AnnouncementState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Announcement>,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Announcement?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AnnouncementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $AnnouncementCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partners_relations_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PartnersRelationsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnersRelationsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PartnersRelationsState()';
}


}

/// @nodoc
class $PartnersRelationsStateCopyWith<$Res>  {
$PartnersRelationsStateCopyWith(PartnersRelationsState _, $Res Function(PartnersRelationsState) __);
}


/// Adds pattern-matching-related methods to [PartnersRelationsState].
extension PartnersRelationsStatePatterns on PartnersRelationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _PrLoading value)?  loading,TResult Function( _PrLoaded value)?  loaded,TResult Function( _PrError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrLoading() when loading != null:
return loading(_that);case _PrLoaded() when loaded != null:
return loaded(_that);case _PrError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _PrLoading value)  loading,required TResult Function( _PrLoaded value)  loaded,required TResult Function( _PrError value)  error,}){
final _that = this;
switch (_that) {
case _PrLoading():
return loading(_that);case _PrLoaded():
return loaded(_that);case _PrError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _PrLoading value)?  loading,TResult? Function( _PrLoaded value)?  loaded,TResult? Function( _PrError value)?  error,}){
final _that = this;
switch (_that) {
case _PrLoading() when loading != null:
return loading(_that);case _PrLoaded() when loaded != null:
return loaded(_that);case _PrError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String viewerId,  List<RelationEdge> hireIncoming,  List<RelationEdge> hireOutgoing,  List<RelationEdge> joinIncoming,  List<RelationEdge> joinOutgoing,  List<RelationEdge> active)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrLoading() when loading != null:
return loading();case _PrLoaded() when loaded != null:
return loaded(_that.viewerId,_that.hireIncoming,_that.hireOutgoing,_that.joinIncoming,_that.joinOutgoing,_that.active);case _PrError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String viewerId,  List<RelationEdge> hireIncoming,  List<RelationEdge> hireOutgoing,  List<RelationEdge> joinIncoming,  List<RelationEdge> joinOutgoing,  List<RelationEdge> active)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _PrLoading():
return loading();case _PrLoaded():
return loaded(_that.viewerId,_that.hireIncoming,_that.hireOutgoing,_that.joinIncoming,_that.joinOutgoing,_that.active);case _PrError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String viewerId,  List<RelationEdge> hireIncoming,  List<RelationEdge> hireOutgoing,  List<RelationEdge> joinIncoming,  List<RelationEdge> joinOutgoing,  List<RelationEdge> active)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _PrLoading() when loading != null:
return loading();case _PrLoaded() when loaded != null:
return loaded(_that.viewerId,_that.hireIncoming,_that.hireOutgoing,_that.joinIncoming,_that.joinOutgoing,_that.active);case _PrError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PrLoading implements PartnersRelationsState {
  const _PrLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PartnersRelationsState.loading()';
}


}




/// @nodoc


class _PrLoaded implements PartnersRelationsState {
  const _PrLoaded({required this.viewerId, required final  List<RelationEdge> hireIncoming, required final  List<RelationEdge> hireOutgoing, required final  List<RelationEdge> joinIncoming, required final  List<RelationEdge> joinOutgoing, required final  List<RelationEdge> active}): _hireIncoming = hireIncoming,_hireOutgoing = hireOutgoing,_joinIncoming = joinIncoming,_joinOutgoing = joinOutgoing,_active = active;
  

 final  String viewerId;
 final  List<RelationEdge> _hireIncoming;
 List<RelationEdge> get hireIncoming {
  if (_hireIncoming is EqualUnmodifiableListView) return _hireIncoming;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hireIncoming);
}

 final  List<RelationEdge> _hireOutgoing;
 List<RelationEdge> get hireOutgoing {
  if (_hireOutgoing is EqualUnmodifiableListView) return _hireOutgoing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hireOutgoing);
}

 final  List<RelationEdge> _joinIncoming;
 List<RelationEdge> get joinIncoming {
  if (_joinIncoming is EqualUnmodifiableListView) return _joinIncoming;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinIncoming);
}

 final  List<RelationEdge> _joinOutgoing;
 List<RelationEdge> get joinOutgoing {
  if (_joinOutgoing is EqualUnmodifiableListView) return _joinOutgoing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinOutgoing);
}

 final  List<RelationEdge> _active;
 List<RelationEdge> get active {
  if (_active is EqualUnmodifiableListView) return _active;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_active);
}


/// Create a copy of PartnersRelationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrLoadedCopyWith<_PrLoaded> get copyWith => __$PrLoadedCopyWithImpl<_PrLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrLoaded&&(identical(other.viewerId, viewerId) || other.viewerId == viewerId)&&const DeepCollectionEquality().equals(other._hireIncoming, _hireIncoming)&&const DeepCollectionEquality().equals(other._hireOutgoing, _hireOutgoing)&&const DeepCollectionEquality().equals(other._joinIncoming, _joinIncoming)&&const DeepCollectionEquality().equals(other._joinOutgoing, _joinOutgoing)&&const DeepCollectionEquality().equals(other._active, _active));
}


@override
int get hashCode => Object.hash(runtimeType,viewerId,const DeepCollectionEquality().hash(_hireIncoming),const DeepCollectionEquality().hash(_hireOutgoing),const DeepCollectionEquality().hash(_joinIncoming),const DeepCollectionEquality().hash(_joinOutgoing),const DeepCollectionEquality().hash(_active));

@override
String toString() {
  return 'PartnersRelationsState.loaded(viewerId: $viewerId, hireIncoming: $hireIncoming, hireOutgoing: $hireOutgoing, joinIncoming: $joinIncoming, joinOutgoing: $joinOutgoing, active: $active)';
}


}

/// @nodoc
abstract mixin class _$PrLoadedCopyWith<$Res> implements $PartnersRelationsStateCopyWith<$Res> {
  factory _$PrLoadedCopyWith(_PrLoaded value, $Res Function(_PrLoaded) _then) = __$PrLoadedCopyWithImpl;
@useResult
$Res call({
 String viewerId, List<RelationEdge> hireIncoming, List<RelationEdge> hireOutgoing, List<RelationEdge> joinIncoming, List<RelationEdge> joinOutgoing, List<RelationEdge> active
});




}
/// @nodoc
class __$PrLoadedCopyWithImpl<$Res>
    implements _$PrLoadedCopyWith<$Res> {
  __$PrLoadedCopyWithImpl(this._self, this._then);

  final _PrLoaded _self;
  final $Res Function(_PrLoaded) _then;

/// Create a copy of PartnersRelationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? viewerId = null,Object? hireIncoming = null,Object? hireOutgoing = null,Object? joinIncoming = null,Object? joinOutgoing = null,Object? active = null,}) {
  return _then(_PrLoaded(
viewerId: null == viewerId ? _self.viewerId : viewerId // ignore: cast_nullable_to_non_nullable
as String,hireIncoming: null == hireIncoming ? _self._hireIncoming : hireIncoming // ignore: cast_nullable_to_non_nullable
as List<RelationEdge>,hireOutgoing: null == hireOutgoing ? _self._hireOutgoing : hireOutgoing // ignore: cast_nullable_to_non_nullable
as List<RelationEdge>,joinIncoming: null == joinIncoming ? _self._joinIncoming : joinIncoming // ignore: cast_nullable_to_non_nullable
as List<RelationEdge>,joinOutgoing: null == joinOutgoing ? _self._joinOutgoing : joinOutgoing // ignore: cast_nullable_to_non_nullable
as List<RelationEdge>,active: null == active ? _self._active : active // ignore: cast_nullable_to_non_nullable
as List<RelationEdge>,
  ));
}


}

/// @nodoc


class _PrError implements PartnersRelationsState {
  const _PrError(this.message);
  

 final  String message;

/// Create a copy of PartnersRelationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrErrorCopyWith<_PrError> get copyWith => __$PrErrorCopyWithImpl<_PrError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PartnersRelationsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PrErrorCopyWith<$Res> implements $PartnersRelationsStateCopyWith<$Res> {
  factory _$PrErrorCopyWith(_PrError value, $Res Function(_PrError) _then) = __$PrErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PrErrorCopyWithImpl<$Res>
    implements _$PrErrorCopyWith<$Res> {
  __$PrErrorCopyWithImpl(this._self, this._then);

  final _PrError _self;
  final $Res Function(_PrError) _then;

/// Create a copy of PartnersRelationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PrError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

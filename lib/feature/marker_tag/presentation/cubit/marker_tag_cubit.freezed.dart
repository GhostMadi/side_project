// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_tag_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkerTagState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerTagState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerTagState()';
}


}

/// @nodoc
class $MarkerTagStateCopyWith<$Res>  {
$MarkerTagStateCopyWith(MarkerTagState _, $Res Function(MarkerTagState) __);
}


/// Adds pattern-matching-related methods to [MarkerTagState].
extension MarkerTagStatePatterns on MarkerTagState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _TagsLoaded value)?  tagsLoaded,TResult Function( _MarkersLoaded value)?  markersLoaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _TagsLoaded() when tagsLoaded != null:
return tagsLoaded(_that);case _MarkersLoaded() when markersLoaded != null:
return markersLoaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _TagsLoaded value)  tagsLoaded,required TResult Function( _MarkersLoaded value)  markersLoaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _TagsLoaded():
return tagsLoaded(_that);case _MarkersLoaded():
return markersLoaded(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _TagsLoaded value)?  tagsLoaded,TResult? Function( _MarkersLoaded value)?  markersLoaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _TagsLoaded() when tagsLoaded != null:
return tagsLoaded(_that);case _MarkersLoaded() when markersLoaded != null:
return markersLoaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<MarkerTagModel> tags)?  tagsLoaded,TResult Function( List<MarkerMapItemModel> markers)?  markersLoaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _TagsLoaded() when tagsLoaded != null:
return tagsLoaded(_that.tags);case _MarkersLoaded() when markersLoaded != null:
return markersLoaded(_that.markers);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<MarkerTagModel> tags)  tagsLoaded,required TResult Function( List<MarkerMapItemModel> markers)  markersLoaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _TagsLoaded():
return tagsLoaded(_that.tags);case _MarkersLoaded():
return markersLoaded(_that.markers);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<MarkerTagModel> tags)?  tagsLoaded,TResult? Function( List<MarkerMapItemModel> markers)?  markersLoaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _TagsLoaded() when tagsLoaded != null:
return tagsLoaded(_that.tags);case _MarkersLoaded() when markersLoaded != null:
return markersLoaded(_that.markers);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements MarkerTagState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerTagState.initial()';
}


}




/// @nodoc


class _Loading implements MarkerTagState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerTagState.loading()';
}


}




/// @nodoc


class _TagsLoaded implements MarkerTagState {
  const _TagsLoaded({required final  List<MarkerTagModel> tags}): _tags = tags;
  

 final  List<MarkerTagModel> _tags;
 List<MarkerTagModel> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagsLoadedCopyWith<_TagsLoaded> get copyWith => __$TagsLoadedCopyWithImpl<_TagsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagsLoaded&&const DeepCollectionEquality().equals(other._tags, _tags));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'MarkerTagState.tagsLoaded(tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$TagsLoadedCopyWith<$Res> implements $MarkerTagStateCopyWith<$Res> {
  factory _$TagsLoadedCopyWith(_TagsLoaded value, $Res Function(_TagsLoaded) _then) = __$TagsLoadedCopyWithImpl;
@useResult
$Res call({
 List<MarkerTagModel> tags
});




}
/// @nodoc
class __$TagsLoadedCopyWithImpl<$Res>
    implements _$TagsLoadedCopyWith<$Res> {
  __$TagsLoadedCopyWithImpl(this._self, this._then);

  final _TagsLoaded _self;
  final $Res Function(_TagsLoaded) _then;

/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tags = null,}) {
  return _then(_TagsLoaded(
tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<MarkerTagModel>,
  ));
}


}

/// @nodoc


class _MarkersLoaded implements MarkerTagState {
  const _MarkersLoaded({required final  List<MarkerMapItemModel> markers}): _markers = markers;
  

 final  List<MarkerMapItemModel> _markers;
 List<MarkerMapItemModel> get markers {
  if (_markers is EqualUnmodifiableListView) return _markers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markers);
}


/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkersLoadedCopyWith<_MarkersLoaded> get copyWith => __$MarkersLoadedCopyWithImpl<_MarkersLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkersLoaded&&const DeepCollectionEquality().equals(other._markers, _markers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_markers));

@override
String toString() {
  return 'MarkerTagState.markersLoaded(markers: $markers)';
}


}

/// @nodoc
abstract mixin class _$MarkersLoadedCopyWith<$Res> implements $MarkerTagStateCopyWith<$Res> {
  factory _$MarkersLoadedCopyWith(_MarkersLoaded value, $Res Function(_MarkersLoaded) _then) = __$MarkersLoadedCopyWithImpl;
@useResult
$Res call({
 List<MarkerMapItemModel> markers
});




}
/// @nodoc
class __$MarkersLoadedCopyWithImpl<$Res>
    implements _$MarkersLoadedCopyWith<$Res> {
  __$MarkersLoadedCopyWithImpl(this._self, this._then);

  final _MarkersLoaded _self;
  final $Res Function(_MarkersLoaded) _then;

/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? markers = null,}) {
  return _then(_MarkersLoaded(
markers: null == markers ? _self._markers : markers // ignore: cast_nullable_to_non_nullable
as List<MarkerMapItemModel>,
  ));
}


}

/// @nodoc


class _Error implements MarkerTagState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MarkerTagState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MarkerTagStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of MarkerTagState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_following_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFollowingListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFollowingListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowingListState()';
}


}

/// @nodoc
class $ProfileFollowingListStateCopyWith<$Res>  {
$ProfileFollowingListStateCopyWith(ProfileFollowingListState _, $Res Function(ProfileFollowingListState) __);
}


/// Adds pattern-matching-related methods to [ProfileFollowingListState].
extension ProfileFollowingListStatePatterns on ProfileFollowingListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _PfoInitial value)?  initial,TResult Function( _PfoLoading value)?  loading,TResult Function( _PfoLoaded value)?  loaded,TResult Function( _PfoError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PfoInitial() when initial != null:
return initial(_that);case _PfoLoading() when loading != null:
return loading(_that);case _PfoLoaded() when loaded != null:
return loaded(_that);case _PfoError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _PfoInitial value)  initial,required TResult Function( _PfoLoading value)  loading,required TResult Function( _PfoLoaded value)  loaded,required TResult Function( _PfoError value)  error,}){
final _that = this;
switch (_that) {
case _PfoInitial():
return initial(_that);case _PfoLoading():
return loading(_that);case _PfoLoaded():
return loaded(_that);case _PfoError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _PfoInitial value)?  initial,TResult? Function( _PfoLoading value)?  loading,TResult? Function( _PfoLoaded value)?  loaded,TResult? Function( _PfoError value)?  error,}){
final _that = this;
switch (_that) {
case _PfoInitial() when initial != null:
return initial(_that);case _PfoLoading() when loading != null:
return loading(_that);case _PfoLoaded() when loaded != null:
return loaded(_that);case _PfoError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ProfileFollowRow> items,  bool hasMore,  bool isLoadingMore)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PfoInitial() when initial != null:
return initial();case _PfoLoading() when loading != null:
return loading();case _PfoLoaded() when loaded != null:
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfoError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ProfileFollowRow> items,  bool hasMore,  bool isLoadingMore)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _PfoInitial():
return initial();case _PfoLoading():
return loading();case _PfoLoaded():
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfoError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ProfileFollowRow> items,  bool hasMore,  bool isLoadingMore)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _PfoInitial() when initial != null:
return initial();case _PfoLoading() when loading != null:
return loading();case _PfoLoaded() when loaded != null:
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfoError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PfoInitial implements ProfileFollowingListState {
  const _PfoInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfoInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowingListState.initial()';
}


}




/// @nodoc


class _PfoLoading implements ProfileFollowingListState {
  const _PfoLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfoLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowingListState.loading()';
}


}




/// @nodoc


class _PfoLoaded implements ProfileFollowingListState {
  const _PfoLoaded({required final  List<ProfileFollowRow> items, required this.hasMore, required this.isLoadingMore}): _items = items;
  

 final  List<ProfileFollowRow> _items;
 List<ProfileFollowRow> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  bool hasMore;
 final  bool isLoadingMore;

/// Create a copy of ProfileFollowingListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PfoLoadedCopyWith<_PfoLoaded> get copyWith => __$PfoLoadedCopyWithImpl<_PfoLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfoLoaded&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,isLoadingMore);

@override
String toString() {
  return 'ProfileFollowingListState.loaded(items: $items, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$PfoLoadedCopyWith<$Res> implements $ProfileFollowingListStateCopyWith<$Res> {
  factory _$PfoLoadedCopyWith(_PfoLoaded value, $Res Function(_PfoLoaded) _then) = __$PfoLoadedCopyWithImpl;
@useResult
$Res call({
 List<ProfileFollowRow> items, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class __$PfoLoadedCopyWithImpl<$Res>
    implements _$PfoLoadedCopyWith<$Res> {
  __$PfoLoadedCopyWithImpl(this._self, this._then);

  final _PfoLoaded _self;
  final $Res Function(_PfoLoaded) _then;

/// Create a copy of ProfileFollowingListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(_PfoLoaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileFollowRow>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _PfoError implements ProfileFollowingListState {
  const _PfoError(this.message);
  

 final  String message;

/// Create a copy of ProfileFollowingListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PfoErrorCopyWith<_PfoError> get copyWith => __$PfoErrorCopyWithImpl<_PfoError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfoError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProfileFollowingListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PfoErrorCopyWith<$Res> implements $ProfileFollowingListStateCopyWith<$Res> {
  factory _$PfoErrorCopyWith(_PfoError value, $Res Function(_PfoError) _then) = __$PfoErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PfoErrorCopyWithImpl<$Res>
    implements _$PfoErrorCopyWith<$Res> {
  __$PfoErrorCopyWithImpl(this._self, this._then);

  final _PfoError _self;
  final $Res Function(_PfoError) _then;

/// Create a copy of ProfileFollowingListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PfoError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

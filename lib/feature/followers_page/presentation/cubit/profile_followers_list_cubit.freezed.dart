// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_followers_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFollowersListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFollowersListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowersListState()';
}


}

/// @nodoc
class $ProfileFollowersListStateCopyWith<$Res>  {
$ProfileFollowersListStateCopyWith(ProfileFollowersListState _, $Res Function(ProfileFollowersListState) __);
}


/// Adds pattern-matching-related methods to [ProfileFollowersListState].
extension ProfileFollowersListStatePatterns on ProfileFollowersListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _PfInitial value)?  initial,TResult Function( _PfLoading value)?  loading,TResult Function( _PfLoaded value)?  loaded,TResult Function( _PfError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PfInitial() when initial != null:
return initial(_that);case _PfLoading() when loading != null:
return loading(_that);case _PfLoaded() when loaded != null:
return loaded(_that);case _PfError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _PfInitial value)  initial,required TResult Function( _PfLoading value)  loading,required TResult Function( _PfLoaded value)  loaded,required TResult Function( _PfError value)  error,}){
final _that = this;
switch (_that) {
case _PfInitial():
return initial(_that);case _PfLoading():
return loading(_that);case _PfLoaded():
return loaded(_that);case _PfError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _PfInitial value)?  initial,TResult? Function( _PfLoading value)?  loading,TResult? Function( _PfLoaded value)?  loaded,TResult? Function( _PfError value)?  error,}){
final _that = this;
switch (_that) {
case _PfInitial() when initial != null:
return initial(_that);case _PfLoading() when loading != null:
return loading(_that);case _PfLoaded() when loaded != null:
return loaded(_that);case _PfError() when error != null:
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
case _PfInitial() when initial != null:
return initial();case _PfLoading() when loading != null:
return loading();case _PfLoaded() when loaded != null:
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfError() when error != null:
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
case _PfInitial():
return initial();case _PfLoading():
return loading();case _PfLoaded():
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfError():
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
case _PfInitial() when initial != null:
return initial();case _PfLoading() when loading != null:
return loading();case _PfLoaded() when loaded != null:
return loaded(_that.items,_that.hasMore,_that.isLoadingMore);case _PfError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PfInitial implements ProfileFollowersListState {
  const _PfInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowersListState.initial()';
}


}




/// @nodoc


class _PfLoading implements ProfileFollowersListState {
  const _PfLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileFollowersListState.loading()';
}


}




/// @nodoc


class _PfLoaded implements ProfileFollowersListState {
  const _PfLoaded({required final  List<ProfileFollowRow> items, required this.hasMore, required this.isLoadingMore}): _items = items;
  

 final  List<ProfileFollowRow> _items;
 List<ProfileFollowRow> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  bool hasMore;
 final  bool isLoadingMore;

/// Create a copy of ProfileFollowersListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PfLoadedCopyWith<_PfLoaded> get copyWith => __$PfLoadedCopyWithImpl<_PfLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfLoaded&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,isLoadingMore);

@override
String toString() {
  return 'ProfileFollowersListState.loaded(items: $items, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$PfLoadedCopyWith<$Res> implements $ProfileFollowersListStateCopyWith<$Res> {
  factory _$PfLoadedCopyWith(_PfLoaded value, $Res Function(_PfLoaded) _then) = __$PfLoadedCopyWithImpl;
@useResult
$Res call({
 List<ProfileFollowRow> items, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class __$PfLoadedCopyWithImpl<$Res>
    implements _$PfLoadedCopyWith<$Res> {
  __$PfLoadedCopyWithImpl(this._self, this._then);

  final _PfLoaded _self;
  final $Res Function(_PfLoaded) _then;

/// Create a copy of ProfileFollowersListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(_PfLoaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProfileFollowRow>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _PfError implements ProfileFollowersListState {
  const _PfError(this.message);
  

 final  String message;

/// Create a copy of ProfileFollowersListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PfErrorCopyWith<_PfError> get copyWith => __$PfErrorCopyWithImpl<_PfError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PfError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProfileFollowersListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PfErrorCopyWith<$Res> implements $ProfileFollowersListStateCopyWith<$Res> {
  factory _$PfErrorCopyWith(_PfError value, $Res Function(_PfError) _then) = __$PfErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PfErrorCopyWithImpl<$Res>
    implements _$PfErrorCopyWith<$Res> {
  __$PfErrorCopyWithImpl(this._self, this._then);

  final _PfError _self;
  final $Res Function(_PfError) _then;

/// Create a copy of ProfileFollowersListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PfError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

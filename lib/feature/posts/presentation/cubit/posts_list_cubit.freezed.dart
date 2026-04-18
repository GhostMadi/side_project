// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'posts_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostsListState()';
}


}

/// @nodoc
class $PostsListStateCopyWith<$Res>  {
$PostsListStateCopyWith(PostsListState _, $Res Function(PostsListState) __);
}


/// Adds pattern-matching-related methods to [PostsListState].
extension PostsListStatePatterns on PostsListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( String? feedClusterId,  bool feedWithoutCluster)?  loading,TResult Function( List<PostModel> items,  Map<String, PostListReaction> reactions,  Map<String, bool> savedByPostId,  String? feedClusterId,  bool feedWithoutCluster,  bool hasMore,  bool isLoadingMore)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.feedClusterId,_that.feedWithoutCluster);case _Loaded() when loaded != null:
return loaded(_that.items,_that.reactions,_that.savedByPostId,_that.feedClusterId,_that.feedWithoutCluster,_that.hasMore,_that.isLoadingMore);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( String? feedClusterId,  bool feedWithoutCluster)  loading,required TResult Function( List<PostModel> items,  Map<String, PostListReaction> reactions,  Map<String, bool> savedByPostId,  String? feedClusterId,  bool feedWithoutCluster,  bool hasMore,  bool isLoadingMore)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading(_that.feedClusterId,_that.feedWithoutCluster);case _Loaded():
return loaded(_that.items,_that.reactions,_that.savedByPostId,_that.feedClusterId,_that.feedWithoutCluster,_that.hasMore,_that.isLoadingMore);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( String? feedClusterId,  bool feedWithoutCluster)?  loading,TResult? Function( List<PostModel> items,  Map<String, PostListReaction> reactions,  Map<String, bool> savedByPostId,  String? feedClusterId,  bool feedWithoutCluster,  bool hasMore,  bool isLoadingMore)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.feedClusterId,_that.feedWithoutCluster);case _Loaded() when loaded != null:
return loaded(_that.items,_that.reactions,_that.savedByPostId,_that.feedClusterId,_that.feedWithoutCluster,_that.hasMore,_that.isLoadingMore);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements PostsListState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostsListState.initial()';
}


}




/// @nodoc


class _Loading implements PostsListState {
  const _Loading({this.feedClusterId, this.feedWithoutCluster = false});
  

 final  String? feedClusterId;
@JsonKey() final  bool feedWithoutCluster;

/// Create a copy of PostsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingCopyWith<_Loading> get copyWith => __$LoadingCopyWithImpl<_Loading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading&&(identical(other.feedClusterId, feedClusterId) || other.feedClusterId == feedClusterId)&&(identical(other.feedWithoutCluster, feedWithoutCluster) || other.feedWithoutCluster == feedWithoutCluster));
}


@override
int get hashCode => Object.hash(runtimeType,feedClusterId,feedWithoutCluster);

@override
String toString() {
  return 'PostsListState.loading(feedClusterId: $feedClusterId, feedWithoutCluster: $feedWithoutCluster)';
}


}

/// @nodoc
abstract mixin class _$LoadingCopyWith<$Res> implements $PostsListStateCopyWith<$Res> {
  factory _$LoadingCopyWith(_Loading value, $Res Function(_Loading) _then) = __$LoadingCopyWithImpl;
@useResult
$Res call({
 String? feedClusterId, bool feedWithoutCluster
});




}
/// @nodoc
class __$LoadingCopyWithImpl<$Res>
    implements _$LoadingCopyWith<$Res> {
  __$LoadingCopyWithImpl(this._self, this._then);

  final _Loading _self;
  final $Res Function(_Loading) _then;

/// Create a copy of PostsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? feedClusterId = freezed,Object? feedWithoutCluster = null,}) {
  return _then(_Loading(
feedClusterId: freezed == feedClusterId ? _self.feedClusterId : feedClusterId // ignore: cast_nullable_to_non_nullable
as String?,feedWithoutCluster: null == feedWithoutCluster ? _self.feedWithoutCluster : feedWithoutCluster // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Loaded implements PostsListState {
  const _Loaded({required final  List<PostModel> items, required final  Map<String, PostListReaction> reactions, required final  Map<String, bool> savedByPostId, this.feedClusterId, this.feedWithoutCluster = false, required this.hasMore, required this.isLoadingMore}): _items = items,_reactions = reactions,_savedByPostId = savedByPostId;
  

 final  List<PostModel> _items;
 List<PostModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, PostListReaction> _reactions;
 Map<String, PostListReaction> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

 final  Map<String, bool> _savedByPostId;
 Map<String, bool> get savedByPostId {
  if (_savedByPostId is EqualUnmodifiableMapView) return _savedByPostId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_savedByPostId);
}

/// Активный фильтр ленты: `null` и [feedWithoutCluster]==false — вся лента.
 final  String? feedClusterId;
@JsonKey() final  bool feedWithoutCluster;
 final  bool hasMore;
 final  bool isLoadingMore;

/// Create a copy of PostsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._savedByPostId, _savedByPostId)&&(identical(other.feedClusterId, feedClusterId) || other.feedClusterId == feedClusterId)&&(identical(other.feedWithoutCluster, feedWithoutCluster) || other.feedWithoutCluster == feedWithoutCluster)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_savedByPostId),feedClusterId,feedWithoutCluster,hasMore,isLoadingMore);

@override
String toString() {
  return 'PostsListState.loaded(items: $items, reactions: $reactions, savedByPostId: $savedByPostId, feedClusterId: $feedClusterId, feedWithoutCluster: $feedWithoutCluster, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $PostsListStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<PostModel> items, Map<String, PostListReaction> reactions, Map<String, bool> savedByPostId, String? feedClusterId, bool feedWithoutCluster, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of PostsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? reactions = null,Object? savedByPostId = null,Object? feedClusterId = freezed,Object? feedWithoutCluster = null,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(_Loaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PostModel>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, PostListReaction>,savedByPostId: null == savedByPostId ? _self._savedByPostId : savedByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,feedClusterId: freezed == feedClusterId ? _self.feedClusterId : feedClusterId // ignore: cast_nullable_to_non_nullable
as String?,feedWithoutCluster: null == feedWithoutCluster ? _self.feedWithoutCluster : feedWithoutCluster // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Error implements PostsListState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of PostsListState
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
  return 'PostsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PostsListStateCopyWith<$Res> {
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

/// Create a copy of PostsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

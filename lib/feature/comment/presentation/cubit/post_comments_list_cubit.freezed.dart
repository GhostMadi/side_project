// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_comments_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCommentsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCommentsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCommentsListState()';
}


}

/// @nodoc
class $PostCommentsListStateCopyWith<$Res>  {
$PostCommentsListStateCopyWith(PostCommentsListState _, $Res Function(PostCommentsListState) __);
}


/// Adds pattern-matching-related methods to [PostCommentsListState].
extension PostCommentsListStatePatterns on PostCommentsListState {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<CommentModel> items,  int offset,  bool hasMore,  bool isLoadingMore,  Map<String, List<CommentModel>> replyThreads,  String? loadingRepliesForParentId,  Map<String, String> myReactionByCommentId)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.items,_that.offset,_that.hasMore,_that.isLoadingMore,_that.replyThreads,_that.loadingRepliesForParentId,_that.myReactionByCommentId);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<CommentModel> items,  int offset,  bool hasMore,  bool isLoadingMore,  Map<String, List<CommentModel>> replyThreads,  String? loadingRepliesForParentId,  Map<String, String> myReactionByCommentId)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.items,_that.offset,_that.hasMore,_that.isLoadingMore,_that.replyThreads,_that.loadingRepliesForParentId,_that.myReactionByCommentId);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<CommentModel> items,  int offset,  bool hasMore,  bool isLoadingMore,  Map<String, List<CommentModel>> replyThreads,  String? loadingRepliesForParentId,  Map<String, String> myReactionByCommentId)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.items,_that.offset,_that.hasMore,_that.isLoadingMore,_that.replyThreads,_that.loadingRepliesForParentId,_that.myReactionByCommentId);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements PostCommentsListState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCommentsListState.initial()';
}


}




/// @nodoc


class _Loading implements PostCommentsListState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCommentsListState.loading()';
}


}




/// @nodoc


class _Loaded implements PostCommentsListState {
  const _Loaded({required final  List<CommentModel> items, required this.offset, required this.hasMore, required this.isLoadingMore, final  Map<String, List<CommentModel>> replyThreads = const {}, this.loadingRepliesForParentId, final  Map<String, String> myReactionByCommentId = const {}}): _items = items,_replyThreads = replyThreads,_myReactionByCommentId = myReactionByCommentId;
  

 final  List<CommentModel> _items;
 List<CommentModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  int offset;
 final  bool hasMore;
 final  bool isLoadingMore;
/// Ключ — id родительского комментария; значение — прямые ответы (после loadReplies).
 final  Map<String, List<CommentModel>> _replyThreads;
/// Ключ — id родительского комментария; значение — прямые ответы (после loadReplies).
@JsonKey() Map<String, List<CommentModel>> get replyThreads {
  if (_replyThreads is EqualUnmodifiableMapView) return _replyThreads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_replyThreads);
}

 final  String? loadingRepliesForParentId;
/// Текущий пользователь: comment_id → like | dislike (как get_my_post_reactions).
 final  Map<String, String> _myReactionByCommentId;
/// Текущий пользователь: comment_id → like | dislike (как get_my_post_reactions).
@JsonKey() Map<String, String> get myReactionByCommentId {
  if (_myReactionByCommentId is EqualUnmodifiableMapView) return _myReactionByCommentId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_myReactionByCommentId);
}


/// Create a copy of PostCommentsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&const DeepCollectionEquality().equals(other._replyThreads, _replyThreads)&&(identical(other.loadingRepliesForParentId, loadingRepliesForParentId) || other.loadingRepliesForParentId == loadingRepliesForParentId)&&const DeepCollectionEquality().equals(other._myReactionByCommentId, _myReactionByCommentId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),offset,hasMore,isLoadingMore,const DeepCollectionEquality().hash(_replyThreads),loadingRepliesForParentId,const DeepCollectionEquality().hash(_myReactionByCommentId));

@override
String toString() {
  return 'PostCommentsListState.loaded(items: $items, offset: $offset, hasMore: $hasMore, isLoadingMore: $isLoadingMore, replyThreads: $replyThreads, loadingRepliesForParentId: $loadingRepliesForParentId, myReactionByCommentId: $myReactionByCommentId)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $PostCommentsListStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<CommentModel> items, int offset, bool hasMore, bool isLoadingMore, Map<String, List<CommentModel>> replyThreads, String? loadingRepliesForParentId, Map<String, String> myReactionByCommentId
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of PostCommentsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? offset = null,Object? hasMore = null,Object? isLoadingMore = null,Object? replyThreads = null,Object? loadingRepliesForParentId = freezed,Object? myReactionByCommentId = null,}) {
  return _then(_Loaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommentModel>,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,replyThreads: null == replyThreads ? _self._replyThreads : replyThreads // ignore: cast_nullable_to_non_nullable
as Map<String, List<CommentModel>>,loadingRepliesForParentId: freezed == loadingRepliesForParentId ? _self.loadingRepliesForParentId : loadingRepliesForParentId // ignore: cast_nullable_to_non_nullable
as String?,myReactionByCommentId: null == myReactionByCommentId ? _self._myReactionByCommentId : myReactionByCommentId // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc


class _Error implements PostCommentsListState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of PostCommentsListState
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
  return 'PostCommentsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PostCommentsListStateCopyWith<$Res> {
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

/// Create a copy of PostCommentsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

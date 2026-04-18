// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatThreadState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatThreadState()';
}


}

/// @nodoc
class $ChatThreadStateCopyWith<$Res>  {
$ChatThreadStateCopyWith(ChatThreadState _, $Res Function(ChatThreadState) __);
}


/// Adds pattern-matching-related methods to [ChatThreadState].
extension ChatThreadStatePatterns on ChatThreadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ChatThreadInitial value)?  initial,TResult Function( _ChatThreadLoading value)?  loading,TResult Function( _ChatThreadLoaded value)?  loaded,TResult Function( _ChatThreadError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadInitial() when initial != null:
return initial(_that);case _ChatThreadLoading() when loading != null:
return loading(_that);case _ChatThreadLoaded() when loaded != null:
return loaded(_that);case _ChatThreadError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ChatThreadInitial value)  initial,required TResult Function( _ChatThreadLoading value)  loading,required TResult Function( _ChatThreadLoaded value)  loaded,required TResult Function( _ChatThreadError value)  error,}){
final _that = this;
switch (_that) {
case _ChatThreadInitial():
return initial(_that);case _ChatThreadLoading():
return loading(_that);case _ChatThreadLoaded():
return loaded(_that);case _ChatThreadError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ChatThreadInitial value)?  initial,TResult? Function( _ChatThreadLoading value)?  loading,TResult? Function( _ChatThreadLoaded value)?  loaded,TResult? Function( _ChatThreadError value)?  error,}){
final _that = this;
switch (_that) {
case _ChatThreadInitial() when initial != null:
return initial(_that);case _ChatThreadLoading() when loading != null:
return loading(_that);case _ChatThreadLoaded() when loaded != null:
return loaded(_that);case _ChatThreadError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String conversationId,  List<ChatThreadItem> items,  bool isLoadingMore,  bool hasMore,  String? errorMessage,  int syncGeneration)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadInitial() when initial != null:
return initial();case _ChatThreadLoading() when loading != null:
return loading();case _ChatThreadLoaded() when loaded != null:
return loaded(_that.conversationId,_that.items,_that.isLoadingMore,_that.hasMore,_that.errorMessage,_that.syncGeneration);case _ChatThreadError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String conversationId,  List<ChatThreadItem> items,  bool isLoadingMore,  bool hasMore,  String? errorMessage,  int syncGeneration)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _ChatThreadInitial():
return initial();case _ChatThreadLoading():
return loading();case _ChatThreadLoaded():
return loaded(_that.conversationId,_that.items,_that.isLoadingMore,_that.hasMore,_that.errorMessage,_that.syncGeneration);case _ChatThreadError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String conversationId,  List<ChatThreadItem> items,  bool isLoadingMore,  bool hasMore,  String? errorMessage,  int syncGeneration)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _ChatThreadInitial() when initial != null:
return initial();case _ChatThreadLoading() when loading != null:
return loading();case _ChatThreadLoaded() when loaded != null:
return loaded(_that.conversationId,_that.items,_that.isLoadingMore,_that.hasMore,_that.errorMessage,_that.syncGeneration);case _ChatThreadError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatThreadInitial implements ChatThreadState {
  const _ChatThreadInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatThreadState.initial()';
}


}




/// @nodoc


class _ChatThreadLoading implements ChatThreadState {
  const _ChatThreadLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatThreadState.loading()';
}


}




/// @nodoc


class _ChatThreadLoaded implements ChatThreadState {
  const _ChatThreadLoaded({required this.conversationId, final  List<ChatThreadItem> items = const <ChatThreadItem>[], this.isLoadingMore = false, this.hasMore = true, this.errorMessage, this.syncGeneration = 0}): _items = items;
  

 final  String conversationId;
 final  List<ChatThreadItem> _items;
@JsonKey() List<ChatThreadItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  bool isLoadingMore;
@JsonKey() final  bool hasMore;
 final  String? errorMessage;
/// Увеличивается при каждой синхронизации с сервером; иначе Bloc может не emit
/// при том же глубоком содержимом items (лаг RPC / то же окно из 50 сообщений).
@JsonKey() final  int syncGeneration;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadLoadedCopyWith<_ChatThreadLoaded> get copyWith => __$ChatThreadLoadedCopyWithImpl<_ChatThreadLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadLoaded&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.syncGeneration, syncGeneration) || other.syncGeneration == syncGeneration));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,const DeepCollectionEquality().hash(_items),isLoadingMore,hasMore,errorMessage,syncGeneration);

@override
String toString() {
  return 'ChatThreadState.loaded(conversationId: $conversationId, items: $items, isLoadingMore: $isLoadingMore, hasMore: $hasMore, errorMessage: $errorMessage, syncGeneration: $syncGeneration)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadLoadedCopyWith<$Res> implements $ChatThreadStateCopyWith<$Res> {
  factory _$ChatThreadLoadedCopyWith(_ChatThreadLoaded value, $Res Function(_ChatThreadLoaded) _then) = __$ChatThreadLoadedCopyWithImpl;
@useResult
$Res call({
 String conversationId, List<ChatThreadItem> items, bool isLoadingMore, bool hasMore, String? errorMessage, int syncGeneration
});




}
/// @nodoc
class __$ChatThreadLoadedCopyWithImpl<$Res>
    implements _$ChatThreadLoadedCopyWith<$Res> {
  __$ChatThreadLoadedCopyWithImpl(this._self, this._then);

  final _ChatThreadLoaded _self;
  final $Res Function(_ChatThreadLoaded) _then;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? items = null,Object? isLoadingMore = null,Object? hasMore = null,Object? errorMessage = freezed,Object? syncGeneration = null,}) {
  return _then(_ChatThreadLoaded(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatThreadItem>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,syncGeneration: null == syncGeneration ? _self.syncGeneration : syncGeneration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ChatThreadError implements ChatThreadState {
  const _ChatThreadError(this.message);
  

 final  String message;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadErrorCopyWith<_ChatThreadError> get copyWith => __$ChatThreadErrorCopyWithImpl<_ChatThreadError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatThreadState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadErrorCopyWith<$Res> implements $ChatThreadStateCopyWith<$Res> {
  factory _$ChatThreadErrorCopyWith(_ChatThreadError value, $Res Function(_ChatThreadError) _then) = __$ChatThreadErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ChatThreadErrorCopyWithImpl<$Res>
    implements _$ChatThreadErrorCopyWith<$Res> {
  __$ChatThreadErrorCopyWithImpl(this._self, this._then);

  final _ChatThreadError _self;
  final $Res Function(_ChatThreadError) _then;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ChatThreadError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

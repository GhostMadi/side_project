// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversations_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatConversationsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationsListState()';
}


}

/// @nodoc
class $ChatConversationsListStateCopyWith<$Res>  {
$ChatConversationsListStateCopyWith(ChatConversationsListState _, $Res Function(ChatConversationsListState) __);
}


/// Adds pattern-matching-related methods to [ChatConversationsListState].
extension ChatConversationsListStatePatterns on ChatConversationsListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ChatConvInitial value)?  initial,TResult Function( _ChatConvLoading value)?  loading,TResult Function( _ChatConvLoaded value)?  loaded,TResult Function( _ChatConvError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConvInitial() when initial != null:
return initial(_that);case _ChatConvLoading() when loading != null:
return loading(_that);case _ChatConvLoaded() when loaded != null:
return loaded(_that);case _ChatConvError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ChatConvInitial value)  initial,required TResult Function( _ChatConvLoading value)  loading,required TResult Function( _ChatConvLoaded value)  loaded,required TResult Function( _ChatConvError value)  error,}){
final _that = this;
switch (_that) {
case _ChatConvInitial():
return initial(_that);case _ChatConvLoading():
return loading(_that);case _ChatConvLoaded():
return loaded(_that);case _ChatConvError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ChatConvInitial value)?  initial,TResult? Function( _ChatConvLoading value)?  loading,TResult? Function( _ChatConvLoaded value)?  loaded,TResult? Function( _ChatConvError value)?  error,}){
final _that = this;
switch (_that) {
case _ChatConvInitial() when initial != null:
return initial(_that);case _ChatConvLoading() when loading != null:
return loading(_that);case _ChatConvLoaded() when loaded != null:
return loaded(_that);case _ChatConvError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ChatConversationEnriched> items,  bool isRefreshing,  String? errorMessage)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConvInitial() when initial != null:
return initial();case _ChatConvLoading() when loading != null:
return loading();case _ChatConvLoaded() when loaded != null:
return loaded(_that.items,_that.isRefreshing,_that.errorMessage);case _ChatConvError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ChatConversationEnriched> items,  bool isRefreshing,  String? errorMessage)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _ChatConvInitial():
return initial();case _ChatConvLoading():
return loading();case _ChatConvLoaded():
return loaded(_that.items,_that.isRefreshing,_that.errorMessage);case _ChatConvError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ChatConversationEnriched> items,  bool isRefreshing,  String? errorMessage)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _ChatConvInitial() when initial != null:
return initial();case _ChatConvLoading() when loading != null:
return loading();case _ChatConvLoaded() when loaded != null:
return loaded(_that.items,_that.isRefreshing,_that.errorMessage);case _ChatConvError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatConvInitial implements ChatConversationsListState {
  const _ChatConvInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConvInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationsListState.initial()';
}


}




/// @nodoc


class _ChatConvLoading implements ChatConversationsListState {
  const _ChatConvLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConvLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatConversationsListState.loading()';
}


}




/// @nodoc


class _ChatConvLoaded implements ChatConversationsListState {
  const _ChatConvLoaded({final  List<ChatConversationEnriched> items = const <ChatConversationEnriched>[], this.isRefreshing = false, this.errorMessage}): _items = items;
  

 final  List<ChatConversationEnriched> _items;
@JsonKey() List<ChatConversationEnriched> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  bool isRefreshing;
 final  String? errorMessage;

/// Create a copy of ChatConversationsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConvLoadedCopyWith<_ChatConvLoaded> get copyWith => __$ChatConvLoadedCopyWithImpl<_ChatConvLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConvLoaded&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isRefreshing,errorMessage);

@override
String toString() {
  return 'ChatConversationsListState.loaded(items: $items, isRefreshing: $isRefreshing, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ChatConvLoadedCopyWith<$Res> implements $ChatConversationsListStateCopyWith<$Res> {
  factory _$ChatConvLoadedCopyWith(_ChatConvLoaded value, $Res Function(_ChatConvLoaded) _then) = __$ChatConvLoadedCopyWithImpl;
@useResult
$Res call({
 List<ChatConversationEnriched> items, bool isRefreshing, String? errorMessage
});




}
/// @nodoc
class __$ChatConvLoadedCopyWithImpl<$Res>
    implements _$ChatConvLoadedCopyWith<$Res> {
  __$ChatConvLoadedCopyWithImpl(this._self, this._then);

  final _ChatConvLoaded _self;
  final $Res Function(_ChatConvLoaded) _then;

/// Create a copy of ChatConversationsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isRefreshing = null,Object? errorMessage = freezed,}) {
  return _then(_ChatConvLoaded(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatConversationEnriched>,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ChatConvError implements ChatConversationsListState {
  const _ChatConvError(this.message);
  

 final  String message;

/// Create a copy of ChatConversationsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConvErrorCopyWith<_ChatConvError> get copyWith => __$ChatConvErrorCopyWithImpl<_ChatConvError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConvError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatConversationsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatConvErrorCopyWith<$Res> implements $ChatConversationsListStateCopyWith<$Res> {
  factory _$ChatConvErrorCopyWith(_ChatConvError value, $Res Function(_ChatConvError) _then) = __$ChatConvErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ChatConvErrorCopyWithImpl<$Res>
    implements _$ChatConvErrorCopyWith<$Res> {
  __$ChatConvErrorCopyWithImpl(this._self, this._then);

  final _ChatConvError _self;
  final $Res Function(_ChatConvError) _then;

/// Create a copy of ChatConversationsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ChatConvError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

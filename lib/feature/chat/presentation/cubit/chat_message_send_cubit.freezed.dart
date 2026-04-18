// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_send_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessageSendState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageSendState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageSendState()';
}


}

/// @nodoc
class $ChatMessageSendStateCopyWith<$Res>  {
$ChatMessageSendStateCopyWith(ChatMessageSendState _, $Res Function(ChatMessageSendState) __);
}


/// Adds pattern-matching-related methods to [ChatMessageSendState].
extension ChatMessageSendStatePatterns on ChatMessageSendState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ChatSendIdle value)?  idle,TResult Function( _ChatSendSending value)?  sending,TResult Function( _ChatSendSent value)?  sent,TResult Function( _ChatSendFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSendIdle() when idle != null:
return idle(_that);case _ChatSendSending() when sending != null:
return sending(_that);case _ChatSendSent() when sent != null:
return sent(_that);case _ChatSendFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ChatSendIdle value)  idle,required TResult Function( _ChatSendSending value)  sending,required TResult Function( _ChatSendSent value)  sent,required TResult Function( _ChatSendFailure value)  failure,}){
final _that = this;
switch (_that) {
case _ChatSendIdle():
return idle(_that);case _ChatSendSending():
return sending(_that);case _ChatSendSent():
return sent(_that);case _ChatSendFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ChatSendIdle value)?  idle,TResult? Function( _ChatSendSending value)?  sending,TResult? Function( _ChatSendSent value)?  sent,TResult? Function( _ChatSendFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _ChatSendIdle() when idle != null:
return idle(_that);case _ChatSendSending() when sending != null:
return sending(_that);case _ChatSendSent() when sent != null:
return sent(_that);case _ChatSendFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  sending,TResult Function( String messageId)?  sent,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSendIdle() when idle != null:
return idle();case _ChatSendSending() when sending != null:
return sending();case _ChatSendSent() when sent != null:
return sent(_that.messageId);case _ChatSendFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  sending,required TResult Function( String messageId)  sent,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _ChatSendIdle():
return idle();case _ChatSendSending():
return sending();case _ChatSendSent():
return sent(_that.messageId);case _ChatSendFailure():
return failure(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  sending,TResult? Function( String messageId)?  sent,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _ChatSendIdle() when idle != null:
return idle();case _ChatSendSending() when sending != null:
return sending();case _ChatSendSent() when sent != null:
return sent(_that.messageId);case _ChatSendFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSendIdle implements ChatMessageSendState {
  const _ChatSendIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSendIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageSendState.idle()';
}


}




/// @nodoc


class _ChatSendSending implements ChatMessageSendState {
  const _ChatSendSending();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSendSending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageSendState.sending()';
}


}




/// @nodoc


class _ChatSendSent implements ChatMessageSendState {
  const _ChatSendSent(this.messageId);
  

 final  String messageId;

/// Create a copy of ChatMessageSendState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSendSentCopyWith<_ChatSendSent> get copyWith => __$ChatSendSentCopyWithImpl<_ChatSendSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSendSent&&(identical(other.messageId, messageId) || other.messageId == messageId));
}


@override
int get hashCode => Object.hash(runtimeType,messageId);

@override
String toString() {
  return 'ChatMessageSendState.sent(messageId: $messageId)';
}


}

/// @nodoc
abstract mixin class _$ChatSendSentCopyWith<$Res> implements $ChatMessageSendStateCopyWith<$Res> {
  factory _$ChatSendSentCopyWith(_ChatSendSent value, $Res Function(_ChatSendSent) _then) = __$ChatSendSentCopyWithImpl;
@useResult
$Res call({
 String messageId
});




}
/// @nodoc
class __$ChatSendSentCopyWithImpl<$Res>
    implements _$ChatSendSentCopyWith<$Res> {
  __$ChatSendSentCopyWithImpl(this._self, this._then);

  final _ChatSendSent _self;
  final $Res Function(_ChatSendSent) _then;

/// Create a copy of ChatMessageSendState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messageId = null,}) {
  return _then(_ChatSendSent(
null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ChatSendFailure implements ChatMessageSendState {
  const _ChatSendFailure(this.message);
  

 final  String message;

/// Create a copy of ChatMessageSendState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSendFailureCopyWith<_ChatSendFailure> get copyWith => __$ChatSendFailureCopyWithImpl<_ChatSendFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSendFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatMessageSendState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatSendFailureCopyWith<$Res> implements $ChatMessageSendStateCopyWith<$Res> {
  factory _$ChatSendFailureCopyWith(_ChatSendFailure value, $Res Function(_ChatSendFailure) _then) = __$ChatSendFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ChatSendFailureCopyWithImpl<$Res>
    implements _$ChatSendFailureCopyWith<$Res> {
  __$ChatSendFailureCopyWithImpl(this._self, this._then);

  final _ChatSendFailure _self;
  final $Res Function(_ChatSendFailure) _then;

/// Create a copy of ChatMessageSendState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ChatSendFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

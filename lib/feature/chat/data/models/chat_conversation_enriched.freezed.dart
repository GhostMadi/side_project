// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation_enriched.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatConversationEnriched {

 ChatConversationModel get conversation; ChatProfileMiniModel? get otherUser; ChatMessageModel? get lastMessage; int get unreadCount;
/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationEnrichedCopyWith<ChatConversationEnriched> get copyWith => _$ChatConversationEnrichedCopyWithImpl<ChatConversationEnriched>(this as ChatConversationEnriched, _$identity);

  /// Serializes this ChatConversationEnriched to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationEnriched&&(identical(other.conversation, conversation) || other.conversation == conversation)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversation,otherUser,lastMessage,unreadCount);

@override
String toString() {
  return 'ChatConversationEnriched(conversation: $conversation, otherUser: $otherUser, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ChatConversationEnrichedCopyWith<$Res>  {
  factory $ChatConversationEnrichedCopyWith(ChatConversationEnriched value, $Res Function(ChatConversationEnriched) _then) = _$ChatConversationEnrichedCopyWithImpl;
@useResult
$Res call({
 ChatConversationModel conversation, ChatProfileMiniModel? otherUser, ChatMessageModel? lastMessage, int unreadCount
});


$ChatConversationModelCopyWith<$Res> get conversation;$ChatProfileMiniModelCopyWith<$Res>? get otherUser;$ChatMessageModelCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$ChatConversationEnrichedCopyWithImpl<$Res>
    implements $ChatConversationEnrichedCopyWith<$Res> {
  _$ChatConversationEnrichedCopyWithImpl(this._self, this._then);

  final ChatConversationEnriched _self;
  final $Res Function(ChatConversationEnriched) _then;

/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversation = null,Object? otherUser = freezed,Object? lastMessage = freezed,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ChatConversationModel,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as ChatProfileMiniModel?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as ChatMessageModel?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatConversationModelCopyWith<$Res> get conversation {
  
  return $ChatConversationModelCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatProfileMiniModelCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $ChatProfileMiniModelCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageModelCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $ChatMessageModelCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatConversationEnriched].
extension ChatConversationEnrichedPatterns on ChatConversationEnriched {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversationEnriched value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversationEnriched() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversationEnriched value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversationEnriched():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversationEnriched value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversationEnriched() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatConversationModel conversation,  ChatProfileMiniModel? otherUser,  ChatMessageModel? lastMessage,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversationEnriched() when $default != null:
return $default(_that.conversation,_that.otherUser,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatConversationModel conversation,  ChatProfileMiniModel? otherUser,  ChatMessageModel? lastMessage,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _ChatConversationEnriched():
return $default(_that.conversation,_that.otherUser,_that.lastMessage,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatConversationModel conversation,  ChatProfileMiniModel? otherUser,  ChatMessageModel? lastMessage,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversationEnriched() when $default != null:
return $default(_that.conversation,_that.otherUser,_that.lastMessage,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversationEnriched implements ChatConversationEnriched {
  const _ChatConversationEnriched({required this.conversation, this.otherUser, this.lastMessage, this.unreadCount = 0});
  factory _ChatConversationEnriched.fromJson(Map<String, dynamic> json) => _$ChatConversationEnrichedFromJson(json);

@override final  ChatConversationModel conversation;
@override final  ChatProfileMiniModel? otherUser;
@override final  ChatMessageModel? lastMessage;
@override@JsonKey() final  int unreadCount;

/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationEnrichedCopyWith<_ChatConversationEnriched> get copyWith => __$ChatConversationEnrichedCopyWithImpl<_ChatConversationEnriched>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationEnrichedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversationEnriched&&(identical(other.conversation, conversation) || other.conversation == conversation)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversation,otherUser,lastMessage,unreadCount);

@override
String toString() {
  return 'ChatConversationEnriched(conversation: $conversation, otherUser: $otherUser, lastMessage: $lastMessage, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationEnrichedCopyWith<$Res> implements $ChatConversationEnrichedCopyWith<$Res> {
  factory _$ChatConversationEnrichedCopyWith(_ChatConversationEnriched value, $Res Function(_ChatConversationEnriched) _then) = __$ChatConversationEnrichedCopyWithImpl;
@override @useResult
$Res call({
 ChatConversationModel conversation, ChatProfileMiniModel? otherUser, ChatMessageModel? lastMessage, int unreadCount
});


@override $ChatConversationModelCopyWith<$Res> get conversation;@override $ChatProfileMiniModelCopyWith<$Res>? get otherUser;@override $ChatMessageModelCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$ChatConversationEnrichedCopyWithImpl<$Res>
    implements _$ChatConversationEnrichedCopyWith<$Res> {
  __$ChatConversationEnrichedCopyWithImpl(this._self, this._then);

  final _ChatConversationEnriched _self;
  final $Res Function(_ChatConversationEnriched) _then;

/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversation = null,Object? otherUser = freezed,Object? lastMessage = freezed,Object? unreadCount = null,}) {
  return _then(_ChatConversationEnriched(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ChatConversationModel,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as ChatProfileMiniModel?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as ChatMessageModel?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatConversationModelCopyWith<$Res> get conversation {
  
  return $ChatConversationModelCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatProfileMiniModelCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $ChatProfileMiniModelCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}/// Create a copy of ChatConversationEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageModelCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $ChatMessageModelCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}

// dart format on

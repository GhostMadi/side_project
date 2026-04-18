// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatThreadItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatThreadItem()';
}


}

/// @nodoc
class $ChatThreadItemCopyWith<$Res>  {
$ChatThreadItemCopyWith(ChatThreadItem _, $Res Function(ChatThreadItem) __);
}


/// Adds pattern-matching-related methods to [ChatThreadItem].
extension ChatThreadItemPatterns on ChatThreadItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ChatThreadServer value)?  server,TResult Function( _ChatThreadOptimisticText value)?  optimisticText,TResult Function( _ChatThreadOptimisticAttachments value)?  optimisticAttachments,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadServer() when server != null:
return server(_that);case _ChatThreadOptimisticText() when optimisticText != null:
return optimisticText(_that);case _ChatThreadOptimisticAttachments() when optimisticAttachments != null:
return optimisticAttachments(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ChatThreadServer value)  server,required TResult Function( _ChatThreadOptimisticText value)  optimisticText,required TResult Function( _ChatThreadOptimisticAttachments value)  optimisticAttachments,}){
final _that = this;
switch (_that) {
case _ChatThreadServer():
return server(_that);case _ChatThreadOptimisticText():
return optimisticText(_that);case _ChatThreadOptimisticAttachments():
return optimisticAttachments(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ChatThreadServer value)?  server,TResult? Function( _ChatThreadOptimisticText value)?  optimisticText,TResult? Function( _ChatThreadOptimisticAttachments value)?  optimisticAttachments,}){
final _that = this;
switch (_that) {
case _ChatThreadServer() when server != null:
return server(_that);case _ChatThreadOptimisticText() when optimisticText != null:
return optimisticText(_that);case _ChatThreadOptimisticAttachments() when optimisticAttachments != null:
return optimisticAttachments(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ChatMessageEnriched data)?  server,TResult Function( String localId,  String conversationId,  String text,  DateTime createdAt,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)?  optimisticText,TResult Function( String localId,  String conversationId,  DateTime createdAt,  List<ChatOptimisticOutgoingPart> parts,  String? caption,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)?  optimisticAttachments,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadServer() when server != null:
return server(_that.data);case _ChatThreadOptimisticText() when optimisticText != null:
return optimisticText(_that.localId,_that.conversationId,_that.text,_that.createdAt,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _ChatThreadOptimisticAttachments() when optimisticAttachments != null:
return optimisticAttachments(_that.localId,_that.conversationId,_that.createdAt,_that.parts,_that.caption,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ChatMessageEnriched data)  server,required TResult Function( String localId,  String conversationId,  String text,  DateTime createdAt,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)  optimisticText,required TResult Function( String localId,  String conversationId,  DateTime createdAt,  List<ChatOptimisticOutgoingPart> parts,  String? caption,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)  optimisticAttachments,}) {final _that = this;
switch (_that) {
case _ChatThreadServer():
return server(_that.data);case _ChatThreadOptimisticText():
return optimisticText(_that.localId,_that.conversationId,_that.text,_that.createdAt,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _ChatThreadOptimisticAttachments():
return optimisticAttachments(_that.localId,_that.conversationId,_that.createdAt,_that.parts,_that.caption,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ChatMessageEnriched data)?  server,TResult? Function( String localId,  String conversationId,  String text,  DateTime createdAt,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)?  optimisticText,TResult? Function( String localId,  String conversationId,  DateTime createdAt,  List<ChatOptimisticOutgoingPart> parts,  String? caption,  ChatMessageEnriched? server,  ChatOptimisticDelivery delivery,  String? replyToMessageId,  ChatReplyPreview? quotedPreview,  String? quotedSenderLabel)?  optimisticAttachments,}) {final _that = this;
switch (_that) {
case _ChatThreadServer() when server != null:
return server(_that.data);case _ChatThreadOptimisticText() when optimisticText != null:
return optimisticText(_that.localId,_that.conversationId,_that.text,_that.createdAt,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _ChatThreadOptimisticAttachments() when optimisticAttachments != null:
return optimisticAttachments(_that.localId,_that.conversationId,_that.createdAt,_that.parts,_that.caption,_that.server,_that.delivery,_that.replyToMessageId,_that.quotedPreview,_that.quotedSenderLabel);case _:
  return null;

}
}

}

/// @nodoc


class _ChatThreadServer implements ChatThreadItem {
  const _ChatThreadServer(this.data);
  

 final  ChatMessageEnriched data;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadServerCopyWith<_ChatThreadServer> get copyWith => __$ChatThreadServerCopyWithImpl<_ChatThreadServer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadServer&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ChatThreadItem.server(data: $data)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadServerCopyWith<$Res> implements $ChatThreadItemCopyWith<$Res> {
  factory _$ChatThreadServerCopyWith(_ChatThreadServer value, $Res Function(_ChatThreadServer) _then) = __$ChatThreadServerCopyWithImpl;
@useResult
$Res call({
 ChatMessageEnriched data
});


$ChatMessageEnrichedCopyWith<$Res> get data;

}
/// @nodoc
class __$ChatThreadServerCopyWithImpl<$Res>
    implements _$ChatThreadServerCopyWith<$Res> {
  __$ChatThreadServerCopyWithImpl(this._self, this._then);

  final _ChatThreadServer _self;
  final $Res Function(_ChatThreadServer) _then;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_ChatThreadServer(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ChatMessageEnriched,
  ));
}

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageEnrichedCopyWith<$Res> get data {
  
  return $ChatMessageEnrichedCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _ChatThreadOptimisticText implements ChatThreadItem {
  const _ChatThreadOptimisticText({required this.localId, required this.conversationId, required this.text, required this.createdAt, this.server, this.delivery = ChatOptimisticDelivery.sending, this.replyToMessageId, this.quotedPreview, this.quotedSenderLabel});
  

 final  String localId;
 final  String conversationId;
 final  String text;
 final  DateTime createdAt;
 final  ChatMessageEnriched? server;
@JsonKey() final  ChatOptimisticDelivery delivery;
/// [send_message(..., p_reply_to)] и превью цитаты в пузырьке до прихода с сервера.
 final  String? replyToMessageId;
 final  ChatReplyPreview? quotedPreview;
 final  String? quotedSenderLabel;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadOptimisticTextCopyWith<_ChatThreadOptimisticText> get copyWith => __$ChatThreadOptimisticTextCopyWithImpl<_ChatThreadOptimisticText>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadOptimisticText&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.server, server) || other.server == server)&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.quotedPreview, quotedPreview) || other.quotedPreview == quotedPreview)&&(identical(other.quotedSenderLabel, quotedSenderLabel) || other.quotedSenderLabel == quotedSenderLabel));
}


@override
int get hashCode => Object.hash(runtimeType,localId,conversationId,text,createdAt,server,delivery,replyToMessageId,quotedPreview,quotedSenderLabel);

@override
String toString() {
  return 'ChatThreadItem.optimisticText(localId: $localId, conversationId: $conversationId, text: $text, createdAt: $createdAt, server: $server, delivery: $delivery, replyToMessageId: $replyToMessageId, quotedPreview: $quotedPreview, quotedSenderLabel: $quotedSenderLabel)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadOptimisticTextCopyWith<$Res> implements $ChatThreadItemCopyWith<$Res> {
  factory _$ChatThreadOptimisticTextCopyWith(_ChatThreadOptimisticText value, $Res Function(_ChatThreadOptimisticText) _then) = __$ChatThreadOptimisticTextCopyWithImpl;
@useResult
$Res call({
 String localId, String conversationId, String text, DateTime createdAt, ChatMessageEnriched? server, ChatOptimisticDelivery delivery, String? replyToMessageId, ChatReplyPreview? quotedPreview, String? quotedSenderLabel
});


$ChatMessageEnrichedCopyWith<$Res>? get server;$ChatReplyPreviewCopyWith<$Res>? get quotedPreview;

}
/// @nodoc
class __$ChatThreadOptimisticTextCopyWithImpl<$Res>
    implements _$ChatThreadOptimisticTextCopyWith<$Res> {
  __$ChatThreadOptimisticTextCopyWithImpl(this._self, this._then);

  final _ChatThreadOptimisticText _self;
  final $Res Function(_ChatThreadOptimisticText) _then;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? localId = null,Object? conversationId = null,Object? text = null,Object? createdAt = null,Object? server = freezed,Object? delivery = null,Object? replyToMessageId = freezed,Object? quotedPreview = freezed,Object? quotedSenderLabel = freezed,}) {
  return _then(_ChatThreadOptimisticText(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as ChatMessageEnriched?,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as ChatOptimisticDelivery,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,quotedPreview: freezed == quotedPreview ? _self.quotedPreview : quotedPreview // ignore: cast_nullable_to_non_nullable
as ChatReplyPreview?,quotedSenderLabel: freezed == quotedSenderLabel ? _self.quotedSenderLabel : quotedSenderLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageEnrichedCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $ChatMessageEnrichedCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatReplyPreviewCopyWith<$Res>? get quotedPreview {
    if (_self.quotedPreview == null) {
    return null;
  }

  return $ChatReplyPreviewCopyWith<$Res>(_self.quotedPreview!, (value) {
    return _then(_self.copyWith(quotedPreview: value));
  });
}
}

/// @nodoc


class _ChatThreadOptimisticAttachments implements ChatThreadItem {
  const _ChatThreadOptimisticAttachments({required this.localId, required this.conversationId, required this.createdAt, required final  List<ChatOptimisticOutgoingPart> parts, this.caption, this.server, this.delivery = ChatOptimisticDelivery.sending, this.replyToMessageId, this.quotedPreview, this.quotedSenderLabel}): _parts = parts;
  

 final  String localId;
 final  String conversationId;
 final  DateTime createdAt;
 final  List<ChatOptimisticOutgoingPart> _parts;
 List<ChatOptimisticOutgoingPart> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}

 final  String? caption;
 final  ChatMessageEnriched? server;
@JsonKey() final  ChatOptimisticDelivery delivery;
 final  String? replyToMessageId;
 final  ChatReplyPreview? quotedPreview;
 final  String? quotedSenderLabel;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadOptimisticAttachmentsCopyWith<_ChatThreadOptimisticAttachments> get copyWith => __$ChatThreadOptimisticAttachmentsCopyWithImpl<_ChatThreadOptimisticAttachments>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadOptimisticAttachments&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._parts, _parts)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.server, server) || other.server == server)&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.quotedPreview, quotedPreview) || other.quotedPreview == quotedPreview)&&(identical(other.quotedSenderLabel, quotedSenderLabel) || other.quotedSenderLabel == quotedSenderLabel));
}


@override
int get hashCode => Object.hash(runtimeType,localId,conversationId,createdAt,const DeepCollectionEquality().hash(_parts),caption,server,delivery,replyToMessageId,quotedPreview,quotedSenderLabel);

@override
String toString() {
  return 'ChatThreadItem.optimisticAttachments(localId: $localId, conversationId: $conversationId, createdAt: $createdAt, parts: $parts, caption: $caption, server: $server, delivery: $delivery, replyToMessageId: $replyToMessageId, quotedPreview: $quotedPreview, quotedSenderLabel: $quotedSenderLabel)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadOptimisticAttachmentsCopyWith<$Res> implements $ChatThreadItemCopyWith<$Res> {
  factory _$ChatThreadOptimisticAttachmentsCopyWith(_ChatThreadOptimisticAttachments value, $Res Function(_ChatThreadOptimisticAttachments) _then) = __$ChatThreadOptimisticAttachmentsCopyWithImpl;
@useResult
$Res call({
 String localId, String conversationId, DateTime createdAt, List<ChatOptimisticOutgoingPart> parts, String? caption, ChatMessageEnriched? server, ChatOptimisticDelivery delivery, String? replyToMessageId, ChatReplyPreview? quotedPreview, String? quotedSenderLabel
});


$ChatMessageEnrichedCopyWith<$Res>? get server;$ChatReplyPreviewCopyWith<$Res>? get quotedPreview;

}
/// @nodoc
class __$ChatThreadOptimisticAttachmentsCopyWithImpl<$Res>
    implements _$ChatThreadOptimisticAttachmentsCopyWith<$Res> {
  __$ChatThreadOptimisticAttachmentsCopyWithImpl(this._self, this._then);

  final _ChatThreadOptimisticAttachments _self;
  final $Res Function(_ChatThreadOptimisticAttachments) _then;

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? localId = null,Object? conversationId = null,Object? createdAt = null,Object? parts = null,Object? caption = freezed,Object? server = freezed,Object? delivery = null,Object? replyToMessageId = freezed,Object? quotedPreview = freezed,Object? quotedSenderLabel = freezed,}) {
  return _then(_ChatThreadOptimisticAttachments(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<ChatOptimisticOutgoingPart>,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as ChatMessageEnriched?,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as ChatOptimisticDelivery,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,quotedPreview: freezed == quotedPreview ? _self.quotedPreview : quotedPreview // ignore: cast_nullable_to_non_nullable
as ChatReplyPreview?,quotedSenderLabel: freezed == quotedSenderLabel ? _self.quotedSenderLabel : quotedSenderLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageEnrichedCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $ChatMessageEnrichedCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}/// Create a copy of ChatThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatReplyPreviewCopyWith<$Res>? get quotedPreview {
    if (_self.quotedPreview == null) {
    return null;
  }

  return $ChatReplyPreviewCopyWith<$Res>(_self.quotedPreview!, (value) {
    return _then(_self.copyWith(quotedPreview: value));
  });
}
}

// dart format on

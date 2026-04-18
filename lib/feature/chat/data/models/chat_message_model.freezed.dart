// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageModel {

 String get id;@JsonKey(name: 'conversation_id') String get conversationId;@JsonKey(name: 'sender_id') String get senderId; String get kind;// 'text'|'media'|'file'|'post_ref'|'system'
 String? get text;@JsonKey(name: 'reply_to_message_id') String? get replyToMessageId;@JsonKey(name: 'forwarded_from_message_id') String? get forwardedFromMessageId;/// UUID с клиента для merge optimistic ↔ server без эвристик (send_message).
@JsonKey(name: 'client_message_id') String? get clientMessageId;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'edited_at') DateTime? get editedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of ChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageModelCopyWith<ChatMessageModel> get copyWith => _$ChatMessageModelCopyWithImpl<ChatMessageModel>(this as ChatMessageModel, _$identity);

  /// Serializes this ChatMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.forwardedFromMessageId, forwardedFromMessageId) || other.forwardedFromMessageId == forwardedFromMessageId)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,kind,text,replyToMessageId,forwardedFromMessageId,clientMessageId,createdAt,editedAt,deletedAt);

@override
String toString() {
  return 'ChatMessageModel(id: $id, conversationId: $conversationId, senderId: $senderId, kind: $kind, text: $text, replyToMessageId: $replyToMessageId, forwardedFromMessageId: $forwardedFromMessageId, clientMessageId: $clientMessageId, createdAt: $createdAt, editedAt: $editedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageModelCopyWith<$Res>  {
  factory $ChatMessageModelCopyWith(ChatMessageModel value, $Res Function(ChatMessageModel) _then) = _$ChatMessageModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'sender_id') String senderId, String kind, String? text,@JsonKey(name: 'reply_to_message_id') String? replyToMessageId,@JsonKey(name: 'forwarded_from_message_id') String? forwardedFromMessageId,@JsonKey(name: 'client_message_id') String? clientMessageId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'edited_at') DateTime? editedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class _$ChatMessageModelCopyWithImpl<$Res>
    implements $ChatMessageModelCopyWith<$Res> {
  _$ChatMessageModelCopyWithImpl(this._self, this._then);

  final ChatMessageModel _self;
  final $Res Function(ChatMessageModel) _then;

/// Create a copy of ChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? kind = null,Object? text = freezed,Object? replyToMessageId = freezed,Object? forwardedFromMessageId = freezed,Object? clientMessageId = freezed,Object? createdAt = null,Object? editedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedFromMessageId: freezed == forwardedFromMessageId ? _self.forwardedFromMessageId : forwardedFromMessageId // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageModel].
extension ChatMessageModelPatterns on ChatMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String kind,  String? text, @JsonKey(name: 'reply_to_message_id')  String? replyToMessageId, @JsonKey(name: 'forwarded_from_message_id')  String? forwardedFromMessageId, @JsonKey(name: 'client_message_id')  String? clientMessageId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageModel() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.kind,_that.text,_that.replyToMessageId,_that.forwardedFromMessageId,_that.clientMessageId,_that.createdAt,_that.editedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String kind,  String? text, @JsonKey(name: 'reply_to_message_id')  String? replyToMessageId, @JsonKey(name: 'forwarded_from_message_id')  String? forwardedFromMessageId, @JsonKey(name: 'client_message_id')  String? clientMessageId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageModel():
return $default(_that.id,_that.conversationId,_that.senderId,_that.kind,_that.text,_that.replyToMessageId,_that.forwardedFromMessageId,_that.clientMessageId,_that.createdAt,_that.editedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String kind,  String? text, @JsonKey(name: 'reply_to_message_id')  String? replyToMessageId, @JsonKey(name: 'forwarded_from_message_id')  String? forwardedFromMessageId, @JsonKey(name: 'client_message_id')  String? clientMessageId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'edited_at')  DateTime? editedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageModel() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.kind,_that.text,_that.replyToMessageId,_that.forwardedFromMessageId,_that.clientMessageId,_that.createdAt,_that.editedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageModel implements ChatMessageModel {
  const _ChatMessageModel({required this.id, @JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(name: 'sender_id') required this.senderId, required this.kind, this.text, @JsonKey(name: 'reply_to_message_id') this.replyToMessageId, @JsonKey(name: 'forwarded_from_message_id') this.forwardedFromMessageId, @JsonKey(name: 'client_message_id') this.clientMessageId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'edited_at') this.editedAt, @JsonKey(name: 'deleted_at') this.deletedAt});
  factory _ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'conversation_id') final  String conversationId;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override final  String kind;
// 'text'|'media'|'file'|'post_ref'|'system'
@override final  String? text;
@override@JsonKey(name: 'reply_to_message_id') final  String? replyToMessageId;
@override@JsonKey(name: 'forwarded_from_message_id') final  String? forwardedFromMessageId;
/// UUID с клиента для merge optimistic ↔ server без эвристик (send_message).
@override@JsonKey(name: 'client_message_id') final  String? clientMessageId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'edited_at') final  DateTime? editedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of ChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageModelCopyWith<_ChatMessageModel> get copyWith => __$ChatMessageModelCopyWithImpl<_ChatMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.forwardedFromMessageId, forwardedFromMessageId) || other.forwardedFromMessageId == forwardedFromMessageId)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,kind,text,replyToMessageId,forwardedFromMessageId,clientMessageId,createdAt,editedAt,deletedAt);

@override
String toString() {
  return 'ChatMessageModel(id: $id, conversationId: $conversationId, senderId: $senderId, kind: $kind, text: $text, replyToMessageId: $replyToMessageId, forwardedFromMessageId: $forwardedFromMessageId, clientMessageId: $clientMessageId, createdAt: $createdAt, editedAt: $editedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageModelCopyWith<$Res> implements $ChatMessageModelCopyWith<$Res> {
  factory _$ChatMessageModelCopyWith(_ChatMessageModel value, $Res Function(_ChatMessageModel) _then) = __$ChatMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'sender_id') String senderId, String kind, String? text,@JsonKey(name: 'reply_to_message_id') String? replyToMessageId,@JsonKey(name: 'forwarded_from_message_id') String? forwardedFromMessageId,@JsonKey(name: 'client_message_id') String? clientMessageId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'edited_at') DateTime? editedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class __$ChatMessageModelCopyWithImpl<$Res>
    implements _$ChatMessageModelCopyWith<$Res> {
  __$ChatMessageModelCopyWithImpl(this._self, this._then);

  final _ChatMessageModel _self;
  final $Res Function(_ChatMessageModel) _then;

/// Create a copy of ChatMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? kind = null,Object? text = freezed,Object? replyToMessageId = freezed,Object? forwardedFromMessageId = freezed,Object? clientMessageId = freezed,Object? createdAt = null,Object? editedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_ChatMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedFromMessageId: freezed == forwardedFromMessageId ? _self.forwardedFromMessageId : forwardedFromMessageId // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

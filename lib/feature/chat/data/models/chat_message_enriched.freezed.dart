// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_enriched.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatReactionSummary {

 String get emoji; int get count;
/// Create a copy of ChatReactionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatReactionSummaryCopyWith<ChatReactionSummary> get copyWith => _$ChatReactionSummaryCopyWithImpl<ChatReactionSummary>(this as ChatReactionSummary, _$identity);

  /// Serializes this ChatReactionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatReactionSummary&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,count);

@override
String toString() {
  return 'ChatReactionSummary(emoji: $emoji, count: $count)';
}


}

/// @nodoc
abstract mixin class $ChatReactionSummaryCopyWith<$Res>  {
  factory $ChatReactionSummaryCopyWith(ChatReactionSummary value, $Res Function(ChatReactionSummary) _then) = _$ChatReactionSummaryCopyWithImpl;
@useResult
$Res call({
 String emoji, int count
});




}
/// @nodoc
class _$ChatReactionSummaryCopyWithImpl<$Res>
    implements $ChatReactionSummaryCopyWith<$Res> {
  _$ChatReactionSummaryCopyWithImpl(this._self, this._then);

  final ChatReactionSummary _self;
  final $Res Function(ChatReactionSummary) _then;

/// Create a copy of ChatReactionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? count = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatReactionSummary].
extension ChatReactionSummaryPatterns on ChatReactionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatReactionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatReactionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatReactionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ChatReactionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatReactionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ChatReactionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatReactionSummary() when $default != null:
return $default(_that.emoji,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  int count)  $default,) {final _that = this;
switch (_that) {
case _ChatReactionSummary():
return $default(_that.emoji,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  int count)?  $default,) {final _that = this;
switch (_that) {
case _ChatReactionSummary() when $default != null:
return $default(_that.emoji,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatReactionSummary implements ChatReactionSummary {
  const _ChatReactionSummary({required this.emoji, required this.count});
  factory _ChatReactionSummary.fromJson(Map<String, dynamic> json) => _$ChatReactionSummaryFromJson(json);

@override final  String emoji;
@override final  int count;

/// Create a copy of ChatReactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatReactionSummaryCopyWith<_ChatReactionSummary> get copyWith => __$ChatReactionSummaryCopyWithImpl<_ChatReactionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatReactionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatReactionSummary&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,count);

@override
String toString() {
  return 'ChatReactionSummary(emoji: $emoji, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ChatReactionSummaryCopyWith<$Res> implements $ChatReactionSummaryCopyWith<$Res> {
  factory _$ChatReactionSummaryCopyWith(_ChatReactionSummary value, $Res Function(_ChatReactionSummary) _then) = __$ChatReactionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String emoji, int count
});




}
/// @nodoc
class __$ChatReactionSummaryCopyWithImpl<$Res>
    implements _$ChatReactionSummaryCopyWith<$Res> {
  __$ChatReactionSummaryCopyWithImpl(this._self, this._then);

  final _ChatReactionSummary _self;
  final $Res Function(_ChatReactionSummary) _then;

/// Create a copy of ChatReactionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? count = null,}) {
  return _then(_ChatReactionSummary(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChatReplyPreview {

 String get id;@JsonKey(name: 'sender_id') String get senderId; String? get text; String get kind;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of ChatReplyPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatReplyPreviewCopyWith<ChatReplyPreview> get copyWith => _$ChatReplyPreviewCopyWithImpl<ChatReplyPreview>(this as ChatReplyPreview, _$identity);

  /// Serializes this ChatReplyPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatReplyPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,text,kind,createdAt);

@override
String toString() {
  return 'ChatReplyPreview(id: $id, senderId: $senderId, text: $text, kind: $kind, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatReplyPreviewCopyWith<$Res>  {
  factory $ChatReplyPreviewCopyWith(ChatReplyPreview value, $Res Function(ChatReplyPreview) _then) = _$ChatReplyPreviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId, String? text, String kind,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$ChatReplyPreviewCopyWithImpl<$Res>
    implements $ChatReplyPreviewCopyWith<$Res> {
  _$ChatReplyPreviewCopyWithImpl(this._self, this._then);

  final ChatReplyPreview _self;
  final $Res Function(ChatReplyPreview) _then;

/// Create a copy of ChatReplyPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? text = freezed,Object? kind = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatReplyPreview].
extension ChatReplyPreviewPatterns on ChatReplyPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatReplyPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatReplyPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatReplyPreview value)  $default,){
final _that = this;
switch (_that) {
case _ChatReplyPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatReplyPreview value)?  $default,){
final _that = this;
switch (_that) {
case _ChatReplyPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String? text,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatReplyPreview() when $default != null:
return $default(_that.id,_that.senderId,_that.text,_that.kind,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String? text,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatReplyPreview():
return $default(_that.id,_that.senderId,_that.text,_that.kind,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'sender_id')  String senderId,  String? text,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatReplyPreview() when $default != null:
return $default(_that.id,_that.senderId,_that.text,_that.kind,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatReplyPreview implements ChatReplyPreview {
  const _ChatReplyPreview({required this.id, @JsonKey(name: 'sender_id') required this.senderId, this.text, required this.kind, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ChatReplyPreview.fromJson(Map<String, dynamic> json) => _$ChatReplyPreviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override final  String? text;
@override final  String kind;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of ChatReplyPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatReplyPreviewCopyWith<_ChatReplyPreview> get copyWith => __$ChatReplyPreviewCopyWithImpl<_ChatReplyPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatReplyPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatReplyPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,text,kind,createdAt);

@override
String toString() {
  return 'ChatReplyPreview(id: $id, senderId: $senderId, text: $text, kind: $kind, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatReplyPreviewCopyWith<$Res> implements $ChatReplyPreviewCopyWith<$Res> {
  factory _$ChatReplyPreviewCopyWith(_ChatReplyPreview value, $Res Function(_ChatReplyPreview) _then) = __$ChatReplyPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId, String? text, String kind,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$ChatReplyPreviewCopyWithImpl<$Res>
    implements _$ChatReplyPreviewCopyWith<$Res> {
  __$ChatReplyPreviewCopyWithImpl(this._self, this._then);

  final _ChatReplyPreview _self;
  final $Res Function(_ChatReplyPreview) _then;

/// Create a copy of ChatReplyPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? text = freezed,Object? kind = null,Object? createdAt = null,}) {
  return _then(_ChatReplyPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ChatPostRef {

@JsonKey(name: 'post_id') String get postId; String? get caption;
/// Create a copy of ChatPostRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatPostRefCopyWith<ChatPostRef> get copyWith => _$ChatPostRefCopyWithImpl<ChatPostRef>(this as ChatPostRef, _$identity);

  /// Serializes this ChatPostRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatPostRef&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.caption, caption) || other.caption == caption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,caption);

@override
String toString() {
  return 'ChatPostRef(postId: $postId, caption: $caption)';
}


}

/// @nodoc
abstract mixin class $ChatPostRefCopyWith<$Res>  {
  factory $ChatPostRefCopyWith(ChatPostRef value, $Res Function(ChatPostRef) _then) = _$ChatPostRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'post_id') String postId, String? caption
});




}
/// @nodoc
class _$ChatPostRefCopyWithImpl<$Res>
    implements $ChatPostRefCopyWith<$Res> {
  _$ChatPostRefCopyWithImpl(this._self, this._then);

  final ChatPostRef _self;
  final $Res Function(ChatPostRef) _then;

/// Create a copy of ChatPostRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? caption = freezed,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatPostRef].
extension ChatPostRefPatterns on ChatPostRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatPostRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatPostRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatPostRef value)  $default,){
final _that = this;
switch (_that) {
case _ChatPostRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatPostRef value)?  $default,){
final _that = this;
switch (_that) {
case _ChatPostRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id')  String postId,  String? caption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatPostRef() when $default != null:
return $default(_that.postId,_that.caption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id')  String postId,  String? caption)  $default,) {final _that = this;
switch (_that) {
case _ChatPostRef():
return $default(_that.postId,_that.caption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'post_id')  String postId,  String? caption)?  $default,) {final _that = this;
switch (_that) {
case _ChatPostRef() when $default != null:
return $default(_that.postId,_that.caption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatPostRef implements ChatPostRef {
  const _ChatPostRef({@JsonKey(name: 'post_id') required this.postId, this.caption});
  factory _ChatPostRef.fromJson(Map<String, dynamic> json) => _$ChatPostRefFromJson(json);

@override@JsonKey(name: 'post_id') final  String postId;
@override final  String? caption;

/// Create a copy of ChatPostRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatPostRefCopyWith<_ChatPostRef> get copyWith => __$ChatPostRefCopyWithImpl<_ChatPostRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatPostRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatPostRef&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.caption, caption) || other.caption == caption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,caption);

@override
String toString() {
  return 'ChatPostRef(postId: $postId, caption: $caption)';
}


}

/// @nodoc
abstract mixin class _$ChatPostRefCopyWith<$Res> implements $ChatPostRefCopyWith<$Res> {
  factory _$ChatPostRefCopyWith(_ChatPostRef value, $Res Function(_ChatPostRef) _then) = __$ChatPostRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'post_id') String postId, String? caption
});




}
/// @nodoc
class __$ChatPostRefCopyWithImpl<$Res>
    implements _$ChatPostRefCopyWith<$Res> {
  __$ChatPostRefCopyWithImpl(this._self, this._then);

  final _ChatPostRef _self;
  final $Res Function(_ChatPostRef) _then;

/// Create a copy of ChatPostRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? caption = freezed,}) {
  return _then(_ChatPostRef(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatMessageEnriched {

 ChatMessageModel get message; ChatProfileMiniModel get sender;@JsonKey(name: 'reply_preview') ChatReplyPreview? get replyPreview; List<ChatReactionSummary> get reactions; List<ChatMessageAttachmentModel> get attachments;@JsonKey(name: 'post_ref') ChatPostRef? get postRef;
/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageEnrichedCopyWith<ChatMessageEnriched> get copyWith => _$ChatMessageEnrichedCopyWithImpl<ChatMessageEnriched>(this as ChatMessageEnriched, _$identity);

  /// Serializes this ChatMessageEnriched to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageEnriched&&(identical(other.message, message) || other.message == message)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.replyPreview, replyPreview) || other.replyPreview == replyPreview)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.postRef, postRef) || other.postRef == postRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,sender,replyPreview,const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(attachments),postRef);

@override
String toString() {
  return 'ChatMessageEnriched(message: $message, sender: $sender, replyPreview: $replyPreview, reactions: $reactions, attachments: $attachments, postRef: $postRef)';
}


}

/// @nodoc
abstract mixin class $ChatMessageEnrichedCopyWith<$Res>  {
  factory $ChatMessageEnrichedCopyWith(ChatMessageEnriched value, $Res Function(ChatMessageEnriched) _then) = _$ChatMessageEnrichedCopyWithImpl;
@useResult
$Res call({
 ChatMessageModel message, ChatProfileMiniModel sender,@JsonKey(name: 'reply_preview') ChatReplyPreview? replyPreview, List<ChatReactionSummary> reactions, List<ChatMessageAttachmentModel> attachments,@JsonKey(name: 'post_ref') ChatPostRef? postRef
});


$ChatMessageModelCopyWith<$Res> get message;$ChatProfileMiniModelCopyWith<$Res> get sender;$ChatReplyPreviewCopyWith<$Res>? get replyPreview;$ChatPostRefCopyWith<$Res>? get postRef;

}
/// @nodoc
class _$ChatMessageEnrichedCopyWithImpl<$Res>
    implements $ChatMessageEnrichedCopyWith<$Res> {
  _$ChatMessageEnrichedCopyWithImpl(this._self, this._then);

  final ChatMessageEnriched _self;
  final $Res Function(ChatMessageEnriched) _then;

/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? sender = null,Object? replyPreview = freezed,Object? reactions = null,Object? attachments = null,Object? postRef = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ChatMessageModel,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as ChatProfileMiniModel,replyPreview: freezed == replyPreview ? _self.replyPreview : replyPreview // ignore: cast_nullable_to_non_nullable
as ChatReplyPreview?,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<ChatReactionSummary>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ChatMessageAttachmentModel>,postRef: freezed == postRef ? _self.postRef : postRef // ignore: cast_nullable_to_non_nullable
as ChatPostRef?,
  ));
}
/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageModelCopyWith<$Res> get message {
  
  return $ChatMessageModelCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatProfileMiniModelCopyWith<$Res> get sender {
  
  return $ChatProfileMiniModelCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatReplyPreviewCopyWith<$Res>? get replyPreview {
    if (_self.replyPreview == null) {
    return null;
  }

  return $ChatReplyPreviewCopyWith<$Res>(_self.replyPreview!, (value) {
    return _then(_self.copyWith(replyPreview: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatPostRefCopyWith<$Res>? get postRef {
    if (_self.postRef == null) {
    return null;
  }

  return $ChatPostRefCopyWith<$Res>(_self.postRef!, (value) {
    return _then(_self.copyWith(postRef: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatMessageEnriched].
extension ChatMessageEnrichedPatterns on ChatMessageEnriched {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageEnriched value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageEnriched() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageEnriched value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageEnriched():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageEnriched value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageEnriched() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatMessageModel message,  ChatProfileMiniModel sender, @JsonKey(name: 'reply_preview')  ChatReplyPreview? replyPreview,  List<ChatReactionSummary> reactions,  List<ChatMessageAttachmentModel> attachments, @JsonKey(name: 'post_ref')  ChatPostRef? postRef)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageEnriched() when $default != null:
return $default(_that.message,_that.sender,_that.replyPreview,_that.reactions,_that.attachments,_that.postRef);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatMessageModel message,  ChatProfileMiniModel sender, @JsonKey(name: 'reply_preview')  ChatReplyPreview? replyPreview,  List<ChatReactionSummary> reactions,  List<ChatMessageAttachmentModel> attachments, @JsonKey(name: 'post_ref')  ChatPostRef? postRef)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageEnriched():
return $default(_that.message,_that.sender,_that.replyPreview,_that.reactions,_that.attachments,_that.postRef);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatMessageModel message,  ChatProfileMiniModel sender, @JsonKey(name: 'reply_preview')  ChatReplyPreview? replyPreview,  List<ChatReactionSummary> reactions,  List<ChatMessageAttachmentModel> attachments, @JsonKey(name: 'post_ref')  ChatPostRef? postRef)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageEnriched() when $default != null:
return $default(_that.message,_that.sender,_that.replyPreview,_that.reactions,_that.attachments,_that.postRef);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageEnriched implements ChatMessageEnriched {
  const _ChatMessageEnriched({required this.message, required this.sender, @JsonKey(name: 'reply_preview') this.replyPreview, final  List<ChatReactionSummary> reactions = const <ChatReactionSummary>[], final  List<ChatMessageAttachmentModel> attachments = const <ChatMessageAttachmentModel>[], @JsonKey(name: 'post_ref') this.postRef}): _reactions = reactions,_attachments = attachments;
  factory _ChatMessageEnriched.fromJson(Map<String, dynamic> json) => _$ChatMessageEnrichedFromJson(json);

@override final  ChatMessageModel message;
@override final  ChatProfileMiniModel sender;
@override@JsonKey(name: 'reply_preview') final  ChatReplyPreview? replyPreview;
 final  List<ChatReactionSummary> _reactions;
@override@JsonKey() List<ChatReactionSummary> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

 final  List<ChatMessageAttachmentModel> _attachments;
@override@JsonKey() List<ChatMessageAttachmentModel> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey(name: 'post_ref') final  ChatPostRef? postRef;

/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageEnrichedCopyWith<_ChatMessageEnriched> get copyWith => __$ChatMessageEnrichedCopyWithImpl<_ChatMessageEnriched>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageEnrichedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageEnriched&&(identical(other.message, message) || other.message == message)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.replyPreview, replyPreview) || other.replyPreview == replyPreview)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.postRef, postRef) || other.postRef == postRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,sender,replyPreview,const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_attachments),postRef);

@override
String toString() {
  return 'ChatMessageEnriched(message: $message, sender: $sender, replyPreview: $replyPreview, reactions: $reactions, attachments: $attachments, postRef: $postRef)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageEnrichedCopyWith<$Res> implements $ChatMessageEnrichedCopyWith<$Res> {
  factory _$ChatMessageEnrichedCopyWith(_ChatMessageEnriched value, $Res Function(_ChatMessageEnriched) _then) = __$ChatMessageEnrichedCopyWithImpl;
@override @useResult
$Res call({
 ChatMessageModel message, ChatProfileMiniModel sender,@JsonKey(name: 'reply_preview') ChatReplyPreview? replyPreview, List<ChatReactionSummary> reactions, List<ChatMessageAttachmentModel> attachments,@JsonKey(name: 'post_ref') ChatPostRef? postRef
});


@override $ChatMessageModelCopyWith<$Res> get message;@override $ChatProfileMiniModelCopyWith<$Res> get sender;@override $ChatReplyPreviewCopyWith<$Res>? get replyPreview;@override $ChatPostRefCopyWith<$Res>? get postRef;

}
/// @nodoc
class __$ChatMessageEnrichedCopyWithImpl<$Res>
    implements _$ChatMessageEnrichedCopyWith<$Res> {
  __$ChatMessageEnrichedCopyWithImpl(this._self, this._then);

  final _ChatMessageEnriched _self;
  final $Res Function(_ChatMessageEnriched) _then;

/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? sender = null,Object? replyPreview = freezed,Object? reactions = null,Object? attachments = null,Object? postRef = freezed,}) {
  return _then(_ChatMessageEnriched(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ChatMessageModel,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as ChatProfileMiniModel,replyPreview: freezed == replyPreview ? _self.replyPreview : replyPreview // ignore: cast_nullable_to_non_nullable
as ChatReplyPreview?,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<ChatReactionSummary>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ChatMessageAttachmentModel>,postRef: freezed == postRef ? _self.postRef : postRef // ignore: cast_nullable_to_non_nullable
as ChatPostRef?,
  ));
}

/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatMessageModelCopyWith<$Res> get message {
  
  return $ChatMessageModelCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatProfileMiniModelCopyWith<$Res> get sender {
  
  return $ChatProfileMiniModelCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatReplyPreviewCopyWith<$Res>? get replyPreview {
    if (_self.replyPreview == null) {
    return null;
  }

  return $ChatReplyPreviewCopyWith<$Res>(_self.replyPreview!, (value) {
    return _then(_self.copyWith(replyPreview: value));
  });
}/// Create a copy of ChatMessageEnriched
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatPostRefCopyWith<$Res>? get postRef {
    if (_self.postRef == null) {
    return null;
  }

  return $ChatPostRefCopyWith<$Res>(_self.postRef!, (value) {
    return _then(_self.copyWith(postRef: value));
  });
}
}

// dart format on

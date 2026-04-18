// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_comment_composer_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCommentComposerState {

 String get draft; bool get isSending; String? get errorMessage;/// Ответ на комментарий; если null — публикуется корневой комментарий.
 String? get replyParentCommentId; String? get replyParentLabel;
/// Create a copy of PostCommentComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCommentComposerStateCopyWith<PostCommentComposerState> get copyWith => _$PostCommentComposerStateCopyWithImpl<PostCommentComposerState>(this as PostCommentComposerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCommentComposerState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.replyParentCommentId, replyParentCommentId) || other.replyParentCommentId == replyParentCommentId)&&(identical(other.replyParentLabel, replyParentLabel) || other.replyParentLabel == replyParentLabel));
}


@override
int get hashCode => Object.hash(runtimeType,draft,isSending,errorMessage,replyParentCommentId,replyParentLabel);

@override
String toString() {
  return 'PostCommentComposerState(draft: $draft, isSending: $isSending, errorMessage: $errorMessage, replyParentCommentId: $replyParentCommentId, replyParentLabel: $replyParentLabel)';
}


}

/// @nodoc
abstract mixin class $PostCommentComposerStateCopyWith<$Res>  {
  factory $PostCommentComposerStateCopyWith(PostCommentComposerState value, $Res Function(PostCommentComposerState) _then) = _$PostCommentComposerStateCopyWithImpl;
@useResult
$Res call({
 String draft, bool isSending, String? errorMessage, String? replyParentCommentId, String? replyParentLabel
});




}
/// @nodoc
class _$PostCommentComposerStateCopyWithImpl<$Res>
    implements $PostCommentComposerStateCopyWith<$Res> {
  _$PostCommentComposerStateCopyWithImpl(this._self, this._then);

  final PostCommentComposerState _self;
  final $Res Function(PostCommentComposerState) _then;

/// Create a copy of PostCommentComposerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = null,Object? isSending = null,Object? errorMessage = freezed,Object? replyParentCommentId = freezed,Object? replyParentLabel = freezed,}) {
  return _then(_self.copyWith(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,replyParentCommentId: freezed == replyParentCommentId ? _self.replyParentCommentId : replyParentCommentId // ignore: cast_nullable_to_non_nullable
as String?,replyParentLabel: freezed == replyParentLabel ? _self.replyParentLabel : replyParentLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostCommentComposerState].
extension PostCommentComposerStatePatterns on PostCommentComposerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostCommentComposerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostCommentComposerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostCommentComposerState value)  $default,){
final _that = this;
switch (_that) {
case _PostCommentComposerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostCommentComposerState value)?  $default,){
final _that = this;
switch (_that) {
case _PostCommentComposerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String draft,  bool isSending,  String? errorMessage,  String? replyParentCommentId,  String? replyParentLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostCommentComposerState() when $default != null:
return $default(_that.draft,_that.isSending,_that.errorMessage,_that.replyParentCommentId,_that.replyParentLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String draft,  bool isSending,  String? errorMessage,  String? replyParentCommentId,  String? replyParentLabel)  $default,) {final _that = this;
switch (_that) {
case _PostCommentComposerState():
return $default(_that.draft,_that.isSending,_that.errorMessage,_that.replyParentCommentId,_that.replyParentLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String draft,  bool isSending,  String? errorMessage,  String? replyParentCommentId,  String? replyParentLabel)?  $default,) {final _that = this;
switch (_that) {
case _PostCommentComposerState() when $default != null:
return $default(_that.draft,_that.isSending,_that.errorMessage,_that.replyParentCommentId,_that.replyParentLabel);case _:
  return null;

}
}

}

/// @nodoc


class _PostCommentComposerState implements PostCommentComposerState {
  const _PostCommentComposerState({this.draft = '', this.isSending = false, this.errorMessage, this.replyParentCommentId, this.replyParentLabel});
  

@override@JsonKey() final  String draft;
@override@JsonKey() final  bool isSending;
@override final  String? errorMessage;
/// Ответ на комментарий; если null — публикуется корневой комментарий.
@override final  String? replyParentCommentId;
@override final  String? replyParentLabel;

/// Create a copy of PostCommentComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCommentComposerStateCopyWith<_PostCommentComposerState> get copyWith => __$PostCommentComposerStateCopyWithImpl<_PostCommentComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCommentComposerState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.replyParentCommentId, replyParentCommentId) || other.replyParentCommentId == replyParentCommentId)&&(identical(other.replyParentLabel, replyParentLabel) || other.replyParentLabel == replyParentLabel));
}


@override
int get hashCode => Object.hash(runtimeType,draft,isSending,errorMessage,replyParentCommentId,replyParentLabel);

@override
String toString() {
  return 'PostCommentComposerState(draft: $draft, isSending: $isSending, errorMessage: $errorMessage, replyParentCommentId: $replyParentCommentId, replyParentLabel: $replyParentLabel)';
}


}

/// @nodoc
abstract mixin class _$PostCommentComposerStateCopyWith<$Res> implements $PostCommentComposerStateCopyWith<$Res> {
  factory _$PostCommentComposerStateCopyWith(_PostCommentComposerState value, $Res Function(_PostCommentComposerState) _then) = __$PostCommentComposerStateCopyWithImpl;
@override @useResult
$Res call({
 String draft, bool isSending, String? errorMessage, String? replyParentCommentId, String? replyParentLabel
});




}
/// @nodoc
class __$PostCommentComposerStateCopyWithImpl<$Res>
    implements _$PostCommentComposerStateCopyWith<$Res> {
  __$PostCommentComposerStateCopyWithImpl(this._self, this._then);

  final _PostCommentComposerState _self;
  final $Res Function(_PostCommentComposerState) _then;

/// Create a copy of PostCommentComposerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? isSending = null,Object? errorMessage = freezed,Object? replyParentCommentId = freezed,Object? replyParentLabel = freezed,}) {
  return _then(_PostCommentComposerState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,replyParentCommentId: freezed == replyParentCommentId ? _self.replyParentCommentId : replyParentCommentId // ignore: cast_nullable_to_non_nullable
as String?,replyParentLabel: freezed == replyParentLabel ? _self.replyParentLabel : replyParentLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

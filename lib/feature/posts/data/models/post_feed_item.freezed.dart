// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostFeedItem {

 PostModel get post; String? get authorUsername; String? get authorAvatarUrl;/// `like` | `dislike` | null
 String? get myReactionKind; bool get mySaved;
/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFeedItemCopyWith<PostFeedItem> get copyWith => _$PostFeedItemCopyWithImpl<PostFeedItem>(this as PostFeedItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFeedItem&&(identical(other.post, post) || other.post == post)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.myReactionKind, myReactionKind) || other.myReactionKind == myReactionKind)&&(identical(other.mySaved, mySaved) || other.mySaved == mySaved));
}


@override
int get hashCode => Object.hash(runtimeType,post,authorUsername,authorAvatarUrl,myReactionKind,mySaved);

@override
String toString() {
  return 'PostFeedItem(post: $post, authorUsername: $authorUsername, authorAvatarUrl: $authorAvatarUrl, myReactionKind: $myReactionKind, mySaved: $mySaved)';
}


}

/// @nodoc
abstract mixin class $PostFeedItemCopyWith<$Res>  {
  factory $PostFeedItemCopyWith(PostFeedItem value, $Res Function(PostFeedItem) _then) = _$PostFeedItemCopyWithImpl;
@useResult
$Res call({
 PostModel post, String? authorUsername, String? authorAvatarUrl, String? myReactionKind, bool mySaved
});


$PostModelCopyWith<$Res> get post;

}
/// @nodoc
class _$PostFeedItemCopyWithImpl<$Res>
    implements $PostFeedItemCopyWith<$Res> {
  _$PostFeedItemCopyWithImpl(this._self, this._then);

  final PostFeedItem _self;
  final $Res Function(PostFeedItem) _then;

/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? authorUsername = freezed,Object? authorAvatarUrl = freezed,Object? myReactionKind = freezed,Object? mySaved = null,}) {
  return _then(_self.copyWith(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as PostModel,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,myReactionKind: freezed == myReactionKind ? _self.myReactionKind : myReactionKind // ignore: cast_nullable_to_non_nullable
as String?,mySaved: null == mySaved ? _self.mySaved : mySaved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostModelCopyWith<$Res> get post {
  
  return $PostModelCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostFeedItem].
extension PostFeedItemPatterns on PostFeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFeedItem value)  $default,){
final _that = this;
switch (_that) {
case _PostFeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _PostFeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostModel post,  String? authorUsername,  String? authorAvatarUrl,  String? myReactionKind,  bool mySaved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFeedItem() when $default != null:
return $default(_that.post,_that.authorUsername,_that.authorAvatarUrl,_that.myReactionKind,_that.mySaved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostModel post,  String? authorUsername,  String? authorAvatarUrl,  String? myReactionKind,  bool mySaved)  $default,) {final _that = this;
switch (_that) {
case _PostFeedItem():
return $default(_that.post,_that.authorUsername,_that.authorAvatarUrl,_that.myReactionKind,_that.mySaved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostModel post,  String? authorUsername,  String? authorAvatarUrl,  String? myReactionKind,  bool mySaved)?  $default,) {final _that = this;
switch (_that) {
case _PostFeedItem() when $default != null:
return $default(_that.post,_that.authorUsername,_that.authorAvatarUrl,_that.myReactionKind,_that.mySaved);case _:
  return null;

}
}

}

/// @nodoc


class _PostFeedItem implements PostFeedItem {
  const _PostFeedItem({required this.post, this.authorUsername, this.authorAvatarUrl, this.myReactionKind, this.mySaved = false});
  

@override final  PostModel post;
@override final  String? authorUsername;
@override final  String? authorAvatarUrl;
/// `like` | `dislike` | null
@override final  String? myReactionKind;
@override@JsonKey() final  bool mySaved;

/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFeedItemCopyWith<_PostFeedItem> get copyWith => __$PostFeedItemCopyWithImpl<_PostFeedItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFeedItem&&(identical(other.post, post) || other.post == post)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.myReactionKind, myReactionKind) || other.myReactionKind == myReactionKind)&&(identical(other.mySaved, mySaved) || other.mySaved == mySaved));
}


@override
int get hashCode => Object.hash(runtimeType,post,authorUsername,authorAvatarUrl,myReactionKind,mySaved);

@override
String toString() {
  return 'PostFeedItem(post: $post, authorUsername: $authorUsername, authorAvatarUrl: $authorAvatarUrl, myReactionKind: $myReactionKind, mySaved: $mySaved)';
}


}

/// @nodoc
abstract mixin class _$PostFeedItemCopyWith<$Res> implements $PostFeedItemCopyWith<$Res> {
  factory _$PostFeedItemCopyWith(_PostFeedItem value, $Res Function(_PostFeedItem) _then) = __$PostFeedItemCopyWithImpl;
@override @useResult
$Res call({
 PostModel post, String? authorUsername, String? authorAvatarUrl, String? myReactionKind, bool mySaved
});


@override $PostModelCopyWith<$Res> get post;

}
/// @nodoc
class __$PostFeedItemCopyWithImpl<$Res>
    implements _$PostFeedItemCopyWith<$Res> {
  __$PostFeedItemCopyWithImpl(this._self, this._then);

  final _PostFeedItem _self;
  final $Res Function(_PostFeedItem) _then;

/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? authorUsername = freezed,Object? authorAvatarUrl = freezed,Object? myReactionKind = freezed,Object? mySaved = null,}) {
  return _then(_PostFeedItem(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as PostModel,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,myReactionKind: freezed == myReactionKind ? _self.myReactionKind : myReactionKind // ignore: cast_nullable_to_non_nullable
as String?,mySaved: null == mySaved ? _self.mySaved : mySaved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PostFeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostModelCopyWith<$Res> get post {
  
  return $PostModelCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}

// dart format on

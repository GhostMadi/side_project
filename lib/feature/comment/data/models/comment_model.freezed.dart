// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentAuthorSnippet {

 String? get username; String? get avatarUrl;
/// Create a copy of CommentAuthorSnippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentAuthorSnippetCopyWith<CommentAuthorSnippet> get copyWith => _$CommentAuthorSnippetCopyWithImpl<CommentAuthorSnippet>(this as CommentAuthorSnippet, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentAuthorSnippet&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,username,avatarUrl);

@override
String toString() {
  return 'CommentAuthorSnippet(username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $CommentAuthorSnippetCopyWith<$Res>  {
  factory $CommentAuthorSnippetCopyWith(CommentAuthorSnippet value, $Res Function(CommentAuthorSnippet) _then) = _$CommentAuthorSnippetCopyWithImpl;
@useResult
$Res call({
 String? username, String? avatarUrl
});




}
/// @nodoc
class _$CommentAuthorSnippetCopyWithImpl<$Res>
    implements $CommentAuthorSnippetCopyWith<$Res> {
  _$CommentAuthorSnippetCopyWithImpl(this._self, this._then);

  final CommentAuthorSnippet _self;
  final $Res Function(CommentAuthorSnippet) _then;

/// Create a copy of CommentAuthorSnippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentAuthorSnippet].
extension CommentAuthorSnippetPatterns on CommentAuthorSnippet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentAuthorSnippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentAuthorSnippet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentAuthorSnippet value)  $default,){
final _that = this;
switch (_that) {
case _CommentAuthorSnippet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentAuthorSnippet value)?  $default,){
final _that = this;
switch (_that) {
case _CommentAuthorSnippet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? username,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentAuthorSnippet() when $default != null:
return $default(_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? username,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _CommentAuthorSnippet():
return $default(_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? username,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _CommentAuthorSnippet() when $default != null:
return $default(_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _CommentAuthorSnippet implements CommentAuthorSnippet {
  const _CommentAuthorSnippet({this.username, this.avatarUrl});
  

@override final  String? username;
@override final  String? avatarUrl;

/// Create a copy of CommentAuthorSnippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentAuthorSnippetCopyWith<_CommentAuthorSnippet> get copyWith => __$CommentAuthorSnippetCopyWithImpl<_CommentAuthorSnippet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentAuthorSnippet&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,username,avatarUrl);

@override
String toString() {
  return 'CommentAuthorSnippet(username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$CommentAuthorSnippetCopyWith<$Res> implements $CommentAuthorSnippetCopyWith<$Res> {
  factory _$CommentAuthorSnippetCopyWith(_CommentAuthorSnippet value, $Res Function(_CommentAuthorSnippet) _then) = __$CommentAuthorSnippetCopyWithImpl;
@override @useResult
$Res call({
 String? username, String? avatarUrl
});




}
/// @nodoc
class __$CommentAuthorSnippetCopyWithImpl<$Res>
    implements _$CommentAuthorSnippetCopyWith<$Res> {
  __$CommentAuthorSnippetCopyWithImpl(this._self, this._then);

  final _CommentAuthorSnippet _self;
  final $Res Function(_CommentAuthorSnippet) _then;

/// Create a copy of CommentAuthorSnippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_CommentAuthorSnippet(
username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CommentModel {

 String get id; String get postId; String get userId; String get text; String? get parentCommentId; int get likesCount; int get dislikesCount;/// Прямые ответы (неудалённые); с сервера `replies_count`.
 int get repliesCount; DateTime get createdAt; DateTime? get editedAt; bool get isDeleted; CommentAuthorSnippet? get author;
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentModelCopyWith<CommentModel> get copyWith => _$CommentModelCopyWithImpl<CommentModel>(this as CommentModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.parentCommentId, parentCommentId) || other.parentCommentId == parentCommentId)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.dislikesCount, dislikesCount) || other.dislikesCount == dislikesCount)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.author, author) || other.author == author));
}


@override
int get hashCode => Object.hash(runtimeType,id,postId,userId,text,parentCommentId,likesCount,dislikesCount,repliesCount,createdAt,editedAt,isDeleted,author);

@override
String toString() {
  return 'CommentModel(id: $id, postId: $postId, userId: $userId, text: $text, parentCommentId: $parentCommentId, likesCount: $likesCount, dislikesCount: $dislikesCount, repliesCount: $repliesCount, createdAt: $createdAt, editedAt: $editedAt, isDeleted: $isDeleted, author: $author)';
}


}

/// @nodoc
abstract mixin class $CommentModelCopyWith<$Res>  {
  factory $CommentModelCopyWith(CommentModel value, $Res Function(CommentModel) _then) = _$CommentModelCopyWithImpl;
@useResult
$Res call({
 String id, String postId, String userId, String text, String? parentCommentId, int likesCount, int dislikesCount, int repliesCount, DateTime createdAt, DateTime? editedAt, bool isDeleted, CommentAuthorSnippet? author
});


$CommentAuthorSnippetCopyWith<$Res>? get author;

}
/// @nodoc
class _$CommentModelCopyWithImpl<$Res>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._self, this._then);

  final CommentModel _self;
  final $Res Function(CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? userId = null,Object? text = null,Object? parentCommentId = freezed,Object? likesCount = null,Object? dislikesCount = null,Object? repliesCount = null,Object? createdAt = null,Object? editedAt = freezed,Object? isDeleted = null,Object? author = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,parentCommentId: freezed == parentCommentId ? _self.parentCommentId : parentCommentId // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,dislikesCount: null == dislikesCount ? _self.dislikesCount : dislikesCount // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as CommentAuthorSnippet?,
  ));
}
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAuthorSnippetCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $CommentAuthorSnippetCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentModel].
extension CommentModelPatterns on CommentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentModel value)  $default,){
final _that = this;
switch (_that) {
case _CommentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  String userId,  String text,  String? parentCommentId,  int likesCount,  int dislikesCount,  int repliesCount,  DateTime createdAt,  DateTime? editedAt,  bool isDeleted,  CommentAuthorSnippet? author)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.postId,_that.userId,_that.text,_that.parentCommentId,_that.likesCount,_that.dislikesCount,_that.repliesCount,_that.createdAt,_that.editedAt,_that.isDeleted,_that.author);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  String userId,  String text,  String? parentCommentId,  int likesCount,  int dislikesCount,  int repliesCount,  DateTime createdAt,  DateTime? editedAt,  bool isDeleted,  CommentAuthorSnippet? author)  $default,) {final _that = this;
switch (_that) {
case _CommentModel():
return $default(_that.id,_that.postId,_that.userId,_that.text,_that.parentCommentId,_that.likesCount,_that.dislikesCount,_that.repliesCount,_that.createdAt,_that.editedAt,_that.isDeleted,_that.author);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  String userId,  String text,  String? parentCommentId,  int likesCount,  int dislikesCount,  int repliesCount,  DateTime createdAt,  DateTime? editedAt,  bool isDeleted,  CommentAuthorSnippet? author)?  $default,) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.id,_that.postId,_that.userId,_that.text,_that.parentCommentId,_that.likesCount,_that.dislikesCount,_that.repliesCount,_that.createdAt,_that.editedAt,_that.isDeleted,_that.author);case _:
  return null;

}
}

}

/// @nodoc


class _CommentModel implements CommentModel {
  const _CommentModel({required this.id, required this.postId, required this.userId, required this.text, this.parentCommentId, required this.likesCount, this.dislikesCount = 0, this.repliesCount = 0, required this.createdAt, this.editedAt, required this.isDeleted, this.author});
  

@override final  String id;
@override final  String postId;
@override final  String userId;
@override final  String text;
@override final  String? parentCommentId;
@override final  int likesCount;
@override@JsonKey() final  int dislikesCount;
/// Прямые ответы (неудалённые); с сервера `replies_count`.
@override@JsonKey() final  int repliesCount;
@override final  DateTime createdAt;
@override final  DateTime? editedAt;
@override final  bool isDeleted;
@override final  CommentAuthorSnippet? author;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentModelCopyWith<_CommentModel> get copyWith => __$CommentModelCopyWithImpl<_CommentModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.text, text) || other.text == text)&&(identical(other.parentCommentId, parentCommentId) || other.parentCommentId == parentCommentId)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.dislikesCount, dislikesCount) || other.dislikesCount == dislikesCount)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.author, author) || other.author == author));
}


@override
int get hashCode => Object.hash(runtimeType,id,postId,userId,text,parentCommentId,likesCount,dislikesCount,repliesCount,createdAt,editedAt,isDeleted,author);

@override
String toString() {
  return 'CommentModel(id: $id, postId: $postId, userId: $userId, text: $text, parentCommentId: $parentCommentId, likesCount: $likesCount, dislikesCount: $dislikesCount, repliesCount: $repliesCount, createdAt: $createdAt, editedAt: $editedAt, isDeleted: $isDeleted, author: $author)';
}


}

/// @nodoc
abstract mixin class _$CommentModelCopyWith<$Res> implements $CommentModelCopyWith<$Res> {
  factory _$CommentModelCopyWith(_CommentModel value, $Res Function(_CommentModel) _then) = __$CommentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, String userId, String text, String? parentCommentId, int likesCount, int dislikesCount, int repliesCount, DateTime createdAt, DateTime? editedAt, bool isDeleted, CommentAuthorSnippet? author
});


@override $CommentAuthorSnippetCopyWith<$Res>? get author;

}
/// @nodoc
class __$CommentModelCopyWithImpl<$Res>
    implements _$CommentModelCopyWith<$Res> {
  __$CommentModelCopyWithImpl(this._self, this._then);

  final _CommentModel _self;
  final $Res Function(_CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? userId = null,Object? text = null,Object? parentCommentId = freezed,Object? likesCount = null,Object? dislikesCount = null,Object? repliesCount = null,Object? createdAt = null,Object? editedAt = freezed,Object? isDeleted = null,Object? author = freezed,}) {
  return _then(_CommentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,parentCommentId: freezed == parentCommentId ? _self.parentCommentId : parentCommentId // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,dislikesCount: null == dislikesCount ? _self.dislikesCount : dislikesCount // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as CommentAuthorSnippet?,
  ));
}

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAuthorSnippetCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $CommentAuthorSnippetCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on

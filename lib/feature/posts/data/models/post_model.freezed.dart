// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'cluster_id') String? get clusterId; String? get title; String? get subtitle; String? get description;@JsonKey(name: 'is_archived') bool get isArchived;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'comments_count') int get commentsCount;@JsonKey(name: 'saves_count') int get savesCount;@JsonKey(name: 'sends_count') int get sendsCount;@JsonKey(name: 'views_count') int get viewsCount;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'post_media') List<PostMediaModel> get media;
/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostModelCopyWith<PostModel> get copyWith => _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.savesCount, savesCount) || other.savesCount == savesCount)&&(identical(other.sendsCount, sendsCount) || other.sendsCount == sendsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.media, media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,clusterId,title,subtitle,description,isArchived,deletedAt,likesCount,commentsCount,savesCount,sendsCount,viewsCount,createdAt,updatedAt,const DeepCollectionEquality().hash(media));

@override
String toString() {
  return 'PostModel(id: $id, userId: $userId, clusterId: $clusterId, title: $title, subtitle: $subtitle, description: $description, isArchived: $isArchived, deletedAt: $deletedAt, likesCount: $likesCount, commentsCount: $commentsCount, savesCount: $savesCount, sendsCount: $sendsCount, viewsCount: $viewsCount, createdAt: $createdAt, updatedAt: $updatedAt, media: $media)';
}


}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res>  {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) = _$PostModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'cluster_id') String? clusterId, String? title, String? subtitle, String? description,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'saves_count') int savesCount,@JsonKey(name: 'sends_count') int sendsCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'post_media') List<PostMediaModel> media
});




}
/// @nodoc
class _$PostModelCopyWithImpl<$Res>
    implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? clusterId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? isArchived = null,Object? deletedAt = freezed,Object? likesCount = null,Object? commentsCount = null,Object? savesCount = null,Object? sendsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? updatedAt = null,Object? media = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,savesCount: null == savesCount ? _self.savesCount : savesCount // ignore: cast_nullable_to_non_nullable
as int,sendsCount: null == sendsCount ? _self.sendsCount : sendsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<PostMediaModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PostModel].
extension PostModelPatterns on PostModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostModel value)  $default,){
final _that = this;
switch (_that) {
case _PostModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostModel value)?  $default,){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'cluster_id')  String? clusterId,  String? title,  String? subtitle,  String? description, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'saves_count')  int savesCount, @JsonKey(name: 'sends_count')  int sendsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'post_media')  List<PostMediaModel> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.id,_that.userId,_that.clusterId,_that.title,_that.subtitle,_that.description,_that.isArchived,_that.deletedAt,_that.likesCount,_that.commentsCount,_that.savesCount,_that.sendsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'cluster_id')  String? clusterId,  String? title,  String? subtitle,  String? description, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'saves_count')  int savesCount, @JsonKey(name: 'sends_count')  int sendsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'post_media')  List<PostMediaModel> media)  $default,) {final _that = this;
switch (_that) {
case _PostModel():
return $default(_that.id,_that.userId,_that.clusterId,_that.title,_that.subtitle,_that.description,_that.isArchived,_that.deletedAt,_that.likesCount,_that.commentsCount,_that.savesCount,_that.sendsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'cluster_id')  String? clusterId,  String? title,  String? subtitle,  String? description, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'saves_count')  int savesCount, @JsonKey(name: 'sends_count')  int sendsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'post_media')  List<PostMediaModel> media)?  $default,) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.id,_that.userId,_that.clusterId,_that.title,_that.subtitle,_that.description,_that.isArchived,_that.deletedAt,_that.likesCount,_that.commentsCount,_that.savesCount,_that.sendsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostModel implements PostModel {
  const _PostModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'cluster_id') this.clusterId, this.title, this.subtitle, this.description, @JsonKey(name: 'is_archived') required this.isArchived, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'likes_count') required this.likesCount, @JsonKey(name: 'comments_count') required this.commentsCount, @JsonKey(name: 'saves_count') required this.savesCount, @JsonKey(name: 'sends_count') required this.sendsCount, @JsonKey(name: 'views_count') required this.viewsCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'post_media') final  List<PostMediaModel> media = const []}): _media = media;
  factory _PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'cluster_id') final  String? clusterId;
@override final  String? title;
@override final  String? subtitle;
@override final  String? description;
@override@JsonKey(name: 'is_archived') final  bool isArchived;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'comments_count') final  int commentsCount;
@override@JsonKey(name: 'saves_count') final  int savesCount;
@override@JsonKey(name: 'sends_count') final  int sendsCount;
@override@JsonKey(name: 'views_count') final  int viewsCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
 final  List<PostMediaModel> _media;
@override@JsonKey(name: 'post_media') List<PostMediaModel> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostModelCopyWith<_PostModel> get copyWith => __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.savesCount, savesCount) || other.savesCount == savesCount)&&(identical(other.sendsCount, sendsCount) || other.sendsCount == sendsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._media, _media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,clusterId,title,subtitle,description,isArchived,deletedAt,likesCount,commentsCount,savesCount,sendsCount,viewsCount,createdAt,updatedAt,const DeepCollectionEquality().hash(_media));

@override
String toString() {
  return 'PostModel(id: $id, userId: $userId, clusterId: $clusterId, title: $title, subtitle: $subtitle, description: $description, isArchived: $isArchived, deletedAt: $deletedAt, likesCount: $likesCount, commentsCount: $commentsCount, savesCount: $savesCount, sendsCount: $sendsCount, viewsCount: $viewsCount, createdAt: $createdAt, updatedAt: $updatedAt, media: $media)';
}


}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res> implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(_PostModel value, $Res Function(_PostModel) _then) = __$PostModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'cluster_id') String? clusterId, String? title, String? subtitle, String? description,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'saves_count') int savesCount,@JsonKey(name: 'sends_count') int sendsCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'post_media') List<PostMediaModel> media
});




}
/// @nodoc
class __$PostModelCopyWithImpl<$Res>
    implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? clusterId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? isArchived = null,Object? deletedAt = freezed,Object? likesCount = null,Object? commentsCount = null,Object? savesCount = null,Object? sendsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? updatedAt = null,Object? media = null,}) {
  return _then(_PostModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,savesCount: null == savesCount ? _self.savesCount : savesCount // ignore: cast_nullable_to_non_nullable
as int,sendsCount: null == sendsCount ? _self.sendsCount : sendsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<PostMediaModel>,
  ));
}


}

// dart format on

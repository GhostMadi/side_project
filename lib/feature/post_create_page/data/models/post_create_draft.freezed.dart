// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_create_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCreateDraft {

 String? get title; String? get subtitle; String? get description; String? get clusterId; List<PostCreateMediaItem> get media;
/// Create a copy of PostCreateDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreateDraftCopyWith<PostCreateDraft> get copyWith => _$PostCreateDraftCopyWithImpl<PostCreateDraft>(this as PostCreateDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreateDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&const DeepCollectionEquality().equals(other.media, media));
}


@override
int get hashCode => Object.hash(runtimeType,title,subtitle,description,clusterId,const DeepCollectionEquality().hash(media));

@override
String toString() {
  return 'PostCreateDraft(title: $title, subtitle: $subtitle, description: $description, clusterId: $clusterId, media: $media)';
}


}

/// @nodoc
abstract mixin class $PostCreateDraftCopyWith<$Res>  {
  factory $PostCreateDraftCopyWith(PostCreateDraft value, $Res Function(PostCreateDraft) _then) = _$PostCreateDraftCopyWithImpl;
@useResult
$Res call({
 String? title, String? subtitle, String? description, String? clusterId, List<PostCreateMediaItem> media
});




}
/// @nodoc
class _$PostCreateDraftCopyWithImpl<$Res>
    implements $PostCreateDraftCopyWith<$Res> {
  _$PostCreateDraftCopyWithImpl(this._self, this._then);

  final PostCreateDraft _self;
  final $Res Function(PostCreateDraft) _then;

/// Create a copy of PostCreateDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? clusterId = freezed,Object? media = null,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<PostCreateMediaItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PostCreateDraft].
extension PostCreateDraftPatterns on PostCreateDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostCreateDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostCreateDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostCreateDraft value)  $default,){
final _that = this;
switch (_that) {
case _PostCreateDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostCreateDraft value)?  $default,){
final _that = this;
switch (_that) {
case _PostCreateDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? subtitle,  String? description,  String? clusterId,  List<PostCreateMediaItem> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostCreateDraft() when $default != null:
return $default(_that.title,_that.subtitle,_that.description,_that.clusterId,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? subtitle,  String? description,  String? clusterId,  List<PostCreateMediaItem> media)  $default,) {final _that = this;
switch (_that) {
case _PostCreateDraft():
return $default(_that.title,_that.subtitle,_that.description,_that.clusterId,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? subtitle,  String? description,  String? clusterId,  List<PostCreateMediaItem> media)?  $default,) {final _that = this;
switch (_that) {
case _PostCreateDraft() when $default != null:
return $default(_that.title,_that.subtitle,_that.description,_that.clusterId,_that.media);case _:
  return null;

}
}

}

/// @nodoc


class _PostCreateDraft implements PostCreateDraft {
  const _PostCreateDraft({this.title, this.subtitle, this.description, this.clusterId, final  List<PostCreateMediaItem> media = const []}): _media = media;
  

@override final  String? title;
@override final  String? subtitle;
@override final  String? description;
@override final  String? clusterId;
 final  List<PostCreateMediaItem> _media;
@override@JsonKey() List<PostCreateMediaItem> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of PostCreateDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCreateDraftCopyWith<_PostCreateDraft> get copyWith => __$PostCreateDraftCopyWithImpl<_PostCreateDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCreateDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&const DeepCollectionEquality().equals(other._media, _media));
}


@override
int get hashCode => Object.hash(runtimeType,title,subtitle,description,clusterId,const DeepCollectionEquality().hash(_media));

@override
String toString() {
  return 'PostCreateDraft(title: $title, subtitle: $subtitle, description: $description, clusterId: $clusterId, media: $media)';
}


}

/// @nodoc
abstract mixin class _$PostCreateDraftCopyWith<$Res> implements $PostCreateDraftCopyWith<$Res> {
  factory _$PostCreateDraftCopyWith(_PostCreateDraft value, $Res Function(_PostCreateDraft) _then) = __$PostCreateDraftCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? subtitle, String? description, String? clusterId, List<PostCreateMediaItem> media
});




}
/// @nodoc
class __$PostCreateDraftCopyWithImpl<$Res>
    implements _$PostCreateDraftCopyWith<$Res> {
  __$PostCreateDraftCopyWithImpl(this._self, this._then);

  final _PostCreateDraft _self;
  final $Res Function(_PostCreateDraft) _then;

/// Create a copy of PostCreateDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? subtitle = freezed,Object? description = freezed,Object? clusterId = freezed,Object? media = null,}) {
  return _then(_PostCreateDraft(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<PostCreateMediaItem>,
  ));
}


}

// dart format on

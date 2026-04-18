// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_create_media_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCreateMediaItem {

 Uint8List get bytes; String get mime; String get ext; String? get aspect;
/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreateMediaItemCopyWith<PostCreateMediaItem> get copyWith => _$PostCreateMediaItemCopyWithImpl<PostCreateMediaItem>(this as PostCreateMediaItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreateMediaItem&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.aspect, aspect) || other.aspect == aspect));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),mime,ext,aspect);

@override
String toString() {
  return 'PostCreateMediaItem(bytes: $bytes, mime: $mime, ext: $ext, aspect: $aspect)';
}


}

/// @nodoc
abstract mixin class $PostCreateMediaItemCopyWith<$Res>  {
  factory $PostCreateMediaItemCopyWith(PostCreateMediaItem value, $Res Function(PostCreateMediaItem) _then) = _$PostCreateMediaItemCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes, String mime, String ext, String? aspect
});




}
/// @nodoc
class _$PostCreateMediaItemCopyWithImpl<$Res>
    implements $PostCreateMediaItemCopyWith<$Res> {
  _$PostCreateMediaItemCopyWithImpl(this._self, this._then);

  final PostCreateMediaItem _self;
  final $Res Function(PostCreateMediaItem) _then;

/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? mime = null,Object? ext = null,Object? aspect = freezed,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,aspect: freezed == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostCreateMediaItem].
extension PostCreateMediaItemPatterns on PostCreateMediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Image value)?  image,TResult Function( _Video value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that);case _Video() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Image value)  image,required TResult Function( _Video value)  video,}){
final _that = this;
switch (_that) {
case _Image():
return image(_that);case _Video():
return video(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Image value)?  image,TResult? Function( _Video value)?  video,}){
final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that);case _Video() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Uint8List bytes,  String mime,  String ext,  String? aspect)?  image,TResult Function( Uint8List bytes,  String mime,  String ext,  String? aspect)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that.bytes,_that.mime,_that.ext,_that.aspect);case _Video() when video != null:
return video(_that.bytes,_that.mime,_that.ext,_that.aspect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Uint8List bytes,  String mime,  String ext,  String? aspect)  image,required TResult Function( Uint8List bytes,  String mime,  String ext,  String? aspect)  video,}) {final _that = this;
switch (_that) {
case _Image():
return image(_that.bytes,_that.mime,_that.ext,_that.aspect);case _Video():
return video(_that.bytes,_that.mime,_that.ext,_that.aspect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Uint8List bytes,  String mime,  String ext,  String? aspect)?  image,TResult? Function( Uint8List bytes,  String mime,  String ext,  String? aspect)?  video,}) {final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that.bytes,_that.mime,_that.ext,_that.aspect);case _Video() when video != null:
return video(_that.bytes,_that.mime,_that.ext,_that.aspect);case _:
  return null;

}
}

}

/// @nodoc


class _Image implements PostCreateMediaItem {
  const _Image({required this.bytes, this.mime = 'image/jpeg', this.ext = 'jpg', this.aspect});
  

@override final  Uint8List bytes;
@override@JsonKey() final  String mime;
@override@JsonKey() final  String ext;
@override final  String? aspect;

/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageCopyWith<_Image> get copyWith => __$ImageCopyWithImpl<_Image>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Image&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.aspect, aspect) || other.aspect == aspect));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),mime,ext,aspect);

@override
String toString() {
  return 'PostCreateMediaItem.image(bytes: $bytes, mime: $mime, ext: $ext, aspect: $aspect)';
}


}

/// @nodoc
abstract mixin class _$ImageCopyWith<$Res> implements $PostCreateMediaItemCopyWith<$Res> {
  factory _$ImageCopyWith(_Image value, $Res Function(_Image) _then) = __$ImageCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String mime, String ext, String? aspect
});




}
/// @nodoc
class __$ImageCopyWithImpl<$Res>
    implements _$ImageCopyWith<$Res> {
  __$ImageCopyWithImpl(this._self, this._then);

  final _Image _self;
  final $Res Function(_Image) _then;

/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? mime = null,Object? ext = null,Object? aspect = freezed,}) {
  return _then(_Image(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,aspect: freezed == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Video implements PostCreateMediaItem {
  const _Video({required this.bytes, required this.mime, required this.ext, this.aspect});
  

@override final  Uint8List bytes;
@override final  String mime;
@override final  String ext;
@override final  String? aspect;

/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCopyWith<_Video> get copyWith => __$VideoCopyWithImpl<_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Video&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.aspect, aspect) || other.aspect == aspect));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),mime,ext,aspect);

@override
String toString() {
  return 'PostCreateMediaItem.video(bytes: $bytes, mime: $mime, ext: $ext, aspect: $aspect)';
}


}

/// @nodoc
abstract mixin class _$VideoCopyWith<$Res> implements $PostCreateMediaItemCopyWith<$Res> {
  factory _$VideoCopyWith(_Video value, $Res Function(_Video) _then) = __$VideoCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String mime, String ext, String? aspect
});




}
/// @nodoc
class __$VideoCopyWithImpl<$Res>
    implements _$VideoCopyWith<$Res> {
  __$VideoCopyWithImpl(this._self, this._then);

  final _Video _self;
  final $Res Function(_Video) _then;

/// Create a copy of PostCreateMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? mime = null,Object? ext = null,Object? aspect = freezed,}) {
  return _then(_Video(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,aspect: freezed == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

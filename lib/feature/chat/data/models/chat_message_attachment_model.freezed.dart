// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_attachment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessageAttachmentModel {

 String get id;@JsonKey(name: 'message_id') String get messageId; String get bucket; String get path; String? get mime;@JsonKey(name: 'size_bytes') int? get sizeBytes; int? get width; int? get height;@JsonKey(name: 'duration_ms') int? get durationMs;@JsonKey(name: 'preview_path') String? get previewPath;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of ChatMessageAttachmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageAttachmentModelCopyWith<ChatMessageAttachmentModel> get copyWith => _$ChatMessageAttachmentModelCopyWithImpl<ChatMessageAttachmentModel>(this as ChatMessageAttachmentModel, _$identity);

  /// Serializes this ChatMessageAttachmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageAttachmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.path, path) || other.path == path)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,bucket,path,mime,sizeBytes,width,height,durationMs,previewPath,createdAt);

@override
String toString() {
  return 'ChatMessageAttachmentModel(id: $id, messageId: $messageId, bucket: $bucket, path: $path, mime: $mime, sizeBytes: $sizeBytes, width: $width, height: $height, durationMs: $durationMs, previewPath: $previewPath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatMessageAttachmentModelCopyWith<$Res>  {
  factory $ChatMessageAttachmentModelCopyWith(ChatMessageAttachmentModel value, $Res Function(ChatMessageAttachmentModel) _then) = _$ChatMessageAttachmentModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'message_id') String messageId, String bucket, String path, String? mime,@JsonKey(name: 'size_bytes') int? sizeBytes, int? width, int? height,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'preview_path') String? previewPath,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$ChatMessageAttachmentModelCopyWithImpl<$Res>
    implements $ChatMessageAttachmentModelCopyWith<$Res> {
  _$ChatMessageAttachmentModelCopyWithImpl(this._self, this._then);

  final ChatMessageAttachmentModel _self;
  final $Res Function(ChatMessageAttachmentModel) _then;

/// Create a copy of ChatMessageAttachmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? bucket = null,Object? path = null,Object? mime = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? previewPath = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageAttachmentModel].
extension ChatMessageAttachmentModelPatterns on ChatMessageAttachmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageAttachmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageAttachmentModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageAttachmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'message_id')  String messageId,  String bucket,  String path,  String? mime, @JsonKey(name: 'size_bytes')  int? sizeBytes,  int? width,  int? height, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'preview_path')  String? previewPath, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel() when $default != null:
return $default(_that.id,_that.messageId,_that.bucket,_that.path,_that.mime,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.previewPath,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'message_id')  String messageId,  String bucket,  String path,  String? mime, @JsonKey(name: 'size_bytes')  int? sizeBytes,  int? width,  int? height, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'preview_path')  String? previewPath, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel():
return $default(_that.id,_that.messageId,_that.bucket,_that.path,_that.mime,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.previewPath,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'message_id')  String messageId,  String bucket,  String path,  String? mime, @JsonKey(name: 'size_bytes')  int? sizeBytes,  int? width,  int? height, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'preview_path')  String? previewPath, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageAttachmentModel() when $default != null:
return $default(_that.id,_that.messageId,_that.bucket,_that.path,_that.mime,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.previewPath,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessageAttachmentModel implements ChatMessageAttachmentModel {
  const _ChatMessageAttachmentModel({required this.id, @JsonKey(name: 'message_id') required this.messageId, required this.bucket, required this.path, this.mime, @JsonKey(name: 'size_bytes') this.sizeBytes, this.width, this.height, @JsonKey(name: 'duration_ms') this.durationMs, @JsonKey(name: 'preview_path') this.previewPath, @JsonKey(name: 'created_at') this.createdAt});
  factory _ChatMessageAttachmentModel.fromJson(Map<String, dynamic> json) => _$ChatMessageAttachmentModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'message_id') final  String messageId;
@override final  String bucket;
@override final  String path;
@override final  String? mime;
@override@JsonKey(name: 'size_bytes') final  int? sizeBytes;
@override final  int? width;
@override final  int? height;
@override@JsonKey(name: 'duration_ms') final  int? durationMs;
@override@JsonKey(name: 'preview_path') final  String? previewPath;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of ChatMessageAttachmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageAttachmentModelCopyWith<_ChatMessageAttachmentModel> get copyWith => __$ChatMessageAttachmentModelCopyWithImpl<_ChatMessageAttachmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageAttachmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageAttachmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.path, path) || other.path == path)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,bucket,path,mime,sizeBytes,width,height,durationMs,previewPath,createdAt);

@override
String toString() {
  return 'ChatMessageAttachmentModel(id: $id, messageId: $messageId, bucket: $bucket, path: $path, mime: $mime, sizeBytes: $sizeBytes, width: $width, height: $height, durationMs: $durationMs, previewPath: $previewPath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageAttachmentModelCopyWith<$Res> implements $ChatMessageAttachmentModelCopyWith<$Res> {
  factory _$ChatMessageAttachmentModelCopyWith(_ChatMessageAttachmentModel value, $Res Function(_ChatMessageAttachmentModel) _then) = __$ChatMessageAttachmentModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'message_id') String messageId, String bucket, String path, String? mime,@JsonKey(name: 'size_bytes') int? sizeBytes, int? width, int? height,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'preview_path') String? previewPath,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$ChatMessageAttachmentModelCopyWithImpl<$Res>
    implements _$ChatMessageAttachmentModelCopyWith<$Res> {
  __$ChatMessageAttachmentModelCopyWithImpl(this._self, this._then);

  final _ChatMessageAttachmentModel _self;
  final $Res Function(_ChatMessageAttachmentModel) _then;

/// Create a copy of ChatMessageAttachmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? bucket = null,Object? path = null,Object? mime = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? previewPath = freezed,Object? createdAt = freezed,}) {
  return _then(_ChatMessageAttachmentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

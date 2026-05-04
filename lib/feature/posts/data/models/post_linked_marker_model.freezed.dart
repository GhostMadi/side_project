// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_linked_marker_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostLinkedMarker {

 String get id;@JsonKey(name: 'text_emoji') String? get textEmoji;@JsonKey(name: 'address_text') String? get addressText;@JsonKey(name: 'is_archived') bool get isArchived;@JsonKey(name: 'event_time') DateTime get eventTime;@JsonKey(name: 'end_time') DateTime get endTime;/// `upcoming` | `active` | `finished` | `cancelled`
 String get status;
/// Create a copy of PostLinkedMarker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostLinkedMarkerCopyWith<PostLinkedMarker> get copyWith => _$PostLinkedMarkerCopyWithImpl<PostLinkedMarker>(this as PostLinkedMarker, _$identity);

  /// Serializes this PostLinkedMarker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostLinkedMarker&&(identical(other.id, id) || other.id == id)&&(identical(other.textEmoji, textEmoji) || other.textEmoji == textEmoji)&&(identical(other.addressText, addressText) || other.addressText == addressText)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,textEmoji,addressText,isArchived,eventTime,endTime,status);

@override
String toString() {
  return 'PostLinkedMarker(id: $id, textEmoji: $textEmoji, addressText: $addressText, isArchived: $isArchived, eventTime: $eventTime, endTime: $endTime, status: $status)';
}


}

/// @nodoc
abstract mixin class $PostLinkedMarkerCopyWith<$Res>  {
  factory $PostLinkedMarkerCopyWith(PostLinkedMarker value, $Res Function(PostLinkedMarker) _then) = _$PostLinkedMarkerCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'text_emoji') String? textEmoji,@JsonKey(name: 'address_text') String? addressText,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'event_time') DateTime eventTime,@JsonKey(name: 'end_time') DateTime endTime, String status
});




}
/// @nodoc
class _$PostLinkedMarkerCopyWithImpl<$Res>
    implements $PostLinkedMarkerCopyWith<$Res> {
  _$PostLinkedMarkerCopyWithImpl(this._self, this._then);

  final PostLinkedMarker _self;
  final $Res Function(PostLinkedMarker) _then;

/// Create a copy of PostLinkedMarker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? textEmoji = freezed,Object? addressText = freezed,Object? isArchived = null,Object? eventTime = null,Object? endTime = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,textEmoji: freezed == textEmoji ? _self.textEmoji : textEmoji // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostLinkedMarker].
extension PostLinkedMarkerPatterns on PostLinkedMarker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostLinkedMarker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostLinkedMarker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostLinkedMarker value)  $default,){
final _that = this;
switch (_that) {
case _PostLinkedMarker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostLinkedMarker value)?  $default,){
final _that = this;
switch (_that) {
case _PostLinkedMarker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostLinkedMarker() when $default != null:
return $default(_that.id,_that.textEmoji,_that.addressText,_that.isArchived,_that.eventTime,_that.endTime,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)  $default,) {final _that = this;
switch (_that) {
case _PostLinkedMarker():
return $default(_that.id,_that.textEmoji,_that.addressText,_that.isArchived,_that.eventTime,_that.endTime,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)?  $default,) {final _that = this;
switch (_that) {
case _PostLinkedMarker() when $default != null:
return $default(_that.id,_that.textEmoji,_that.addressText,_that.isArchived,_that.eventTime,_that.endTime,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostLinkedMarker implements PostLinkedMarker {
  const _PostLinkedMarker({required this.id, @JsonKey(name: 'text_emoji') this.textEmoji, @JsonKey(name: 'address_text') this.addressText, @JsonKey(name: 'is_archived') this.isArchived = false, @JsonKey(name: 'event_time') required this.eventTime, @JsonKey(name: 'end_time') required this.endTime, required this.status});
  factory _PostLinkedMarker.fromJson(Map<String, dynamic> json) => _$PostLinkedMarkerFromJson(json);

@override final  String id;
@override@JsonKey(name: 'text_emoji') final  String? textEmoji;
@override@JsonKey(name: 'address_text') final  String? addressText;
@override@JsonKey(name: 'is_archived') final  bool isArchived;
@override@JsonKey(name: 'event_time') final  DateTime eventTime;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
/// `upcoming` | `active` | `finished` | `cancelled`
@override final  String status;

/// Create a copy of PostLinkedMarker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostLinkedMarkerCopyWith<_PostLinkedMarker> get copyWith => __$PostLinkedMarkerCopyWithImpl<_PostLinkedMarker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostLinkedMarkerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostLinkedMarker&&(identical(other.id, id) || other.id == id)&&(identical(other.textEmoji, textEmoji) || other.textEmoji == textEmoji)&&(identical(other.addressText, addressText) || other.addressText == addressText)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,textEmoji,addressText,isArchived,eventTime,endTime,status);

@override
String toString() {
  return 'PostLinkedMarker(id: $id, textEmoji: $textEmoji, addressText: $addressText, isArchived: $isArchived, eventTime: $eventTime, endTime: $endTime, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PostLinkedMarkerCopyWith<$Res> implements $PostLinkedMarkerCopyWith<$Res> {
  factory _$PostLinkedMarkerCopyWith(_PostLinkedMarker value, $Res Function(_PostLinkedMarker) _then) = __$PostLinkedMarkerCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'text_emoji') String? textEmoji,@JsonKey(name: 'address_text') String? addressText,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'event_time') DateTime eventTime,@JsonKey(name: 'end_time') DateTime endTime, String status
});




}
/// @nodoc
class __$PostLinkedMarkerCopyWithImpl<$Res>
    implements _$PostLinkedMarkerCopyWith<$Res> {
  __$PostLinkedMarkerCopyWithImpl(this._self, this._then);

  final _PostLinkedMarker _self;
  final $Res Function(_PostLinkedMarker) _then;

/// Create a copy of PostLinkedMarker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? textEmoji = freezed,Object? addressText = freezed,Object? isArchived = null,Object? eventTime = null,Object? endTime = null,Object? status = null,}) {
  return _then(_PostLinkedMarker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,textEmoji: freezed == textEmoji ? _self.textEmoji : textEmoji // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatConversationModel {

 String get id; String get type;// 'dm'|'group'
 String? get title;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of ChatConversationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationModelCopyWith<ChatConversationModel> get copyWith => _$ChatConversationModelCopyWithImpl<ChatConversationModel>(this as ChatConversationModel, _$identity);

  /// Serializes this ChatConversationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,createdAt);

@override
String toString() {
  return 'ChatConversationModel(id: $id, type: $type, title: $title, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatConversationModelCopyWith<$Res>  {
  factory $ChatConversationModelCopyWith(ChatConversationModel value, $Res Function(ChatConversationModel) _then) = _$ChatConversationModelCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? title,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$ChatConversationModelCopyWithImpl<$Res>
    implements $ChatConversationModelCopyWith<$Res> {
  _$ChatConversationModelCopyWithImpl(this._self, this._then);

  final ChatConversationModel _self;
  final $Res Function(ChatConversationModel) _then;

/// Create a copy of ChatConversationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversationModel].
extension ChatConversationModelPatterns on ChatConversationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversationModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? title, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversationModel() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? title, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatConversationModel():
return $default(_that.id,_that.type,_that.title,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? title, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversationModel() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversationModel implements ChatConversationModel {
  const _ChatConversationModel({required this.id, required this.type, this.title, @JsonKey(name: 'created_at') this.createdAt});
  factory _ChatConversationModel.fromJson(Map<String, dynamic> json) => _$ChatConversationModelFromJson(json);

@override final  String id;
@override final  String type;
// 'dm'|'group'
@override final  String? title;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of ChatConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationModelCopyWith<_ChatConversationModel> get copyWith => __$ChatConversationModelCopyWithImpl<_ChatConversationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,createdAt);

@override
String toString() {
  return 'ChatConversationModel(id: $id, type: $type, title: $title, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationModelCopyWith<$Res> implements $ChatConversationModelCopyWith<$Res> {
  factory _$ChatConversationModelCopyWith(_ChatConversationModel value, $Res Function(_ChatConversationModel) _then) = __$ChatConversationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? title,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$ChatConversationModelCopyWithImpl<$Res>
    implements _$ChatConversationModelCopyWith<$Res> {
  __$ChatConversationModelCopyWithImpl(this._self, this._then);

  final _ChatConversationModel _self;
  final $Res Function(_ChatConversationModel) _then;

/// Create a copy of ChatConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? createdAt = freezed,}) {
  return _then(_ChatConversationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

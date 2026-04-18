// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_profile_mini_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatProfileMiniModel {

 String get id; String? get username;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of ChatProfileMiniModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatProfileMiniModelCopyWith<ChatProfileMiniModel> get copyWith => _$ChatProfileMiniModelCopyWithImpl<ChatProfileMiniModel>(this as ChatProfileMiniModel, _$identity);

  /// Serializes this ChatProfileMiniModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatProfileMiniModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl);

@override
String toString() {
  return 'ChatProfileMiniModel(id: $id, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $ChatProfileMiniModelCopyWith<$Res>  {
  factory $ChatProfileMiniModelCopyWith(ChatProfileMiniModel value, $Res Function(ChatProfileMiniModel) _then) = _$ChatProfileMiniModelCopyWithImpl;
@useResult
$Res call({
 String id, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$ChatProfileMiniModelCopyWithImpl<$Res>
    implements $ChatProfileMiniModelCopyWith<$Res> {
  _$ChatProfileMiniModelCopyWithImpl(this._self, this._then);

  final ChatProfileMiniModel _self;
  final $Res Function(ChatProfileMiniModel) _then;

/// Create a copy of ChatProfileMiniModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatProfileMiniModel].
extension ChatProfileMiniModelPatterns on ChatProfileMiniModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatProfileMiniModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatProfileMiniModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatProfileMiniModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatProfileMiniModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatProfileMiniModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatProfileMiniModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatProfileMiniModel() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatProfileMiniModel():
return $default(_that.id,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? username, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatProfileMiniModel() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatProfileMiniModel implements ChatProfileMiniModel {
  const _ChatProfileMiniModel({required this.id, this.username, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _ChatProfileMiniModel.fromJson(Map<String, dynamic> json) => _$ChatProfileMiniModelFromJson(json);

@override final  String id;
@override final  String? username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of ChatProfileMiniModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatProfileMiniModelCopyWith<_ChatProfileMiniModel> get copyWith => __$ChatProfileMiniModelCopyWithImpl<_ChatProfileMiniModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatProfileMiniModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatProfileMiniModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl);

@override
String toString() {
  return 'ChatProfileMiniModel(id: $id, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatProfileMiniModelCopyWith<$Res> implements $ChatProfileMiniModelCopyWith<$Res> {
  factory _$ChatProfileMiniModelCopyWith(_ChatProfileMiniModel value, $Res Function(_ChatProfileMiniModel) _then) = __$ChatProfileMiniModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? username,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$ChatProfileMiniModelCopyWithImpl<$Res>
    implements _$ChatProfileMiniModelCopyWith<$Res> {
  __$ChatProfileMiniModelCopyWithImpl(this._self, this._then);

  final _ChatProfileMiniModel _self;
  final $Res Function(_ChatProfileMiniModel) _then;

/// Create a copy of ChatProfileMiniModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_ChatProfileMiniModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

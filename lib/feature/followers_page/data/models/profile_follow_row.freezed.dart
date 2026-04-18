// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_follow_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFollowRow {

 String get profileId; String? get username; String? get avatarUrl;
/// Create a copy of ProfileFollowRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFollowRowCopyWith<ProfileFollowRow> get copyWith => _$ProfileFollowRowCopyWithImpl<ProfileFollowRow>(this as ProfileFollowRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFollowRow&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,username,avatarUrl);

@override
String toString() {
  return 'ProfileFollowRow(profileId: $profileId, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $ProfileFollowRowCopyWith<$Res>  {
  factory $ProfileFollowRowCopyWith(ProfileFollowRow value, $Res Function(ProfileFollowRow) _then) = _$ProfileFollowRowCopyWithImpl;
@useResult
$Res call({
 String profileId, String? username, String? avatarUrl
});




}
/// @nodoc
class _$ProfileFollowRowCopyWithImpl<$Res>
    implements $ProfileFollowRowCopyWith<$Res> {
  _$ProfileFollowRowCopyWithImpl(this._self, this._then);

  final ProfileFollowRow _self;
  final $Res Function(ProfileFollowRow) _then;

/// Create a copy of ProfileFollowRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileFollowRow].
extension ProfileFollowRowPatterns on ProfileFollowRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileFollowRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileFollowRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileFollowRow value)  $default,){
final _that = this;
switch (_that) {
case _ProfileFollowRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileFollowRow value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileFollowRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profileId,  String? username,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileFollowRow() when $default != null:
return $default(_that.profileId,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profileId,  String? username,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _ProfileFollowRow():
return $default(_that.profileId,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profileId,  String? username,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProfileFollowRow() when $default != null:
return $default(_that.profileId,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileFollowRow implements ProfileFollowRow {
  const _ProfileFollowRow({required this.profileId, this.username, this.avatarUrl});
  

@override final  String profileId;
@override final  String? username;
@override final  String? avatarUrl;

/// Create a copy of ProfileFollowRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFollowRowCopyWith<_ProfileFollowRow> get copyWith => __$ProfileFollowRowCopyWithImpl<_ProfileFollowRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileFollowRow&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,username,avatarUrl);

@override
String toString() {
  return 'ProfileFollowRow(profileId: $profileId, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfileFollowRowCopyWith<$Res> implements $ProfileFollowRowCopyWith<$Res> {
  factory _$ProfileFollowRowCopyWith(_ProfileFollowRow value, $Res Function(_ProfileFollowRow) _then) = __$ProfileFollowRowCopyWithImpl;
@override @useResult
$Res call({
 String profileId, String? username, String? avatarUrl
});




}
/// @nodoc
class __$ProfileFollowRowCopyWithImpl<$Res>
    implements _$ProfileFollowRowCopyWith<$Res> {
  __$ProfileFollowRowCopyWithImpl(this._self, this._then);

  final _ProfileFollowRow _self;
  final $Res Function(_ProfileFollowRow) _then;

/// Create a copy of ProfileFollowRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = null,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_ProfileFollowRow(
profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

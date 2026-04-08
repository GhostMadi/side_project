// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_search_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileSearchState {

 String get query; List<ProfileSearchHit> get results; bool get isLoading; String? get errorMessage;
/// Create a copy of ProfileSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileSearchStateCopyWith<ProfileSearchState> get copyWith => _$ProfileSearchStateCopyWithImpl<ProfileSearchState>(this as ProfileSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileSearchState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(results),isLoading,errorMessage);

@override
String toString() {
  return 'ProfileSearchState(query: $query, results: $results, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProfileSearchStateCopyWith<$Res>  {
  factory $ProfileSearchStateCopyWith(ProfileSearchState value, $Res Function(ProfileSearchState) _then) = _$ProfileSearchStateCopyWithImpl;
@useResult
$Res call({
 String query, List<ProfileSearchHit> results, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$ProfileSearchStateCopyWithImpl<$Res>
    implements $ProfileSearchStateCopyWith<$Res> {
  _$ProfileSearchStateCopyWithImpl(this._self, this._then);

  final ProfileSearchState _self;
  final $Res Function(ProfileSearchState) _then;

/// Create a copy of ProfileSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? results = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<ProfileSearchHit>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileSearchState].
extension ProfileSearchStatePatterns on ProfileSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileSearchState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<ProfileSearchHit> results,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileSearchState() when $default != null:
return $default(_that.query,_that.results,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<ProfileSearchHit> results,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProfileSearchState():
return $default(_that.query,_that.results,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<ProfileSearchHit> results,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProfileSearchState() when $default != null:
return $default(_that.query,_that.results,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileSearchState implements ProfileSearchState {
  const _ProfileSearchState({this.query = '', final  List<ProfileSearchHit> results = const <ProfileSearchHit>[], this.isLoading = false, this.errorMessage}): _results = results;
  

@override@JsonKey() final  String query;
 final  List<ProfileSearchHit> _results;
@override@JsonKey() List<ProfileSearchHit> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of ProfileSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileSearchStateCopyWith<_ProfileSearchState> get copyWith => __$ProfileSearchStateCopyWithImpl<_ProfileSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileSearchState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_results),isLoading,errorMessage);

@override
String toString() {
  return 'ProfileSearchState(query: $query, results: $results, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProfileSearchStateCopyWith<$Res> implements $ProfileSearchStateCopyWith<$Res> {
  factory _$ProfileSearchStateCopyWith(_ProfileSearchState value, $Res Function(_ProfileSearchState) _then) = __$ProfileSearchStateCopyWithImpl;
@override @useResult
$Res call({
 String query, List<ProfileSearchHit> results, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$ProfileSearchStateCopyWithImpl<$Res>
    implements _$ProfileSearchStateCopyWith<$Res> {
  __$ProfileSearchStateCopyWithImpl(this._self, this._then);

  final _ProfileSearchState _self;
  final $Res Function(_ProfileSearchState) _then;

/// Create a copy of ProfileSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? results = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_ProfileSearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<ProfileSearchHit>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

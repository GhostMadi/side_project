// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_mutation_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowMutationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowMutationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowMutationState()';
}


}

/// @nodoc
class $FollowMutationStateCopyWith<$Res>  {
$FollowMutationStateCopyWith(FollowMutationState _, $Res Function(FollowMutationState) __);
}


/// Adds pattern-matching-related methods to [FollowMutationState].
extension FollowMutationStatePatterns on FollowMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FmIdle value)?  idle,TResult Function( _FmInProgress value)?  inProgress,TResult Function( _FmSuccess value)?  success,TResult Function( _FmFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FmIdle() when idle != null:
return idle(_that);case _FmInProgress() when inProgress != null:
return inProgress(_that);case _FmSuccess() when success != null:
return success(_that);case _FmFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FmIdle value)  idle,required TResult Function( _FmInProgress value)  inProgress,required TResult Function( _FmSuccess value)  success,required TResult Function( _FmFailure value)  failure,}){
final _that = this;
switch (_that) {
case _FmIdle():
return idle(_that);case _FmInProgress():
return inProgress(_that);case _FmSuccess():
return success(_that);case _FmFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FmIdle value)?  idle,TResult? Function( _FmInProgress value)?  inProgress,TResult? Function( _FmSuccess value)?  success,TResult? Function( _FmFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _FmIdle() when idle != null:
return idle(_that);case _FmInProgress() when inProgress != null:
return inProgress(_that);case _FmSuccess() when success != null:
return success(_that);case _FmFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  inProgress,TResult Function()?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FmIdle() when idle != null:
return idle();case _FmInProgress() when inProgress != null:
return inProgress();case _FmSuccess() when success != null:
return success();case _FmFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  inProgress,required TResult Function()  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _FmIdle():
return idle();case _FmInProgress():
return inProgress();case _FmSuccess():
return success();case _FmFailure():
return failure(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  inProgress,TResult? Function()?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _FmIdle() when idle != null:
return idle();case _FmInProgress() when inProgress != null:
return inProgress();case _FmSuccess() when success != null:
return success();case _FmFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _FmIdle implements FollowMutationState {
  const _FmIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FmIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowMutationState.idle()';
}


}




/// @nodoc


class _FmInProgress implements FollowMutationState {
  const _FmInProgress();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FmInProgress);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowMutationState.inProgress()';
}


}




/// @nodoc


class _FmSuccess implements FollowMutationState {
  const _FmSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FmSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowMutationState.success()';
}


}




/// @nodoc


class _FmFailure implements FollowMutationState {
  const _FmFailure(this.message);
  

 final  String message;

/// Create a copy of FollowMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FmFailureCopyWith<_FmFailure> get copyWith => __$FmFailureCopyWithImpl<_FmFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FmFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'FollowMutationState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class _$FmFailureCopyWith<$Res> implements $FollowMutationStateCopyWith<$Res> {
  factory _$FmFailureCopyWith(_FmFailure value, $Res Function(_FmFailure) _then) = __$FmFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$FmFailureCopyWithImpl<$Res>
    implements _$FmFailureCopyWith<$Res> {
  __$FmFailureCopyWithImpl(this._self, this._then);

  final _FmFailure _self;
  final $Res Function(_FmFailure) _then;

/// Create a copy of FollowMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_FmFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cluster_create_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClusterCreateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClusterCreateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClusterCreateState()';
}


}

/// @nodoc
class $ClusterCreateStateCopyWith<$Res>  {
$ClusterCreateStateCopyWith(ClusterCreateState _, $Res Function(ClusterCreateState) __);
}


/// Adds pattern-matching-related methods to [ClusterCreateState].
extension ClusterCreateStatePatterns on ClusterCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Editing value)?  editing,TResult Function( _Submitting value)?  submitting,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Editing() when editing != null:
return editing(_that);case _Submitting() when submitting != null:
return submitting(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Editing value)  editing,required TResult Function( _Submitting value)  submitting,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Editing():
return editing(_that);case _Submitting():
return submitting(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Editing value)?  editing,TResult? Function( _Submitting value)?  submitting,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Editing() when editing != null:
return editing(_that);case _Submitting() when submitting != null:
return submitting(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  editing,TResult Function()?  submitting,TResult Function( ClusterModel cluster)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Editing() when editing != null:
return editing();case _Submitting() when submitting != null:
return submitting();case _Success() when success != null:
return success(_that.cluster);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  editing,required TResult Function()  submitting,required TResult Function( ClusterModel cluster)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Editing():
return editing();case _Submitting():
return submitting();case _Success():
return success(_that.cluster);case _Error():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  editing,TResult? Function()?  submitting,TResult? Function( ClusterModel cluster)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Editing() when editing != null:
return editing();case _Submitting() when submitting != null:
return submitting();case _Success() when success != null:
return success(_that.cluster);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Editing implements ClusterCreateState {
  const _Editing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Editing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClusterCreateState.editing()';
}


}




/// @nodoc


class _Submitting implements ClusterCreateState {
  const _Submitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Submitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClusterCreateState.submitting()';
}


}




/// @nodoc


class _Success implements ClusterCreateState {
  const _Success(this.cluster);
  

 final  ClusterModel cluster;

/// Create a copy of ClusterCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.cluster, cluster) || other.cluster == cluster));
}


@override
int get hashCode => Object.hash(runtimeType,cluster);

@override
String toString() {
  return 'ClusterCreateState.success(cluster: $cluster)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $ClusterCreateStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 ClusterModel cluster
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of ClusterCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cluster = null,}) {
  return _then(_Success(
null == cluster ? _self.cluster : cluster // ignore: cast_nullable_to_non_nullable
as ClusterModel,
  ));
}


}

/// @nodoc


class _Error implements ClusterCreateState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of ClusterCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ClusterCreateState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ClusterCreateStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ClusterCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_create_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostCreateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCreateState()';
}


}

/// @nodoc
class $PostCreateStateCopyWith<$Res>  {
$PostCreateStateCopyWith(PostCreateState _, $Res Function(PostCreateState) __);
}


/// Adds pattern-matching-related methods to [PostCreateState].
extension PostCreateStatePatterns on PostCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Ready value)?  ready,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Ready value)  ready,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Ready():
return ready(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Ready value)?  ready,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ClusterModel> clusters,  List<AppSingleSelectOption<String>> clusterSelectOptions,  bool isSubmitting,  String? errorMessage)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Ready() when ready != null:
return ready(_that.clusters,_that.clusterSelectOptions,_that.isSubmitting,_that.errorMessage);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ClusterModel> clusters,  List<AppSingleSelectOption<String>> clusterSelectOptions,  bool isSubmitting,  String? errorMessage)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Ready():
return ready(_that.clusters,_that.clusterSelectOptions,_that.isSubmitting,_that.errorMessage);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ClusterModel> clusters,  List<AppSingleSelectOption<String>> clusterSelectOptions,  bool isSubmitting,  String? errorMessage)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Ready() when ready != null:
return ready(_that.clusters,_that.clusterSelectOptions,_that.isSubmitting,_that.errorMessage);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements PostCreateState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCreateState.initial()';
}


}




/// @nodoc


class _Loading implements PostCreateState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostCreateState.loading()';
}


}




/// @nodoc


class _Ready implements PostCreateState {
  const _Ready({required final  List<ClusterModel> clusters, final  List<AppSingleSelectOption<String>> clusterSelectOptions = const <AppSingleSelectOption<String>>[], this.isSubmitting = false, this.errorMessage}): _clusters = clusters,_clusterSelectOptions = clusterSelectOptions;
  

 final  List<ClusterModel> _clusters;
 List<ClusterModel> get clusters {
  if (_clusters is EqualUnmodifiableListView) return _clusters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clusters);
}

 final  List<AppSingleSelectOption<String>> _clusterSelectOptions;
@JsonKey() List<AppSingleSelectOption<String>> get clusterSelectOptions {
  if (_clusterSelectOptions is EqualUnmodifiableListView) return _clusterSelectOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clusterSelectOptions);
}

@JsonKey() final  bool isSubmitting;
 final  String? errorMessage;

/// Create a copy of PostCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadyCopyWith<_Ready> get copyWith => __$ReadyCopyWithImpl<_Ready>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ready&&const DeepCollectionEquality().equals(other._clusters, _clusters)&&const DeepCollectionEquality().equals(other._clusterSelectOptions, _clusterSelectOptions)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_clusters),const DeepCollectionEquality().hash(_clusterSelectOptions),isSubmitting,errorMessage);

@override
String toString() {
  return 'PostCreateState.ready(clusters: $clusters, clusterSelectOptions: $clusterSelectOptions, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ReadyCopyWith<$Res> implements $PostCreateStateCopyWith<$Res> {
  factory _$ReadyCopyWith(_Ready value, $Res Function(_Ready) _then) = __$ReadyCopyWithImpl;
@useResult
$Res call({
 List<ClusterModel> clusters, List<AppSingleSelectOption<String>> clusterSelectOptions, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class __$ReadyCopyWithImpl<$Res>
    implements _$ReadyCopyWith<$Res> {
  __$ReadyCopyWithImpl(this._self, this._then);

  final _Ready _self;
  final $Res Function(_Ready) _then;

/// Create a copy of PostCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clusters = null,Object? clusterSelectOptions = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_Ready(
clusters: null == clusters ? _self._clusters : clusters // ignore: cast_nullable_to_non_nullable
as List<ClusterModel>,clusterSelectOptions: null == clusterSelectOptions ? _self._clusterSelectOptions : clusterSelectOptions // ignore: cast_nullable_to_non_nullable
as List<AppSingleSelectOption<String>>,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Error implements PostCreateState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of PostCreateState
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
  return 'PostCreateState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PostCreateStateCopyWith<$Res> {
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

/// Create a copy of PostCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

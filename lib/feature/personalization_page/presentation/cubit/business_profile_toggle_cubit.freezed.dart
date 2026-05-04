// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_profile_toggle_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BusinessProfileToggleState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessProfileToggleState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BusinessProfileToggleState()';
}


}

/// @nodoc
class $BusinessProfileToggleStateCopyWith<$Res>  {
$BusinessProfileToggleStateCopyWith(BusinessProfileToggleState _, $Res Function(BusinessProfileToggleState) __);
}


/// Adds pattern-matching-related methods to [BusinessProfileToggleState].
extension BusinessProfileToggleStatePatterns on BusinessProfileToggleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _BpLoading value)?  loading,TResult Function( _BpLoaded value)?  loaded,TResult Function( _BpError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BpLoading() when loading != null:
return loading(_that);case _BpLoaded() when loaded != null:
return loaded(_that);case _BpError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _BpLoading value)  loading,required TResult Function( _BpLoaded value)  loaded,required TResult Function( _BpError value)  error,}){
final _that = this;
switch (_that) {
case _BpLoading():
return loading(_that);case _BpLoaded():
return loaded(_that);case _BpError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _BpLoading value)?  loading,TResult? Function( _BpLoaded value)?  loaded,TResult? Function( _BpError value)?  error,}){
final _that = this;
switch (_that) {
case _BpLoading() when loading != null:
return loading(_that);case _BpLoaded() when loaded != null:
return loaded(_that);case _BpError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( bool isActive,  bool submitting)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BpLoading() when loading != null:
return loading();case _BpLoaded() when loaded != null:
return loaded(_that.isActive,_that.submitting);case _BpError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( bool isActive,  bool submitting)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _BpLoading():
return loading();case _BpLoaded():
return loaded(_that.isActive,_that.submitting);case _BpError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( bool isActive,  bool submitting)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _BpLoading() when loading != null:
return loading();case _BpLoaded() when loaded != null:
return loaded(_that.isActive,_that.submitting);case _BpError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _BpLoading implements BusinessProfileToggleState {
  const _BpLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BpLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BusinessProfileToggleState.loading()';
}


}




/// @nodoc


class _BpLoaded implements BusinessProfileToggleState {
  const _BpLoaded({required this.isActive, this.submitting = false});
  

 final  bool isActive;
@JsonKey() final  bool submitting;

/// Create a copy of BusinessProfileToggleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BpLoadedCopyWith<_BpLoaded> get copyWith => __$BpLoadedCopyWithImpl<_BpLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BpLoaded&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.submitting, submitting) || other.submitting == submitting));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,submitting);

@override
String toString() {
  return 'BusinessProfileToggleState.loaded(isActive: $isActive, submitting: $submitting)';
}


}

/// @nodoc
abstract mixin class _$BpLoadedCopyWith<$Res> implements $BusinessProfileToggleStateCopyWith<$Res> {
  factory _$BpLoadedCopyWith(_BpLoaded value, $Res Function(_BpLoaded) _then) = __$BpLoadedCopyWithImpl;
@useResult
$Res call({
 bool isActive, bool submitting
});




}
/// @nodoc
class __$BpLoadedCopyWithImpl<$Res>
    implements _$BpLoadedCopyWith<$Res> {
  __$BpLoadedCopyWithImpl(this._self, this._then);

  final _BpLoaded _self;
  final $Res Function(_BpLoaded) _then;

/// Create a copy of BusinessProfileToggleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? submitting = null,}) {
  return _then(_BpLoaded(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _BpError implements BusinessProfileToggleState {
  const _BpError(this.message);
  

 final  String message;

/// Create a copy of BusinessProfileToggleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BpErrorCopyWith<_BpError> get copyWith => __$BpErrorCopyWithImpl<_BpError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BpError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BusinessProfileToggleState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$BpErrorCopyWith<$Res> implements $BusinessProfileToggleStateCopyWith<$Res> {
  factory _$BpErrorCopyWith(_BpError value, $Res Function(_BpError) _then) = __$BpErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$BpErrorCopyWithImpl<$Res>
    implements _$BpErrorCopyWith<$Res> {
  __$BpErrorCopyWithImpl(this._self, this._then);

  final _BpError _self;
  final $Res Function(_BpError) _then;

/// Create a copy of BusinessProfileToggleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_BpError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

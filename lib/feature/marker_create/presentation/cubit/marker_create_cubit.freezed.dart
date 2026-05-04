// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_create_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkerCreateState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerCreateState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerCreateState()';
}


}

/// @nodoc
class $MarkerCreateStateCopyWith<$Res>  {
$MarkerCreateStateCopyWith(MarkerCreateState _, $Res Function(MarkerCreateState) __);
}


/// Adds pattern-matching-related methods to [MarkerCreateState].
extension MarkerCreateStatePatterns on MarkerCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Editing value)?  editing,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Editing() when editing != null:
return editing(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Editing value)  editing,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Editing():
return editing(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Editing value)?  editing,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Editing() when editing != null:
return editing(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( MarkerCreateStep step,  List<MarkerTagModel> tags,  MarkerCreateDraft draft,  bool isSubmitting)?  editing,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Editing() when editing != null:
return editing(_that.step,_that.tags,_that.draft,_that.isSubmitting);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( MarkerCreateStep step,  List<MarkerTagModel> tags,  MarkerCreateDraft draft,  bool isSubmitting)  editing,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Editing():
return editing(_that.step,_that.tags,_that.draft,_that.isSubmitting);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( MarkerCreateStep step,  List<MarkerTagModel> tags,  MarkerCreateDraft draft,  bool isSubmitting)?  editing,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Editing() when editing != null:
return editing(_that.step,_that.tags,_that.draft,_that.isSubmitting);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements MarkerCreateState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerCreateState.initial()';
}


}




/// @nodoc


class _Loading implements MarkerCreateState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MarkerCreateState.loading()';
}


}




/// @nodoc


class _Editing implements MarkerCreateState {
  const _Editing({required this.step, required final  List<MarkerTagModel> tags, required this.draft, required this.isSubmitting}): _tags = tags;
  

 final  MarkerCreateStep step;
 final  List<MarkerTagModel> _tags;
 List<MarkerTagModel> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  MarkerCreateDraft draft;
 final  bool isSubmitting;

/// Create a copy of MarkerCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditingCopyWith<_Editing> get copyWith => __$EditingCopyWithImpl<_Editing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Editing&&(identical(other.step, step) || other.step == step)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,step,const DeepCollectionEquality().hash(_tags),draft,isSubmitting);

@override
String toString() {
  return 'MarkerCreateState.editing(step: $step, tags: $tags, draft: $draft, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class _$EditingCopyWith<$Res> implements $MarkerCreateStateCopyWith<$Res> {
  factory _$EditingCopyWith(_Editing value, $Res Function(_Editing) _then) = __$EditingCopyWithImpl;
@useResult
$Res call({
 MarkerCreateStep step, List<MarkerTagModel> tags, MarkerCreateDraft draft, bool isSubmitting
});


$MarkerCreateDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$EditingCopyWithImpl<$Res>
    implements _$EditingCopyWith<$Res> {
  __$EditingCopyWithImpl(this._self, this._then);

  final _Editing _self;
  final $Res Function(_Editing) _then;

/// Create a copy of MarkerCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? step = null,Object? tags = null,Object? draft = null,Object? isSubmitting = null,}) {
  return _then(_Editing(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as MarkerCreateStep,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<MarkerTagModel>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as MarkerCreateDraft,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MarkerCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarkerCreateDraftCopyWith<$Res> get draft {
  
  return $MarkerCreateDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class _Error implements MarkerCreateState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of MarkerCreateState
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
  return 'MarkerCreateState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MarkerCreateStateCopyWith<$Res> {
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

/// Create a copy of MarkerCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

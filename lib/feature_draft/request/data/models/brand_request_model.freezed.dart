// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brand_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BrandRequestModel {

 String get id; String get userId; String get fullName; String get taxId; String get phone; String get email; String? get idFrontUrl; String? get idBackUrl;// Используем Enum и задаем дефолтное значение
 BrandRequestStatus get status; List<ModeratorHistoryItem> get moderatorHistory; String? get moderatorName; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of BrandRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrandRequestModelCopyWith<BrandRequestModel> get copyWith => _$BrandRequestModelCopyWithImpl<BrandRequestModel>(this as BrandRequestModel, _$identity);

  /// Serializes this BrandRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrandRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.idFrontUrl, idFrontUrl) || other.idFrontUrl == idFrontUrl)&&(identical(other.idBackUrl, idBackUrl) || other.idBackUrl == idBackUrl)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.moderatorHistory, moderatorHistory)&&(identical(other.moderatorName, moderatorName) || other.moderatorName == moderatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,fullName,taxId,phone,email,idFrontUrl,idBackUrl,status,const DeepCollectionEquality().hash(moderatorHistory),moderatorName,createdAt,updatedAt);

@override
String toString() {
  return 'BrandRequestModel(id: $id, userId: $userId, fullName: $fullName, taxId: $taxId, phone: $phone, email: $email, idFrontUrl: $idFrontUrl, idBackUrl: $idBackUrl, status: $status, moderatorHistory: $moderatorHistory, moderatorName: $moderatorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BrandRequestModelCopyWith<$Res>  {
  factory $BrandRequestModelCopyWith(BrandRequestModel value, $Res Function(BrandRequestModel) _then) = _$BrandRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String fullName, String taxId, String phone, String email, String? idFrontUrl, String? idBackUrl, BrandRequestStatus status, List<ModeratorHistoryItem> moderatorHistory, String? moderatorName, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$BrandRequestModelCopyWithImpl<$Res>
    implements $BrandRequestModelCopyWith<$Res> {
  _$BrandRequestModelCopyWithImpl(this._self, this._then);

  final BrandRequestModel _self;
  final $Res Function(BrandRequestModel) _then;

/// Create a copy of BrandRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? fullName = null,Object? taxId = null,Object? phone = null,Object? email = null,Object? idFrontUrl = freezed,Object? idBackUrl = freezed,Object? status = null,Object? moderatorHistory = null,Object? moderatorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,idFrontUrl: freezed == idFrontUrl ? _self.idFrontUrl : idFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackUrl: freezed == idBackUrl ? _self.idBackUrl : idBackUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BrandRequestStatus,moderatorHistory: null == moderatorHistory ? _self.moderatorHistory : moderatorHistory // ignore: cast_nullable_to_non_nullable
as List<ModeratorHistoryItem>,moderatorName: freezed == moderatorName ? _self.moderatorName : moderatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BrandRequestModel].
extension BrandRequestModelPatterns on BrandRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrandRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrandRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrandRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _BrandRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrandRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _BrandRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String fullName,  String taxId,  String phone,  String email,  String? idFrontUrl,  String? idBackUrl,  BrandRequestStatus status,  List<ModeratorHistoryItem> moderatorHistory,  String? moderatorName,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrandRequestModel() when $default != null:
return $default(_that.id,_that.userId,_that.fullName,_that.taxId,_that.phone,_that.email,_that.idFrontUrl,_that.idBackUrl,_that.status,_that.moderatorHistory,_that.moderatorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String fullName,  String taxId,  String phone,  String email,  String? idFrontUrl,  String? idBackUrl,  BrandRequestStatus status,  List<ModeratorHistoryItem> moderatorHistory,  String? moderatorName,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BrandRequestModel():
return $default(_that.id,_that.userId,_that.fullName,_that.taxId,_that.phone,_that.email,_that.idFrontUrl,_that.idBackUrl,_that.status,_that.moderatorHistory,_that.moderatorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String fullName,  String taxId,  String phone,  String email,  String? idFrontUrl,  String? idBackUrl,  BrandRequestStatus status,  List<ModeratorHistoryItem> moderatorHistory,  String? moderatorName,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BrandRequestModel() when $default != null:
return $default(_that.id,_that.userId,_that.fullName,_that.taxId,_that.phone,_that.email,_that.idFrontUrl,_that.idBackUrl,_that.status,_that.moderatorHistory,_that.moderatorName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _BrandRequestModel implements BrandRequestModel {
  const _BrandRequestModel({required this.id, required this.userId, required this.fullName, required this.taxId, required this.phone, required this.email, this.idFrontUrl, this.idBackUrl, this.status = BrandRequestStatus.pending, final  List<ModeratorHistoryItem> moderatorHistory = const [], this.moderatorName, this.createdAt, this.updatedAt}): _moderatorHistory = moderatorHistory;
  factory _BrandRequestModel.fromJson(Map<String, dynamic> json) => _$BrandRequestModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String fullName;
@override final  String taxId;
@override final  String phone;
@override final  String email;
@override final  String? idFrontUrl;
@override final  String? idBackUrl;
// Используем Enum и задаем дефолтное значение
@override@JsonKey() final  BrandRequestStatus status;
 final  List<ModeratorHistoryItem> _moderatorHistory;
@override@JsonKey() List<ModeratorHistoryItem> get moderatorHistory {
  if (_moderatorHistory is EqualUnmodifiableListView) return _moderatorHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moderatorHistory);
}

@override final  String? moderatorName;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of BrandRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrandRequestModelCopyWith<_BrandRequestModel> get copyWith => __$BrandRequestModelCopyWithImpl<_BrandRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrandRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrandRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.idFrontUrl, idFrontUrl) || other.idFrontUrl == idFrontUrl)&&(identical(other.idBackUrl, idBackUrl) || other.idBackUrl == idBackUrl)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._moderatorHistory, _moderatorHistory)&&(identical(other.moderatorName, moderatorName) || other.moderatorName == moderatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,fullName,taxId,phone,email,idFrontUrl,idBackUrl,status,const DeepCollectionEquality().hash(_moderatorHistory),moderatorName,createdAt,updatedAt);

@override
String toString() {
  return 'BrandRequestModel(id: $id, userId: $userId, fullName: $fullName, taxId: $taxId, phone: $phone, email: $email, idFrontUrl: $idFrontUrl, idBackUrl: $idBackUrl, status: $status, moderatorHistory: $moderatorHistory, moderatorName: $moderatorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BrandRequestModelCopyWith<$Res> implements $BrandRequestModelCopyWith<$Res> {
  factory _$BrandRequestModelCopyWith(_BrandRequestModel value, $Res Function(_BrandRequestModel) _then) = __$BrandRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String fullName, String taxId, String phone, String email, String? idFrontUrl, String? idBackUrl, BrandRequestStatus status, List<ModeratorHistoryItem> moderatorHistory, String? moderatorName, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$BrandRequestModelCopyWithImpl<$Res>
    implements _$BrandRequestModelCopyWith<$Res> {
  __$BrandRequestModelCopyWithImpl(this._self, this._then);

  final _BrandRequestModel _self;
  final $Res Function(_BrandRequestModel) _then;

/// Create a copy of BrandRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? fullName = null,Object? taxId = null,Object? phone = null,Object? email = null,Object? idFrontUrl = freezed,Object? idBackUrl = freezed,Object? status = null,Object? moderatorHistory = null,Object? moderatorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BrandRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,idFrontUrl: freezed == idFrontUrl ? _self.idFrontUrl : idFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackUrl: freezed == idBackUrl ? _self.idBackUrl : idBackUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BrandRequestStatus,moderatorHistory: null == moderatorHistory ? _self._moderatorHistory : moderatorHistory // ignore: cast_nullable_to_non_nullable
as List<ModeratorHistoryItem>,moderatorName: freezed == moderatorName ? _self.moderatorName : moderatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ModeratorHistoryItem {

 DateTime? get date; String? get comment; String? get moderator;
/// Create a copy of ModeratorHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModeratorHistoryItemCopyWith<ModeratorHistoryItem> get copyWith => _$ModeratorHistoryItemCopyWithImpl<ModeratorHistoryItem>(this as ModeratorHistoryItem, _$identity);

  /// Serializes this ModeratorHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModeratorHistoryItem&&(identical(other.date, date) || other.date == date)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.moderator, moderator) || other.moderator == moderator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,comment,moderator);

@override
String toString() {
  return 'ModeratorHistoryItem(date: $date, comment: $comment, moderator: $moderator)';
}


}

/// @nodoc
abstract mixin class $ModeratorHistoryItemCopyWith<$Res>  {
  factory $ModeratorHistoryItemCopyWith(ModeratorHistoryItem value, $Res Function(ModeratorHistoryItem) _then) = _$ModeratorHistoryItemCopyWithImpl;
@useResult
$Res call({
 DateTime? date, String? comment, String? moderator
});




}
/// @nodoc
class _$ModeratorHistoryItemCopyWithImpl<$Res>
    implements $ModeratorHistoryItemCopyWith<$Res> {
  _$ModeratorHistoryItemCopyWithImpl(this._self, this._then);

  final ModeratorHistoryItem _self;
  final $Res Function(ModeratorHistoryItem) _then;

/// Create a copy of ModeratorHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = freezed,Object? comment = freezed,Object? moderator = freezed,}) {
  return _then(_self.copyWith(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,moderator: freezed == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModeratorHistoryItem].
extension ModeratorHistoryItemPatterns on ModeratorHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModeratorHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModeratorHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModeratorHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _ModeratorHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModeratorHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _ModeratorHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? date,  String? comment,  String? moderator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModeratorHistoryItem() when $default != null:
return $default(_that.date,_that.comment,_that.moderator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? date,  String? comment,  String? moderator)  $default,) {final _that = this;
switch (_that) {
case _ModeratorHistoryItem():
return $default(_that.date,_that.comment,_that.moderator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? date,  String? comment,  String? moderator)?  $default,) {final _that = this;
switch (_that) {
case _ModeratorHistoryItem() when $default != null:
return $default(_that.date,_that.comment,_that.moderator);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ModeratorHistoryItem implements ModeratorHistoryItem {
  const _ModeratorHistoryItem({this.date, this.comment, this.moderator});
  factory _ModeratorHistoryItem.fromJson(Map<String, dynamic> json) => _$ModeratorHistoryItemFromJson(json);

@override final  DateTime? date;
@override final  String? comment;
@override final  String? moderator;

/// Create a copy of ModeratorHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModeratorHistoryItemCopyWith<_ModeratorHistoryItem> get copyWith => __$ModeratorHistoryItemCopyWithImpl<_ModeratorHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModeratorHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModeratorHistoryItem&&(identical(other.date, date) || other.date == date)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.moderator, moderator) || other.moderator == moderator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,comment,moderator);

@override
String toString() {
  return 'ModeratorHistoryItem(date: $date, comment: $comment, moderator: $moderator)';
}


}

/// @nodoc
abstract mixin class _$ModeratorHistoryItemCopyWith<$Res> implements $ModeratorHistoryItemCopyWith<$Res> {
  factory _$ModeratorHistoryItemCopyWith(_ModeratorHistoryItem value, $Res Function(_ModeratorHistoryItem) _then) = __$ModeratorHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime? date, String? comment, String? moderator
});




}
/// @nodoc
class __$ModeratorHistoryItemCopyWithImpl<$Res>
    implements _$ModeratorHistoryItemCopyWith<$Res> {
  __$ModeratorHistoryItemCopyWithImpl(this._self, this._then);

  final _ModeratorHistoryItem _self;
  final $Res Function(_ModeratorHistoryItem) _then;

/// Create a copy of ModeratorHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = freezed,Object? comment = freezed,Object? moderator = freezed,}) {
  return _then(_ModeratorHistoryItem(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,moderator: freezed == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

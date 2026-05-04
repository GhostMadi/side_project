// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarkerTagModel {

 String get id; String get key;@JsonKey(name: 'group_key') String? get groupKey;
/// Create a copy of MarkerTagModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerTagModelCopyWith<MarkerTagModel> get copyWith => _$MarkerTagModelCopyWithImpl<MarkerTagModel>(this as MarkerTagModel, _$identity);

  /// Serializes this MarkerTagModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,groupKey);

@override
String toString() {
  return 'MarkerTagModel(id: $id, key: $key, groupKey: $groupKey)';
}


}

/// @nodoc
abstract mixin class $MarkerTagModelCopyWith<$Res>  {
  factory $MarkerTagModelCopyWith(MarkerTagModel value, $Res Function(MarkerTagModel) _then) = _$MarkerTagModelCopyWithImpl;
@useResult
$Res call({
 String id, String key,@JsonKey(name: 'group_key') String? groupKey
});




}
/// @nodoc
class _$MarkerTagModelCopyWithImpl<$Res>
    implements $MarkerTagModelCopyWith<$Res> {
  _$MarkerTagModelCopyWithImpl(this._self, this._then);

  final MarkerTagModel _self;
  final $Res Function(MarkerTagModel) _then;

/// Create a copy of MarkerTagModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? groupKey = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkerTagModel].
extension MarkerTagModelPatterns on MarkerTagModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkerTagModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkerTagModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkerTagModel value)  $default,){
final _that = this;
switch (_that) {
case _MarkerTagModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkerTagModel value)?  $default,){
final _that = this;
switch (_that) {
case _MarkerTagModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key, @JsonKey(name: 'group_key')  String? groupKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkerTagModel() when $default != null:
return $default(_that.id,_that.key,_that.groupKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key, @JsonKey(name: 'group_key')  String? groupKey)  $default,) {final _that = this;
switch (_that) {
case _MarkerTagModel():
return $default(_that.id,_that.key,_that.groupKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key, @JsonKey(name: 'group_key')  String? groupKey)?  $default,) {final _that = this;
switch (_that) {
case _MarkerTagModel() when $default != null:
return $default(_that.id,_that.key,_that.groupKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarkerTagModel implements MarkerTagModel {
  const _MarkerTagModel({required this.id, required this.key, @JsonKey(name: 'group_key') this.groupKey});
  factory _MarkerTagModel.fromJson(Map<String, dynamic> json) => _$MarkerTagModelFromJson(json);

@override final  String id;
@override final  String key;
@override@JsonKey(name: 'group_key') final  String? groupKey;

/// Create a copy of MarkerTagModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerTagModelCopyWith<_MarkerTagModel> get copyWith => __$MarkerTagModelCopyWithImpl<_MarkerTagModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkerTagModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerTagModel&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,groupKey);

@override
String toString() {
  return 'MarkerTagModel(id: $id, key: $key, groupKey: $groupKey)';
}


}

/// @nodoc
abstract mixin class _$MarkerTagModelCopyWith<$Res> implements $MarkerTagModelCopyWith<$Res> {
  factory _$MarkerTagModelCopyWith(_MarkerTagModel value, $Res Function(_MarkerTagModel) _then) = __$MarkerTagModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String key,@JsonKey(name: 'group_key') String? groupKey
});




}
/// @nodoc
class __$MarkerTagModelCopyWithImpl<$Res>
    implements _$MarkerTagModelCopyWith<$Res> {
  __$MarkerTagModelCopyWithImpl(this._self, this._then);

  final _MarkerTagModel _self;
  final $Res Function(_MarkerTagModel) _then;

/// Create a copy of MarkerTagModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? groupKey = freezed,}) {
  return _then(_MarkerTagModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MarkerMapItemModel {

 String get id;@JsonKey(name: 'owner_id') String get ownerId;@JsonKey(name: 'text_emoji') String? get textEmoji;@JsonKey(name: 'address_text') String? get addressText; String? get description;@JsonKey(name: 'cover_image_url') String? get coverImageUrl; double get lat; double get lng;@JsonKey(name: 'event_time') DateTime get eventTime;@JsonKey(name: 'end_time') DateTime get endTime;/// RPC returns string: upcoming|active|finished|cancelled
 String get status;@JsonKey(name: 'distance_m') double? get distanceM;@JsonKey(name: 'post_id') String? get postId;/// Сколько постов привязано к маркеру (`marker_posts`; 0 — пустой маркер на карте).
@JsonKey(name: 'post_count') int get postCount;/// До 4 превью URL первого медиа каждого поста (RPC `preview_image_urls`).
@JsonKey(name: 'preview_image_urls') List<String> get previewImageUrls;
/// Create a copy of MarkerMapItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerMapItemModelCopyWith<MarkerMapItemModel> get copyWith => _$MarkerMapItemModelCopyWithImpl<MarkerMapItemModel>(this as MarkerMapItemModel, _$identity);

  /// Serializes this MarkerMapItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerMapItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.textEmoji, textEmoji) || other.textEmoji == textEmoji)&&(identical(other.addressText, addressText) || other.addressText == addressText)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other.previewImageUrls, previewImageUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,textEmoji,addressText,description,coverImageUrl,lat,lng,eventTime,endTime,status,distanceM,postId,postCount,const DeepCollectionEquality().hash(previewImageUrls));

@override
String toString() {
  return 'MarkerMapItemModel(id: $id, ownerId: $ownerId, textEmoji: $textEmoji, addressText: $addressText, description: $description, coverImageUrl: $coverImageUrl, lat: $lat, lng: $lng, eventTime: $eventTime, endTime: $endTime, status: $status, distanceM: $distanceM, postId: $postId, postCount: $postCount, previewImageUrls: $previewImageUrls)';
}


}

/// @nodoc
abstract mixin class $MarkerMapItemModelCopyWith<$Res>  {
  factory $MarkerMapItemModelCopyWith(MarkerMapItemModel value, $Res Function(MarkerMapItemModel) _then) = _$MarkerMapItemModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId,@JsonKey(name: 'text_emoji') String? textEmoji,@JsonKey(name: 'address_text') String? addressText, String? description,@JsonKey(name: 'cover_image_url') String? coverImageUrl, double lat, double lng,@JsonKey(name: 'event_time') DateTime eventTime,@JsonKey(name: 'end_time') DateTime endTime, String status,@JsonKey(name: 'distance_m') double? distanceM,@JsonKey(name: 'post_id') String? postId,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'preview_image_urls') List<String> previewImageUrls
});




}
/// @nodoc
class _$MarkerMapItemModelCopyWithImpl<$Res>
    implements $MarkerMapItemModelCopyWith<$Res> {
  _$MarkerMapItemModelCopyWithImpl(this._self, this._then);

  final MarkerMapItemModel _self;
  final $Res Function(MarkerMapItemModel) _then;

/// Create a copy of MarkerMapItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? textEmoji = freezed,Object? addressText = freezed,Object? description = freezed,Object? coverImageUrl = freezed,Object? lat = null,Object? lng = null,Object? eventTime = null,Object? endTime = null,Object? status = null,Object? distanceM = freezed,Object? postId = freezed,Object? postCount = null,Object? previewImageUrls = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,textEmoji: freezed == textEmoji ? _self.textEmoji : textEmoji // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,previewImageUrls: null == previewImageUrls ? _self.previewImageUrls : previewImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkerMapItemModel].
extension MarkerMapItemModelPatterns on MarkerMapItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkerMapItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkerMapItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkerMapItemModel value)  $default,){
final _that = this;
switch (_that) {
case _MarkerMapItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkerMapItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _MarkerMapItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  double lat,  double lng, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'distance_m')  double? distanceM, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'preview_image_urls')  List<String> previewImageUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkerMapItemModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.textEmoji,_that.addressText,_that.description,_that.coverImageUrl,_that.lat,_that.lng,_that.eventTime,_that.endTime,_that.status,_that.distanceM,_that.postId,_that.postCount,_that.previewImageUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  double lat,  double lng, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'distance_m')  double? distanceM, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'preview_image_urls')  List<String> previewImageUrls)  $default,) {final _that = this;
switch (_that) {
case _MarkerMapItemModel():
return $default(_that.id,_that.ownerId,_that.textEmoji,_that.addressText,_that.description,_that.coverImageUrl,_that.lat,_that.lng,_that.eventTime,_that.endTime,_that.status,_that.distanceM,_that.postId,_that.postCount,_that.previewImageUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'owner_id')  String ownerId, @JsonKey(name: 'text_emoji')  String? textEmoji, @JsonKey(name: 'address_text')  String? addressText,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  double lat,  double lng, @JsonKey(name: 'event_time')  DateTime eventTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status, @JsonKey(name: 'distance_m')  double? distanceM, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'preview_image_urls')  List<String> previewImageUrls)?  $default,) {final _that = this;
switch (_that) {
case _MarkerMapItemModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.textEmoji,_that.addressText,_that.description,_that.coverImageUrl,_that.lat,_that.lng,_that.eventTime,_that.endTime,_that.status,_that.distanceM,_that.postId,_that.postCount,_that.previewImageUrls);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarkerMapItemModel implements MarkerMapItemModel {
  const _MarkerMapItemModel({required this.id, @JsonKey(name: 'owner_id') required this.ownerId, @JsonKey(name: 'text_emoji') this.textEmoji, @JsonKey(name: 'address_text') this.addressText, this.description, @JsonKey(name: 'cover_image_url') this.coverImageUrl, required this.lat, required this.lng, @JsonKey(name: 'event_time') required this.eventTime, @JsonKey(name: 'end_time') required this.endTime, required this.status, @JsonKey(name: 'distance_m') this.distanceM, @JsonKey(name: 'post_id') this.postId, @JsonKey(name: 'post_count') this.postCount = 0, @JsonKey(name: 'preview_image_urls') final  List<String> previewImageUrls = const <String>[]}): _previewImageUrls = previewImageUrls;
  factory _MarkerMapItemModel.fromJson(Map<String, dynamic> json) => _$MarkerMapItemModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override@JsonKey(name: 'text_emoji') final  String? textEmoji;
@override@JsonKey(name: 'address_text') final  String? addressText;
@override final  String? description;
@override@JsonKey(name: 'cover_image_url') final  String? coverImageUrl;
@override final  double lat;
@override final  double lng;
@override@JsonKey(name: 'event_time') final  DateTime eventTime;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
/// RPC returns string: upcoming|active|finished|cancelled
@override final  String status;
@override@JsonKey(name: 'distance_m') final  double? distanceM;
@override@JsonKey(name: 'post_id') final  String? postId;
/// Сколько постов привязано к маркеру (`marker_posts`; 0 — пустой маркер на карте).
@override@JsonKey(name: 'post_count') final  int postCount;
/// До 4 превью URL первого медиа каждого поста (RPC `preview_image_urls`).
 final  List<String> _previewImageUrls;
/// До 4 превью URL первого медиа каждого поста (RPC `preview_image_urls`).
@override@JsonKey(name: 'preview_image_urls') List<String> get previewImageUrls {
  if (_previewImageUrls is EqualUnmodifiableListView) return _previewImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previewImageUrls);
}


/// Create a copy of MarkerMapItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerMapItemModelCopyWith<_MarkerMapItemModel> get copyWith => __$MarkerMapItemModelCopyWithImpl<_MarkerMapItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkerMapItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerMapItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.textEmoji, textEmoji) || other.textEmoji == textEmoji)&&(identical(other.addressText, addressText) || other.addressText == addressText)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.eventTime, eventTime) || other.eventTime == eventTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other._previewImageUrls, _previewImageUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,textEmoji,addressText,description,coverImageUrl,lat,lng,eventTime,endTime,status,distanceM,postId,postCount,const DeepCollectionEquality().hash(_previewImageUrls));

@override
String toString() {
  return 'MarkerMapItemModel(id: $id, ownerId: $ownerId, textEmoji: $textEmoji, addressText: $addressText, description: $description, coverImageUrl: $coverImageUrl, lat: $lat, lng: $lng, eventTime: $eventTime, endTime: $endTime, status: $status, distanceM: $distanceM, postId: $postId, postCount: $postCount, previewImageUrls: $previewImageUrls)';
}


}

/// @nodoc
abstract mixin class _$MarkerMapItemModelCopyWith<$Res> implements $MarkerMapItemModelCopyWith<$Res> {
  factory _$MarkerMapItemModelCopyWith(_MarkerMapItemModel value, $Res Function(_MarkerMapItemModel) _then) = __$MarkerMapItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId,@JsonKey(name: 'text_emoji') String? textEmoji,@JsonKey(name: 'address_text') String? addressText, String? description,@JsonKey(name: 'cover_image_url') String? coverImageUrl, double lat, double lng,@JsonKey(name: 'event_time') DateTime eventTime,@JsonKey(name: 'end_time') DateTime endTime, String status,@JsonKey(name: 'distance_m') double? distanceM,@JsonKey(name: 'post_id') String? postId,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'preview_image_urls') List<String> previewImageUrls
});




}
/// @nodoc
class __$MarkerMapItemModelCopyWithImpl<$Res>
    implements _$MarkerMapItemModelCopyWith<$Res> {
  __$MarkerMapItemModelCopyWithImpl(this._self, this._then);

  final _MarkerMapItemModel _self;
  final $Res Function(_MarkerMapItemModel) _then;

/// Create a copy of MarkerMapItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? textEmoji = freezed,Object? addressText = freezed,Object? description = freezed,Object? coverImageUrl = freezed,Object? lat = null,Object? lng = null,Object? eventTime = null,Object? endTime = null,Object? status = null,Object? distanceM = freezed,Object? postId = freezed,Object? postCount = null,Object? previewImageUrls = null,}) {
  return _then(_MarkerMapItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,textEmoji: freezed == textEmoji ? _self.textEmoji : textEmoji // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,eventTime: null == eventTime ? _self.eventTime : eventTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,previewImageUrls: null == previewImageUrls ? _self._previewImageUrls : previewImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

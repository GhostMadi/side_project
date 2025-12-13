// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Announcement {

/// id объявления
 String? get id;/// id создателя объявления
 String? get creatorId;/// заголовок
 String? get title;/// тип объявления (например: news, update, promo)
 String? get type;/// категория (например: system, user, marketing)
 String? get category;/// список ссылок на картинки
 List<String> get imageUrls;/// список описаний
 List<AnnouncementDescription> get descriptions;
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<Announcement> get copyWith => _$AnnouncementCopyWithImpl<Announcement>(this as Announcement, _$identity);

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&const DeepCollectionEquality().equals(other.descriptions, descriptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,type,category,const DeepCollectionEquality().hash(imageUrls),const DeepCollectionEquality().hash(descriptions));

@override
String toString() {
  return 'Announcement(id: $id, creatorId: $creatorId, title: $title, type: $type, category: $category, imageUrls: $imageUrls, descriptions: $descriptions)';
}


}

/// @nodoc
abstract mixin class $AnnouncementCopyWith<$Res>  {
  factory $AnnouncementCopyWith(Announcement value, $Res Function(Announcement) _then) = _$AnnouncementCopyWithImpl;
@useResult
$Res call({
 String? id, String? creatorId, String? title, String? type, String? category, List<String> imageUrls, List<AnnouncementDescription> descriptions
});




}
/// @nodoc
class _$AnnouncementCopyWithImpl<$Res>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._self, this._then);

  final Announcement _self;
  final $Res Function(Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? creatorId = freezed,Object? title = freezed,Object? type = freezed,Object? category = freezed,Object? imageUrls = null,Object? descriptions = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,descriptions: null == descriptions ? _self.descriptions : descriptions // ignore: cast_nullable_to_non_nullable
as List<AnnouncementDescription>,
  ));
}

}


/// Adds pattern-matching-related methods to [Announcement].
extension AnnouncementPatterns on Announcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Announcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Announcement value)  $default,){
final _that = this;
switch (_that) {
case _Announcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Announcement value)?  $default,){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? creatorId,  String? title,  String? type,  String? category,  List<String> imageUrls,  List<AnnouncementDescription> descriptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.category,_that.imageUrls,_that.descriptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? creatorId,  String? title,  String? type,  String? category,  List<String> imageUrls,  List<AnnouncementDescription> descriptions)  $default,) {final _that = this;
switch (_that) {
case _Announcement():
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.category,_that.imageUrls,_that.descriptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? creatorId,  String? title,  String? type,  String? category,  List<String> imageUrls,  List<AnnouncementDescription> descriptions)?  $default,) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.category,_that.imageUrls,_that.descriptions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Announcement implements Announcement {
  const _Announcement({this.id, this.creatorId, this.title, this.type, this.category, final  List<String> imageUrls = const <String>[], final  List<AnnouncementDescription> descriptions = const <AnnouncementDescription>[]}): _imageUrls = imageUrls,_descriptions = descriptions;
  factory _Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

/// id объявления
@override final  String? id;
/// id создателя объявления
@override final  String? creatorId;
/// заголовок
@override final  String? title;
/// тип объявления (например: news, update, promo)
@override final  String? type;
/// категория (например: system, user, marketing)
@override final  String? category;
/// список ссылок на картинки
 final  List<String> _imageUrls;
/// список ссылок на картинки
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

/// список описаний
 final  List<AnnouncementDescription> _descriptions;
/// список описаний
@override@JsonKey() List<AnnouncementDescription> get descriptions {
  if (_descriptions is EqualUnmodifiableListView) return _descriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_descriptions);
}


/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementCopyWith<_Announcement> get copyWith => __$AnnouncementCopyWithImpl<_Announcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&const DeepCollectionEquality().equals(other._descriptions, _descriptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,type,category,const DeepCollectionEquality().hash(_imageUrls),const DeepCollectionEquality().hash(_descriptions));

@override
String toString() {
  return 'Announcement(id: $id, creatorId: $creatorId, title: $title, type: $type, category: $category, imageUrls: $imageUrls, descriptions: $descriptions)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementCopyWith<$Res> implements $AnnouncementCopyWith<$Res> {
  factory _$AnnouncementCopyWith(_Announcement value, $Res Function(_Announcement) _then) = __$AnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? creatorId, String? title, String? type, String? category, List<String> imageUrls, List<AnnouncementDescription> descriptions
});




}
/// @nodoc
class __$AnnouncementCopyWithImpl<$Res>
    implements _$AnnouncementCopyWith<$Res> {
  __$AnnouncementCopyWithImpl(this._self, this._then);

  final _Announcement _self;
  final $Res Function(_Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? creatorId = freezed,Object? title = freezed,Object? type = freezed,Object? category = freezed,Object? imageUrls = null,Object? descriptions = null,}) {
  return _then(_Announcement(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,descriptions: null == descriptions ? _self._descriptions : descriptions // ignore: cast_nullable_to_non_nullable
as List<AnnouncementDescription>,
  ));
}


}


/// @nodoc
mixin _$AnnouncementDescription {

/// id описания
 String? get id;/// ссылка на id объявления (idAnnouncement)
 String? get announcementId;/// текст описания
 String? get description;/// ссылка на картинку
 String? get imageUrl;
/// Create a copy of AnnouncementDescription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementDescriptionCopyWith<AnnouncementDescription> get copyWith => _$AnnouncementDescriptionCopyWithImpl<AnnouncementDescription>(this as AnnouncementDescription, _$identity);

  /// Serializes this AnnouncementDescription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnouncementDescription&&(identical(other.id, id) || other.id == id)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,announcementId,description,imageUrl);

@override
String toString() {
  return 'AnnouncementDescription(id: $id, announcementId: $announcementId, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $AnnouncementDescriptionCopyWith<$Res>  {
  factory $AnnouncementDescriptionCopyWith(AnnouncementDescription value, $Res Function(AnnouncementDescription) _then) = _$AnnouncementDescriptionCopyWithImpl;
@useResult
$Res call({
 String? id, String? announcementId, String? description, String? imageUrl
});




}
/// @nodoc
class _$AnnouncementDescriptionCopyWithImpl<$Res>
    implements $AnnouncementDescriptionCopyWith<$Res> {
  _$AnnouncementDescriptionCopyWithImpl(this._self, this._then);

  final AnnouncementDescription _self;
  final $Res Function(AnnouncementDescription) _then;

/// Create a copy of AnnouncementDescription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? announcementId = freezed,Object? description = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,announcementId: freezed == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnnouncementDescription].
extension AnnouncementDescriptionPatterns on AnnouncementDescription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnouncementDescription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnouncementDescription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnouncementDescription value)  $default,){
final _that = this;
switch (_that) {
case _AnnouncementDescription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnouncementDescription value)?  $default,){
final _that = this;
switch (_that) {
case _AnnouncementDescription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? announcementId,  String? description,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnouncementDescription() when $default != null:
return $default(_that.id,_that.announcementId,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? announcementId,  String? description,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _AnnouncementDescription():
return $default(_that.id,_that.announcementId,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? announcementId,  String? description,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _AnnouncementDescription() when $default != null:
return $default(_that.id,_that.announcementId,_that.description,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _AnnouncementDescription implements AnnouncementDescription {
  const _AnnouncementDescription({this.id, this.announcementId, this.description, this.imageUrl});
  factory _AnnouncementDescription.fromJson(Map<String, dynamic> json) => _$AnnouncementDescriptionFromJson(json);

/// id описания
@override final  String? id;
/// ссылка на id объявления (idAnnouncement)
@override final  String? announcementId;
/// текст описания
@override final  String? description;
/// ссылка на картинку
@override final  String? imageUrl;

/// Create a copy of AnnouncementDescription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementDescriptionCopyWith<_AnnouncementDescription> get copyWith => __$AnnouncementDescriptionCopyWithImpl<_AnnouncementDescription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementDescriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnouncementDescription&&(identical(other.id, id) || other.id == id)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,announcementId,description,imageUrl);

@override
String toString() {
  return 'AnnouncementDescription(id: $id, announcementId: $announcementId, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementDescriptionCopyWith<$Res> implements $AnnouncementDescriptionCopyWith<$Res> {
  factory _$AnnouncementDescriptionCopyWith(_AnnouncementDescription value, $Res Function(_AnnouncementDescription) _then) = __$AnnouncementDescriptionCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? announcementId, String? description, String? imageUrl
});




}
/// @nodoc
class __$AnnouncementDescriptionCopyWithImpl<$Res>
    implements _$AnnouncementDescriptionCopyWith<$Res> {
  __$AnnouncementDescriptionCopyWithImpl(this._self, this._then);

  final _AnnouncementDescription _self;
  final $Res Function(_AnnouncementDescription) _then;

/// Create a copy of AnnouncementDescription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? announcementId = freezed,Object? description = freezed,Object? imageUrl = freezed,}) {
  return _then(_AnnouncementDescription(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,announcementId: freezed == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

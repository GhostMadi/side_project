import 'package:side_project/feature/cities/data/models/city_code.dart';
import 'package:side_project/feature/countries/data/models/country_code.dart';
import 'package:side_project/feature/profile_categories/data/models/profile_category_code.dart';

/// Строка `public.profiles` (ответ PostgREST / Supabase).
///
/// **Базовая таблица:** `id`, `email`, `full_name`, `username`, `category_code`, `city_code`,
/// `country_code` (char(2)), `avatar_url`, `background_url`, `bio`, `phone`,
/// `followers_count`, `following_count`, `cluster_count`, `post_count`, `created_at`, `updated_at`.
///
/// **Дополнительно** (миграция `20260329140000_profiles_username_change_limit.sql`):
/// `username_change_count`, `username_next_change_allowed_at` — лимит смены ника; в JSON могут
/// отсутствовать, тогда в модели `0` и `null`.
///
/// В коде: [countryCode] / [cityCode] — разбор через enum; [citySlug] — если `city_code` есть в БД,
/// но slug не вошёл в [CityCode] (показ и сохранение «как в API»).
class ProfileModel {
  const ProfileModel({
    required this.id,
    this.email,
    this.fullName,
    this.username,
    this.categoryCode,
    this.countryCode,
    this.cityCode,
    this.citySlug,
    this.avatarUrl,
    this.backgroundUrl,
    this.bio,
    this.phone,
    this.followersCount = 0,
    this.followingCount = 0,
    this.clusterCount = 0,
    this.postCount = 0,
    this.usernameChangeCount = 0,
    this.usernameNextChangeAllowedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String? username;

  /// `category_code` — код категории в справочнике.
  final ProfileCategoryCode? categoryCode;

  /// `country_code` — как в `public.countries.code`.
  final CountryCode? countryCode;

  /// Город, если slug известен enum'у [CityCode].
  final CityCode? cityCode;

  /// Сырой `city_code` из БД, только если [cityCode] не удалось распарсить.
  final String? citySlug;

  final String? avatarUrl;
  final String? backgroundUrl;
  final String? bio;
  final String? phone;
  final int followersCount;
  final int followingCount;
  final int clusterCount;

  /// Опубликованные посты в сетке профиля (не в архиве, не soft delete) — `profiles.post_count` в БД.
  final int postCount;

  /// Сколько смен ника уже «использовано» в текущем окне (0…4).
  /// Первый ввод ника с пустого сюда не входит — считаем только смены «был ник → другой ник».
  final int usernameChangeCount;

  /// Пока не наступит этот момент (время в UTC), сменить ник нельзя — идёт пауза после 4 смен.
  /// Если `null`, такой паузы нет: можно менять по лимиту смен в окне.
  final DateTime? usernameNextChangeAllowedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawCountry = (json['country_code'] as String?)?.trim();
    final rawCity = (json['city_code'] as String?)?.trim();

    final country = CountryCode.tryParse(rawCountry);
    final slugRaw = (rawCity != null && rawCity.isNotEmpty) ? rawCity.trim() : null;
    CityCode? city;
    if (slugRaw != null && country != null) {
      city = CityCode.tryParse(countryCode: country.code, cityCode: slugRaw);
    }

    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      categoryCode: ProfileCategoryCode.tryParse(json['category_code'] as String?),
      countryCode: country,
      cityCode: city,
      citySlug: (slugRaw != null && city == null) ? slugRaw : null,
      avatarUrl: json['avatar_url'] as String?,
      backgroundUrl: json['background_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      clusterCount:
          (json['cluster_count'] as num?)?.toInt() ?? (json['collection_count'] as num?)?.toInt() ?? 0,
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
      usernameChangeCount: (json['username_change_count'] as num?)?.toInt() ?? 0,
      usernameNextChangeAllowedAt: _parseDate(json['username_next_change_allowed_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Сколько смен ника осталось в текущем окне (после снятия паузы — снова до 4).
  int get usernameChangesRemaining {
    if (isUsernameChangeCooldownActive) return 0;
    final until = usernameNextChangeAllowedAt;
    final now = DateTime.now().toUtc();
    if (usernameChangeCount >= 4 && (until == null || !now.isBefore(until))) {
      return 4;
    }
    return (4 - usernameChangeCount).clamp(0, 4).toInt();
  }

  /// Пауза после лимита: есть дедлайн и текущее время раньше него (как в триггере).
  bool get isUsernameChangeCooldownActive {
    final until = usernameNextChangeAllowedAt;
    if (until == null) return false;
    return DateTime.now().toUtc().isBefore(until);
  }

  /// Можно ли сменить ник, опираясь только на поля профиля (без лишнего запроса к API).
  bool get canChangeUsername => !isUsernameChangeCooldownActive && usernameChangesRemaining > 0;

  /// Подпись города: enum или неизвестный slug из БД.
  String? get cityLabel => cityCode?.labelRu ?? citySlug;

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

import 'package:flutter/material.dart';

// class AppColors {
//   static Color primary = Colors.white;
//   static Color secondary = Colors.black;
//   static Color brand = Color(0xffB7F5FE);

//   static Color strokeColor = Color(0xffBEBFBE);
// }

/// Доступ к кастомным цветам через context.appColors
extension AppColorsX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.fallback;
}

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary; // фон / surface
  final Color secondary; // основной текст
  final Color brand; // акцент
  final Color third; // бордер/строки
  final Color fourth; // вторичный фон/disabled fill
  final Color error; // вторичный фон/disabled fill

  const AppColorsExtension({
    required this.primary,
    required this.secondary,
    required this.brand,
    required this.third,
    required this.fourth,
    required this.error,
  });

  static const fallback = AppColorsExtension(
    primary: Colors.transparent,
    secondary: Colors.transparent,
    brand: Colors.transparent,
    third: Colors.transparent,
    fourth: Colors.transparent,
    error: Colors.transparent,
  );

  /// Светлая тема
  static const light = AppColorsExtension(
    primary: Colors.white,
    secondary: Colors.black,
    brand: Color(0xffB7F5FE),
    third: Color(0xffBEBFBE),
    fourth: Color(0xffDBDDE1),
    error: Color(0xffFEB6B6),
  );

  /// Тёмная тема
  static const dark = AppColorsExtension(
    primary: Colors.black,
    secondary: Colors.white,
    brand: Color(0xffB7F5FE), // если хочешь тот же brand и в dark
    third: Color(0xffBEBFBE),
    fourth: Color(0xff2A2A2A), // лучше темнее для dark, чем #DBDDE1
    error: Color(0xffFEB6B6),
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? brand,
    Color? third,
    Color? fourth,
    Color? error,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      brand: brand ?? this.brand,
      third: third ?? this.third,
      fourth: fourth ?? this.fourth,
      error: error ?? this.error,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      third: Color.lerp(third, other.third, t)!,
      fourth: Color.lerp(fourth, other.fourth, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

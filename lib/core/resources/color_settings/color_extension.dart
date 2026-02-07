// import 'package:flutter/material.dart';
// import 'package:side_project/core/resources/color_settings/app_colors.dart';

// /// Доступ к кастомным цветам через AppColors
// extension AppColorsX on BuildContext {
//   AppColorsExtension get appColors =>
//       Theme.of(this).extension<AppColorsExtension>() ??
//       AppColorsExtension.fallback;
// }

// @immutable
// class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
//   final Color primary; // фон / surface
//   final Color secondary; // основной текст
//   final Color brand; // акцент
//   final Color third; // бордер/строки
//   final Color fourth; // вторичный фон/disabled fill
//   final Color error; // ошибка

//   const AppColorsExtension({
//     required this.primary,
//     required this.secondary,
//     required this.brand,
//     required this.third,
//     required this.fourth,
//     required this.error,
//   });

//   /// Фолбэк на случай ошибок (прозрачный)
//   static const fallback = AppColorsExtension(
//     primary: Colors.transparent,
//     secondary: Colors.transparent,
//     brand: Colors.transparent,
//     third: Colors.transparent,
//     fourth: Colors.transparent,
//     error: Colors.transparent,
//   );

//   /// СВЕТЛАЯ ТЕМА (Берет данные из AppColors.white)
//   static final light = AppColorsExtension(
//     primary: AppColors.white.primarySurface,
//     secondary: AppColors.white.mainText,
//     brand: AppColors.white.brand,
//     third: AppColors.white.border,
//     fourth: AppColors.white.secondaryFill,
//     error: AppColors.white.error,
//   );

//   /// ТЁМНАЯ ТЕМА (Берет данные из AppColors.black)
//   static final dark = AppColorsExtension(
//     primary: AppColors.black.primarySurface,
//     secondary: AppColors.black.mainText,
//     brand: AppColors.black.brand,
//     third: AppColors.black.border,
//     fourth: AppColors.black.secondaryFill,
//     error: AppColors.black.error,
//   );

//   @override
//   AppColorsExtension copyWith({
//     Color? primary,
//     Color? secondary,
//     Color? brand,
//     Color? third,
//     Color? fourth,
//     Color? error,
//   }) {
//     return AppColorsExtension(
//       primary: primary ?? this.primary,
//       secondary: secondary ?? this.secondary,
//       brand: brand ?? this.brand,
//       third: third ?? this.third,
//       fourth: fourth ?? this.fourth,
//       error: error ?? this.error,
//     );
//   }

//   @override
//   AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
//     if (other is! AppColorsExtension) return this;

//     return AppColorsExtension(
//       primary: Color.lerp(primary, other.primary, t)!,
//       secondary: Color.lerp(secondary, other.secondary, t)!,
//       brand: Color.lerp(brand, other.brand, t)!,
//       third: Color.lerp(third, other.third, t)!,
//       fourth: Color.lerp(fourth, other.fourth, t)!,
//       error: Color.lerp(error, other.error, t)!,
//     );
//   }
// }

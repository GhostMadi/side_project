import 'package:flutter/material.dart';

abstract class AppColors {
  // Общий цвет (если он одинаковый для обоих тем)
  static const Color brand = Color(0xffB7F5FE);

  // Цвета bottombar
  static const Color bottomBarColor = Color(0xFFFFFFFF);
  static const Color bottomBarActiveIcon = Color(0xFF8BC34A);
  static const Color bottomBarInactiveIcon = Color(0xFFA1AAB3);
  static Color bottomBarSegment = const Color(0xFF8BC34A).withValues(alpha: 0.12);
  static Color bottomBarShadow = const Color(0xFF8BC34A).withValues(alpha: 0.2);

  //sheet
  static const Color bgColor = Color(0xFF0D140A); // Темный фон с легким зеленым подтоном
  static const Color activeColor = Color(0xFFC5FEB7); // Мягкий салатовый (Apple/Lime)
  static const Color inactiveColor = Color(0xFF43573D); // Приглушенный серо-зеленый

  // Button (Soft Lime Style)
  static const Color btnBackground = Color(0xFF8BC34A); // Основной салатовый фон
  static const Color btnText = Color(0xFFFFFFFF); // Темный текст (тот же, что bgColor)
  static const Color btnDisabled = Color(0xFF1A2418); // Темно-зеленый выключенный фон
  static const Color btnDisabledText = Color(0xFF43573D); // Приглушенный текст выключенной кнопки

  //text
  static const Color textColor = Color(0xFF1A1D1E); // Почти черный, но мягче
  static const Color subTextColor = Color(0xFF6A6A6A); // Глубокий серый (для описаний)

  // /// Набор цветов для светлой (White) темы
  // static const white = _WhitePalette();

  // /// Набор цветов для темной (Black) темы
  // static const black = _BlackPalette();
}

// /// Класс-хранилище для светлой палитры
// class _WhitePalette {
//   const _WhitePalette();

//   final Color primarySurface = Colors.white;
//   final Color mainText = Colors.black;
//   final Color brand = AppColors.brand;
//   final Color border = const Color(0xffBEBFBE);
//   final Color secondaryFill = const Color(0xffDBDDE1);
//   final Color error = const Color(0xffFEB6B6);
// }

// /// Класс-хранилище для темной палитры
// class _BlackPalette {
//   const _BlackPalette();

//   final Color primarySurface = Colors.black;
//   final Color mainText = Colors.white;
//   final Color brand = const Color(0xffB7F5FE);
//   final Color border = const Color(0xffBEBFBE);
//   final Color secondaryFill = const Color(0xff2A2A2A);
//   final Color error = const Color(0xffFEB6B6);
// }

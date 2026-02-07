import 'package:flutter/material.dart';

abstract class AppColors {
  // Общий цвет (если он одинаковый для обоих тем)
  static const Color brand = Color(0xffB7F5FE);

  // Цвета bottombar
  static const Color bottomBarColor = Color(0xFF0A0B14); // Глубокий синий фон
  static const Color bottomBarActiveIcon = Color(0xFFB7C9FE); // Светло-синий актив
  static const Color bottomBarInactiveIcon = Color(0xFF3D4257); // Серо-синий
  static Color bottomBarSegment = const Color(0xFFB7C9FE).withValues(alpha: 0.12);
  static Color bottomBarShadow = const Color(0xFFB7C9FE).withValues(alpha: 0.3);

  //text
  static const Color textColor = Colors.black;
  static const Color subTextColor = Colors.grey;

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

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/color_extension.dart';

ThemeData lightTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    extensions: [
      AppColorsExtension.light, // Цвета
      // AppTypographyExtension.light, // Шрифты
      // AppDimensionsExtension.main,
    ],
  );
}

ThemeData blackTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.black,

    extensions: [
      AppColorsExtension.dark, // Цвета
      // AppTypographyExtension.dark, // Шрифты
      // AppDimensionsExtension.main,
    ],
  );
}
